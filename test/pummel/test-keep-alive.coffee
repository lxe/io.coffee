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

# This test requires the program 'wrk'
runAb = (opts, callback) ->
  args = [
    "-c"
    opts.concurrent or 100
    "-t"
    opts.threads or 2
    "-d"
    opts.duration or "10s"
  ]
  unless opts.keepalive
    args.push "-H"
    args.push "Connection: close"
  args.push url.format(
    hostname: "127.0.0.1"
    port: common.PORT
    protocol: "http"
  )
  comm = path.join(__dirname, "..", "..", "tools", "wrk", "wrk")
  
  #console.log(comm, args.join(' '));
  child = spawn(comm, args)
  child.stderr.pipe process.stderr
  child.stdout.setEncoding "utf8"
  stdout = undefined
  child.stdout.on "data", (data) ->
    stdout += data
    return

  child.on "close", (code, signal) ->
    if code
      console.error code, signal
      process.exit code
      return
    matches = /Requests\/sec:\s*(\d+)\./i.exec(stdout)
    reqSec = parseInt(matches[1])
    matches = /Keep-Alive requests:\s*(\d+)/i.exec(stdout)
    keepAliveRequests = undefined
    if matches
      keepAliveRequests = parseInt(matches[1])
    else
      keepAliveRequests = 0
    callback reqSec, keepAliveRequests
    return

  return
if process.platform is "win32"
  console.log "skipping this test because there is no wrk on windows"
  process.exit 0
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
http = require("http")
path = require("path")
url = require("url")
body = "hello world\n"
server = http.createServer((req, res) ->
  res.writeHead 200,
    "Content-Length": body.length
    "Content-Type": "text/plain"

  res.write body
  res.end()
  return
)
keepAliveReqSec = 0
normalReqSec = 0
server.listen common.PORT, ->
  runAb
    keepalive: true
  , (reqSec) ->
    keepAliveReqSec = reqSec
    console.log "keep-alive:", keepAliveReqSec, "req/sec"
    runAb
      keepalive: false
    , (reqSec) ->
      normalReqSec = reqSec
      console.log "normal:" + normalReqSec + " req/sec"
      server.close()
      return

    return

  return

process.on "exit", ->
  assert.equal true, normalReqSec > 50
  assert.equal true, keepAliveReqSec > 50
  assert.equal true, normalReqSec < keepAliveReqSec
  return

