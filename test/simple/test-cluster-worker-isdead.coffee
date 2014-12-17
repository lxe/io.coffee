cluster = require("cluster")
assert = require("assert")
net = require("net")
if cluster.isMaster
  worker = cluster.fork()
  assert.ok not worker.isDead(), "isDead() should return false right after the worker has been " + "created."
  worker.on "exit", ->
    assert.ok not worker.isConnected(), "After an event has been emitted, " + "isDead should return true"
    return

  worker.on "message", (msg) ->
    worker.kill()  if msg is "readyToDie"
    return

else if cluster.isWorker
  assert.ok not cluster.worker.isDead(), "isDead() should return false when called from within a worker"
  process.send "readyToDie"
