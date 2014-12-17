cluster = require("cluster")
assert = require("assert")
util = require("util")
if cluster.isMaster
  worker = cluster.fork()
  assert.ok worker.isConnected(), "isConnected() should return true as soon as the worker has " + "been created."
  worker.on "disconnect", ->
    assert.ok not worker.isConnected(), "After a disconnect event has been emitted, " + "isConncted should return false"
    return

  worker.on "message", (msg) ->
    worker.disconnect()  if msg is "readyToDisconnect"
    return

else
  assert.ok cluster.worker.isConnected(), "isConnected() should return true from within a worker at all " + "times."
  cluster.worker.process.on "disconnect", ->
    assert.ok not cluster.worker.isConnected(), "isConnected() should return false from within a worker " + "after its underlying process has been disconnected from " + "the master"
    return

  process.send "readyToDisconnect"
