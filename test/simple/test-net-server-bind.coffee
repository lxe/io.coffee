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

# With only a callback, server should get a port assigned by the OS
address0 = undefined
server0 = net.createServer((socket) ->
)
server0.listen ->
  address0 = server0.address()
  console.log "address0 %j", address0
  server0.close()
  return


# No callback to listen(), assume we can bind in 100 ms
address1 = undefined
server1 = net.createServer((socket) ->
)
server1.listen common.PORT
setTimeout (->
  address1 = server1.address()
  console.log "address1 %j", address1
  server1.close()
  return
), 100

# Callback to listen()
address2 = undefined
server2 = net.createServer((socket) ->
)
server2.listen common.PORT + 1, ->
  address2 = server2.address()
  console.log "address2 %j", address2
  server2.close()
  return


# Backlog argument
address3 = undefined
server3 = net.createServer((socket) ->
)
server3.listen common.PORT + 2, "0.0.0.0", 127, ->
  address3 = server3.address()
  console.log "address3 %j", address3
  server3.close()
  return


# Backlog argument without host argument
address4 = undefined
server4 = net.createServer((socket) ->
)
server4.listen common.PORT + 3, 127, ->
  address4 = server4.address()
  console.log "address4 %j", address4
  server4.close()
  return

process.on "exit", ->
  assert.ok address0.port > 100
  assert.equal common.PORT, address1.port
  assert.equal common.PORT + 1, address2.port
  assert.equal common.PORT + 2, address3.port
  assert.equal common.PORT + 3, address4.port
  return

