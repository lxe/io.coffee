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

# Testing to send an handle twice to the parent process.
common = require("../common")
assert = require("assert")
cluster = require("cluster")
net = require("net")
workers = toStart: 1
if cluster.isMaster
  i = 0

  while i < workers.toStart
    worker = cluster.fork()
    worker.on "exit", (code, signal) ->
      assert.equal code, 0, "Worker exited with an error code"
      assert not signal, "Worker exited by a signal"
      return

    ++i
else
  server = net.createServer((socket) ->
    process.send "send-handle-1", socket
    process.send "send-handle-2", socket
    return
  )
  server.listen(common.PORT, ->
    client = net.connect(
      host: "localhost"
      port: common.PORT
    )
    client.on "close", ->
      cluster.worker.disconnect()
      return

    setTimeout (->
      client.end()
      return
    ), 50
    return
  ).on "error", (e) ->
    console.error e
    assert false, "server.listen failed"
    cluster.worker.disconnect()
    return

