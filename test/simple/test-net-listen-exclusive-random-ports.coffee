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
noop = ->
common = require("../common")
assert = require("assert")
cluster = require("cluster")
net = require("net")
if cluster.isMaster
  worker1 = cluster.fork()
  worker1.on "message", (port1) ->
    assert.equal port1, port1 | 0, "first worker could not listen"
    worker2 = cluster.fork()
    worker2.on "message", (port2) ->
      assert.equal port2, port2 | 0, "second worker could not listen"
      assert.notEqual port1, port2, "ports should not be equal"
      worker1.kill()
      worker2.kill()
      return

    return

else
  server = net.createServer(noop)
  server.on "error", (err) ->
    process.send err.code
    return

  server.listen
    port: 0
    exclusive: true
  , ->
    process.send server.address().port
    return

