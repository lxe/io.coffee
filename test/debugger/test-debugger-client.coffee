# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

# Make sure split messages go in.

# Make sure that if we get backed up, we still manage to get all the
# messages
addTest = (cb) ->
  expectedConnections++
  tests.push cb
  return
doTest = (cb, done) ->
  args = [
    "--debug=" + debugPort
    "-e"
    script
  ]
  nodeProcess = spawn(process.execPath, args)
  nodeProcess.stdout.once "data", (c) ->
    console.log ">>> new node process: %d", nodeProcess.pid
    failed = true
    try
      process._debugProcess nodeProcess.pid
      failed = false
    finally
      
      # At least TRY not to leave zombie procs if this fails.
      nodeProcess.kill "SIGTERM"  if failed
    console.log ">>> starting debugger session"
    return

  didTryConnect = false
  nodeProcess.stderr.setEncoding "utf8"
  b = ""
  nodeProcess.stderr.on "data", (data) ->
    console.error "got stderr data %j", data
    nodeProcess.stderr.resume()
    b += data
    if didTryConnect is false and b.match(/Debugger listening on port/)
      
      # The timeout is here to expose a race in the bootstrap process.
      # Without the early SIGUSR1 debug handler, it effectively results
      # in an infinite ECONNREFUSED loop.
      tryConnect = ->
        
        # Wait for some data before trying to connect
        c = new debug.Client()
        console.error ">>> connecting..."
        c.connect debug.port
        c.on "break", (brk) ->
          c.reqContinue ->

          return

        c.on "ready", ->
          connectCount++
          console.log "ready!"
          cb c, ->
            c.end()
            c.on "end", ->
              console.error ">>> killing node process %d\n\n", nodeProcess.pid
              nodeProcess.kill()
              done()
              return

            return

          return

        c.on "error", (err) ->
          throw err  if err.code isnt "ECONNREFUSED"
          setTimeout tryConnect, 10
          return

        return
      didTryConnect = true
      setTimeout tryConnect, 100
    return

  return
run = ->
  t = tests[0]
  return  unless t
  doTest t, ->
    tests.shift()
    run()
    return

  return
process.env.NODE_DEBUGGER_TIMEOUT = 2000
common = require("../common")
assert = require("assert")
debug = require("_debugger")
debugPort = common.PORT + 1337
debug.port = debugPort
spawn = require("child_process").spawn
setTimeout(->
  nodeProcess.kill "SIGTERM"  if nodeProcess
  throw new Error("timeout")return
, 10000).unref()
resCount = 0
p = new debug.Protocol()
p.onResponse = (res) ->
  resCount++
  return

p.execute "Type: connect\r\n" + "V8-Version: 3.0.4.1\r\n" + "Protocol-Version: 1\r\n" + "Embedding-Host: node v0.3.3-pre\r\n" + "Content-Length: 0\r\n\r\n"
assert.equal 1, resCount
parts = []
parts.push "Content-Length: 336\r\n"
assert.equal 21, parts[0].length
parts.push "\r\n"
assert.equal 2, parts[1].length
bodyLength = 0
parts.push "{\"seq\":12,\"type\":\"event\",\"event\":\"break\",\"body\":" + "{\"invocationText\":\"#<a Server>"
assert.equal 78, parts[2].length
bodyLength += parts[2].length
parts.push ".[anonymous](req=#<an IncomingMessage>, " + "res=#<a ServerResponse>)\",\"sourceLine\""
assert.equal 78, parts[3].length
bodyLength += parts[3].length
parts.push ":45,\"sourceColumn\":4,\"sourceLineText\":\"    debugger;\"," + "\"script\":{\"id\":24,\"name\":\"/home/ryan/projects/node/" + "benchmark/http_simple.js\",\"lineOffset\":0,\"columnOffset\":0," + "\"lineCount\":98}}}"
assert.equal 180, parts[4].length
bodyLength += parts[4].length
assert.equal 336, bodyLength
i = 0

while i < parts.length
  p.execute parts[i]
  i++
assert.equal 2, resCount
d = "Content-Length: 466\r\n\r\n" + "{\"seq\":10,\"type\":\"event\",\"event\":\"afterCompile\",\"success\":true," + "\"body\":{\"script\":{\"handle\":1,\"type\":\"script\",\"name\":\"dns.js\"," + "\"id\":34,\"lineOffset\":0,\"columnOffset\":0,\"lineCount\":241," + "\"sourceStart\":\"(function (module, exports, require) {" + "var dns = process.binding('cares')" + ";\\nvar ne\",\"sourceLength\":6137,\"scriptType\":2,\"compilationType\":0," + "\"context\":{\"ref\":0},\"text\":\"dns.js (lines: 241)\"}},\"refs\":" + "[{\"handle\":0" + ",\"type\":\"context\",\"text\":\"#<a ContextMirror>\"}],\"running\":true}" + "Content-Length: 119\r\n\r\n" + "{\"seq\":11,\"type\":\"event\",\"event\":\"scriptCollected\",\"success\":true," + "\"body\":{\"script\":{\"id\":26}},\"refs\":[],\"running\":true}"
p.execute d
assert.equal 4, resCount
expectedConnections = 0
tests = []
addTest (client, done) ->
  console.error "requesting version"
  client.reqVersion (err, v) ->
    assert.ok not err
    console.log "version: %s", v
    assert.equal process.versions.v8, v
    done()
    return

  return

addTest (client, done) ->
  console.error "requesting scripts"
  client.reqScripts (err) ->
    assert.ok not err
    console.error "got %d scripts", Object.keys(client.scripts).length
    foundMainScript = false
    for k of client.scripts
      script = client.scripts[k]
      if script and script.name is "node.js"
        foundMainScript = true
        break
    assert.ok foundMainScript
    done()
    return

  return

addTest (client, done) ->
  console.error "eval 2+2"
  client.reqEval "2+2", (err, res) ->
    console.error res
    assert.ok not err
    assert.equal "4", res.text
    assert.equal 4, res.value
    done()
    return

  return

connectCount = 0
script = "setTimeout(function () { console.log(\"blah\"); });" + "setInterval(function () {}, 1000000);"
nodeProcess = undefined
run()
process.on "exit", (code) ->
  assert.equal expectedConnections, connectCount  unless code
  return

