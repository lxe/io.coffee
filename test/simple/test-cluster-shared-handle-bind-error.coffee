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
cluster = require("cluster")
net = require("net")
if cluster.isMaster
  
  # Master opens and binds the socket and shares it with the worker.
  cluster.schedulingPolicy = cluster.SCHED_NONE
  
  # Hog the TCP port so that when the worker tries to bind, it'll fail.
  net.createServer(assert.fail).listen common.PORT, ->
    server = this
    worker = cluster.fork()
    worker.on "exit", common.mustCall((exitCode) ->
      assert.equal exitCode, 0
      server.close()
      return
    )
    return

else
  s = net.createServer(assert.fail)
  s.listen common.PORT, assert.fail.bind(null, "listen should have failed")
  s.on "error", common.mustCall((err) ->
    assert.equal err.code, "EADDRINUSE"
    process.disconnect()
    return
  )
