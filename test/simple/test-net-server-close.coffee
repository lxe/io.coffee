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
events = []
sockets = []
process.on "exit", ->
  assert.equal server.connections, 0
  assert.equal events.length, 3
  
  # Expect to see one server event and two client events. The order of the
  # events is undefined because they arrive on the same event loop tick.
  assert.equal events.join(" ").match(/server/g).length, 1
  assert.equal events.join(" ").match(/client/g).length, 2
  return

server = net.createServer((c) ->
  c.on "close", ->
    events.push "client"
    return

  sockets.push c
  if sockets.length is 2
    server.close()
    sockets.forEach (c) ->
      c.destroy()
      return

  return
)
server.on "close", ->
  events.push "server"
  return

server.listen common.PORT, ->
  net.createConnection common.PORT
  net.createConnection common.PORT
  return

