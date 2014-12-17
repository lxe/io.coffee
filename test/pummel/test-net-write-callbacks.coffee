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
makeCallback = (c) ->
  called = false
  ->
    throw new Error("called callback #" + c + " more than once")  if called
    called = true
    throw new Error("callbacks out of order. last=" + lastCalled + " current=" + c)  if c < lastCalled
    lastCalled = c
    cbcount++
    return
common = require("../common")
net = require("net")
assert = require("assert")
cbcount = 0
N = 500000
server = net.Server((socket) ->
  socket.on "data", (d) ->
    console.error "got %d bytes", d.length
    return

  socket.on "end", ->
    console.error "end"
    socket.destroy()
    server.close()
    return

  return
)
lastCalled = -1
server.listen common.PORT, ->
  client = net.createConnection(common.PORT)
  client.on "connect", ->
    i = 0

    while i < N
      client.write "hello world", makeCallback(i)
      i++
    client.end()
    return

  return

process.on "exit", ->
  assert.equal N, cbcount
  return

