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
net = require("net")
tcpPort = common.PORT
clientConnected = 0
serverConnected = 0
server = net.createServer((socket) ->
  socket.end()
  server.close()  if ++serverConnected is 4
  return
)
server.listen tcpPort, "localhost", ->
  cb = ->
    ++clientConnected
    return
  net.createConnection(tcpPort).on "connect", cb
  net.createConnection(tcpPort, "localhost").on "connect", cb
  net.createConnection tcpPort, cb
  net.createConnection tcpPort, "localhost", cb
  assert.throws ->
    net.createConnection
      port: "invalid!"
    , cb
    return

  return

process.on "exit", ->
  assert.equal clientConnected, 4
  return

