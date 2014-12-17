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
startDebugger = (scriptToDebug) ->
  scriptToDebug = process.env.NODE_DEBUGGER_TEST_SCRIPT or common.fixturesDir + "/" + scriptToDebug
  child = spawn(process.execPath, [
    "debug"
    "--port=" + port
    scriptToDebug
  ])
  console.error "./node", "debug", "--port=" + port, scriptToDebug
  child.stdout.setEncoding "utf-8"
  child.stdout.on "data", (data) ->
    data = (buffer + data).split("\n")
    buffer = data.pop()
    data.forEach (line) ->
      child.emit "line", line
      return

    return

  child.stderr.pipe process.stderr
  child.on "line", (line) ->
    line = line.replace(/^(debug> *)+/, "")
    console.log line
    assert.ok expected.length > 0, "Got unexpected line: " + line
    expectedLine = expected[0].lines.shift()
    assert.ok line.match(expectedLine) isnt null, line + " != " + expectedLine
    if expected[0].lines.length is 0
      callback = expected[0].callback
      expected.shift()
      callback and callback()
    return

  childClosed = false
  child.on "close", (code) ->
    assert not code
    childClosed = true
    return

  quitCalled = false
  quit = ->
    return  if quitCalled or childClosed
    quitCalled = true
    child.stdin.write "quit"
    child.kill "SIGTERM"
    return

  setTimeout(->
    console.error "dying badly buffer=%j", buffer
    err = "Timeout"
    err = err + ". Expected: " + expected[0].lines.shift()  if expected.length > 0 and expected[0].lines
    child.on "close", ->
      console.error "child is closed"
      throw new Error(err)return

    quit()
    return
  , 10000).unref()
  process.once "uncaughtException", (e) ->
    console.error "UncaughtException", e, e.stack
    quit()
    console.error e.toString()
    process.exit 1
    return

  process.on "exit", (code) ->
    console.error "process exit", code
    quit()
    assert childClosed  if code is 0
    return

  return
addTest = (input, output) ->
  next = ->
    if expected.length > 0
      console.log "debug> " + expected[0].input
      child.stdin.write expected[0].input + "\n"
      unless expected[0].lines
        callback = expected[0].callback
        expected.shift()
        callback and callback()
    else
      quit()
    return
  expected.push
    input: input
    lines: output
    callback: next

  return
process.env.NODE_DEBUGGER_TIMEOUT = 2000
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
port = common.PORT + 1337
child = undefined
buffer = ""
expected = []
quit = undefined
handshakeLines = [
  /listening on port \d+/
  /connecting.* ok/
]
initialBreakLines = [
  /break in .*:1/
  /1/
  /2/
  /3/
]
initialLines = handshakeLines.concat(initialBreakLines)

# Process initial lines
addTest null, initialLines
exports.startDebugger = startDebugger
exports.addTest = addTest
exports.initialLines = initialLines
exports.handshakeLines = handshakeLines
exports.initialBreakLines = initialBreakLines
