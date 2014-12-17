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
bytesRead = 0
bytesWritten = 0
count = 0
tcp = net.Server((s) ->
  console.log "tcp server connection"
  
  # trigger old mode.
  s.resume()
  s.on "end", ->
    bytesRead += s.bytesRead
    console.log "tcp socket disconnect #" + count
    return

  return
)
tcp.listen common.PORT, doTest = ->
  console.error "listening"
  socket = net.createConnection(tcpPort)
  socket.on "connect", ->
    count++
    console.error "CLIENT connect #%d", count
    socket.write "foo", ->
      console.error "CLIENT: write cb"
      socket.end "bar"
      return

    return

  socket.on "finish", ->
    bytesWritten += socket.bytesWritten
    console.error "CLIENT end event #%d", count
    return

  socket.on "close", ->
    console.error "CLIENT close event #%d", count
    console.log "Bytes read: " + bytesRead
    console.log "Bytes written: " + bytesWritten
    if count < 2
      console.error "RECONNECTING"
      socket.connect tcpPort
    else
      tcp.close()
    return

  return

process.on "exit", ->
  assert.equal bytesRead, 12
  assert.equal bytesWritten, 12
  return

