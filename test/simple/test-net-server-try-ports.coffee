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

# This tests binds to one port, then attempts to start a server on that
# port. It should be EADDRINUSE but be able to then bind to another port.
common = require("../common")
assert = require("assert")
net = require("net")
connections = 0
server1listening = false
server2listening = false
server1 = net.Server((socket) ->
  connections++
  socket.destroy()
  return
)
server2 = net.Server((socket) ->
  connections++
  socket.destroy()
  return
)
server2errors = 0
server2.on "error", ->
  server2errors++
  console.error "server2 error"
  return

server1.listen common.PORT, ->
  console.error "server1 listening"
  server1listening = true
  
  # This should make server2 emit EADDRINUSE
  server2.listen common.PORT
  
  # Wait a bit, now try again.
  # TODO, the listen callback should report if there was an error.
  # Then we could avoid this very unlikely but potential race condition
  # here.
  setTimeout (->
    server2.listen common.PORT + 1, ->
      console.error "server2 listening"
      server2listening = true
      server1.close()
      server2.close()
      return

    return
  ), 100
  return

process.on "exit", ->
  assert.equal 1, server2errors
  assert.ok server2listening
  assert.ok server1listening
  return

