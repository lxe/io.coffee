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
if cluster.isWorker
  http = require("http")
  http.Server(->
  ).listen common.PORT, "127.0.0.1"
else if cluster.isMaster
  checks =
    cluster:
      emitDisconnect: false
      emitExit: false
      callback: false

    worker:
      emitDisconnect: false
      emitExit: false
      state: false
      suicideMode: false
      died: false

  
  # helper function to check if a process is alive
  alive = (pid) ->
    try
      process.kill pid, 0
      return true
    catch e
      return false
    return

  
  # start worker
  worker = cluster.fork()
  
  # Disconnect worker when it is ready
  worker.once "listening", ->
    worker.disconnect()
    return

  
  # Check cluster events
  cluster.once "disconnect", ->
    checks.cluster.emitDisconnect = true
    return

  cluster.once "exit", ->
    checks.cluster.emitExit = true
    return

  
  # Check worker events and properties
  worker.once "disconnect", ->
    checks.worker.emitDisconnect = true
    checks.worker.suicideMode = worker.suicide
    checks.worker.state = worker.state
    return

  
  # Check that the worker died
  worker.once "exit", ->
    checks.worker.emitExit = true
    checks.worker.died = not alive(worker.process.pid)
    process.nextTick ->
      process.exit 0
      return

    return

  process.once "exit", ->
    w = checks.worker
    c = checks.cluster
    
    # events
    assert.ok w.emitDisconnect, "Disconnect event did not emit"
    assert.ok c.emitDisconnect, "Disconnect event did not emit"
    assert.ok w.emitExit, "Exit event did not emit"
    assert.ok c.emitExit, "Exit event did not emit"
    
    # flags
    assert.equal w.state, "disconnected", "The state property was not set"
    assert.equal w.suicideMode, true, "Suicide mode was not set"
    
    # is process alive
    assert.ok w.died, "The worker did not die"
    return

