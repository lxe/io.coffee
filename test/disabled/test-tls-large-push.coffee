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

# Server sends a large string. Client counts bytes and pauses every few
# seconds. Makes sure that pause and resume work properly.
common = require("../common")
assert = require("assert")
tls = require("tls")
fs = require("fs")
body = ""
process.stdout.write "build body..."
i = 0

while i < 10 * 1024 * 1024
  body += "hello world\n"
  i++
process.stdout.write "done\n"
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent2-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent2-cert.pem")

connections = 0
server = tls.Server(options, (socket) ->
  socket.end body
  connections++
  return
)
recvCount = 0
server.listen common.PORT, ->
  client = tls.connect(common.PORT)
  client.on "data", (d) ->
    process.stdout.write "."
    recvCount += d.length
    return

  
  #
  #    client.pause();
  #    process.nextTick(function () {
  #      client.resume();
  #    });
  #    
  client.on "close", ->
    debugger
    console.log "close"
    server.close()
    return

  return

process.on "exit", ->
  assert.equal 1, connections
  console.log "body.length: %d", body.length
  console.log "  recvCount: %d", recvCount
  assert.equal body.length, recvCount
  return

