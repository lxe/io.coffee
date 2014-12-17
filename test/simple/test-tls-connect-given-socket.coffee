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
common = require("../common")
assert = require("assert")
tls = require("tls")
net = require("net")
fs = require("fs")
path = require("path")
serverConnected = 0
clientConnected = 0
options =
  key: fs.readFileSync(path.join(common.fixturesDir, "test_key.pem"))
  cert: fs.readFileSync(path.join(common.fixturesDir, "test_cert.pem"))

server = tls.createServer(options, (socket) ->
  serverConnected++
  socket.end "Hello"
  return
).listen(common.PORT, ->
  establish = (socket) ->
    client = tls.connect(
      rejectUnauthorized: false
      socket: socket
    , ->
      clientConnected++
      data = ""
      client.on "data", (chunk) ->
        data += chunk.toString()
        return

      client.on "end", ->
        assert.equal data, "Hello"
        server.close()  if --waiting is 0
        return

      return
    )
    assert client.readable
    assert client.writable
    return
  waiting = 2
  
  # Already connected socket
  connected = net.connect(common.PORT, ->
    establish connected
    return
  )
  
  # Connecting socket
  connecting = net.connect(common.PORT)
  establish connecting
  return
)
process.on "exit", ->
  assert.equal serverConnected, 2
  assert.equal clientConnected, 2
  return

