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

# This test requires the program 'ab'
runAb = (opts, callback) ->
  command = "ab " + opts + " http://127.0.0.1:" + common.PORT + "/"
  exec command, (err, stdout, stderr) ->
    if err
      if /ab|apr/i.test(stderr)
        console.log "problem spawning ab - skipping test.\n" + stderr
        process.reallyExit 0
      process.exit()
      return
    m = /Document Length:\s*(\d+) bytes/i.exec(stdout)
    documentLength = parseInt(m[1])
    m = /Complete requests:\s*(\d+)/i.exec(stdout)
    completeRequests = parseInt(m[1])
    m = /HTML transferred:\s*(\d+) bytes/i.exec(stdout)
    htmlTransfered = parseInt(m[1])
    assert.equal bodyLength, documentLength
    assert.equal completeRequests * documentLength, htmlTransfered
    runs++
    callback()  if callback
    return

  return
common = require("../common")
assert = require("assert")
http = require("http")
exec = require("child_process").exec
bodyLength = 12345
body = ""
i = 0

while i < bodyLength
  body += "c"
  i++
server = http.createServer((req, res) ->
  res.writeHead 200,
    "Content-Length": bodyLength
    "Content-Type": "text/plain"

  res.end body
  return
)
runs = 0
server.listen common.PORT, ->
  runAb "-c 1 -n 10", ->
    console.log "-c 1 -n 10 okay"
    runAb "-c 1 -n 100", ->
      console.log "-c 1 -n 100 okay"
      runAb "-c 1 -n 1000", ->
        console.log "-c 1 -n 1000 okay"
        server.close()
        return

      return

    return

  return

process.on "exit", ->
  assert.equal 3, runs
  return

