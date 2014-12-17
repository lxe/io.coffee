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

# test-cluster-worker-init.js
# verifies that, when a child process is forked, the cluster.worker
# object can receive messages as expected
common = require("../common")
assert = require("assert")
cluster = require("cluster")
msg = "foo"
if cluster.isMaster
  worker = cluster.fork()
  timer = setTimeout(->
    assert false, "message not received"
    return
  , 5000)
  timer.unref()
  worker.on "message", (message) ->
    assert message, "did not receive expected message"
    worker.disconnect()
    return

  worker.on "online", ->
    worker.send msg
    return

else
  
  # GH #7998
  cluster.worker.on "message", (message) ->
    process.send message is msg
    return

