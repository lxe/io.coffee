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

# This example sets a timeout then immediately attempts to disable the timeout
# https://github.com/joyent/node/pull/2245
common = require("../common")
net = require("net")
assert = require("assert")
T = 100
server = net.createServer((c) ->
  c.write "hello"
  return
)
server.listen common.PORT
killers = [
  0
  Infinity
  NaN
]
left = killers.length
killers.forEach (killer) ->
  socket = net.createConnection(common.PORT, "localhost")
  socket.setTimeout T, ->
    socket.destroy()
    server.close()  if --left is 0
    assert.ok killer isnt 0
    clearTimeout timeout
    return

  socket.setTimeout killer
  timeout = setTimeout(->
    socket.destroy()
    server.close()  if --left is 0
    assert.ok killer is 0
    return
  , T * 2)
  return

