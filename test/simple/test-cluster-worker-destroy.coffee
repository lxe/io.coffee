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

#
# * The goal of this test is to cover the Workers' implementation of
# * Worker.prototype.destroy. Worker.prototype.destroy is called within
# * the worker's context: once when the worker is still connected to the
# * master, and another time when it's not connected to it, so that we cover
# * both code paths.
# 

# Call destroy when worker is disconnected

# Call destroy when worker is not disconnected yet
onProcessExit = ->
  assert.equal workerExited, 2, "When master exits, all workers should have exited too"
  assert.equal workerDisconnected, 2, "When master exits, all workers should have disconnected"
  return
ondisconnect = ->
  ++workerDisconnected
  return
onexit = ->
  ++workerExited
  return
require "../common"
cluster = require("cluster")
assert = require("assert")
worker1 = undefined
worker2 = undefined
workerExited = undefined
workerDisconnected = undefined
if cluster.isMaster
  worker1 = cluster.fork()
  worker2 = cluster.fork()
  workerExited = 0
  workerDisconnected = 0
  [
    worker1
    worker2
  ].forEach (worker) ->
    worker.on "disconnect", ondisconnect
    worker.on "exit", onexit
    return

  process.on "exit", onProcessExit
else
  if cluster.worker.id is 1
    cluster.worker.process.on "disconnect", ->
      cluster.worker.destroy()
      return

    cluster.worker.disconnect()
  else
    cluster.worker.destroy()
