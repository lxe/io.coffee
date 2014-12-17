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
do_not_call = ->
  throw new Error("This function should not have been called.")return
common = require("../common")
assert = require("assert")
net = require("net")
expected_bad_connections = 1
actual_bad_connections = 0
host = "********"
host += host
host += host
host += host
host += host
host += host
socket = net.connect(42, host, do_not_call)
socket.on "error", (err) ->
  assert.equal err.code, "ENOTFOUND"
  actual_bad_connections++
  return

socket.on "lookup", (err, ip, type) ->
  assert err instanceof Error
  assert.equal err.code, "ENOTFOUND"
  assert.equal ip, `undefined`
  assert.equal type, `undefined`
  return

process.on "exit", ->
  assert.equal actual_bad_connections, expected_bad_connections
  return

