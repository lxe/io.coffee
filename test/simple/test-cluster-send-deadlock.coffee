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

# Testing mutual send of handles: from master to worker, and from worker to
# master.
common = require("../common")
assert = require("assert")
cluster = require("cluster")
net = require("net")
if cluster.isMaster
  worker = cluster.fork()
  worker.on "exit", (code, signal) ->
    assert.equal code, 0, "Worker exited with an error code"
    assert not signal, "Worker exited by a signal"
    server.close()
    return

  server = net.createServer((socket) ->
    worker.send "handle", socket
    return
  )
  server.listen common.PORT, ->
    worker.send "listen"
    return

else
  process.on "message", (msg, handle) ->
    if msg is "listen"
      onclose = ->
        cluster.worker.disconnect()  if --waiting is 0
        return
      client1 = net.connect(
        host: "localhost"
        port: common.PORT
      )
      client2 = net.connect(
        host: "localhost"
        port: common.PORT
      )
      waiting = 2
      client1.on "close", onclose
      client2.on "close", onclose
      setTimeout (->
        client1.end()
        client2.end()
        return
      ), 50
    else
      process.send "reply", handle
    return

