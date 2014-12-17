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

# test-cluster-worker-exit.js
# verifies that, when a child process exits (by calling `process.exit(code)`)
# - the parent receives the proper events in the proper order, no duplicates
# - the exitCode and signalCode are correct in the 'exit' event
# - the worker.suicide flag, and worker.state are correct
# - the worker process actually goes away

# start worker

# the worker is up and running...

# Check cluster events

# Check worker events and properties

# Check that the worker died

# some helper functions ...
checkResults = (expected_results, results) ->
  for k of expected_results
    actual = results[k]
    expected = expected_results[k]
    if typeof expected is "function"
      expected r[k]
    else
      msg = (expected[1] or "") + (" [expected: " + expected[0] + " / actual: " + actual + "]")
      if expected and expected.length
        assert.equal actual, expected[0], msg
      else
        assert.equal actual, expected, msg
  return
alive = (pid) ->
  try
    process.kill pid, "SIGCONT"
    return true
  catch e
    return false
  return
common = require("../common")
assert = require("assert")
cluster = require("cluster")
EXIT_CODE = 42
if cluster.isWorker
  http = require("http")
  server = http.Server(->
  )
  server.once "listening", ->
    process.exit EXIT_CODE
    return

  server.listen common.PORT, "127.0.0.1"
else if cluster.isMaster
  expected_results =
    cluster_emitDisconnect: [
      1
      "the cluster did not emit 'disconnect'"
    ]
    cluster_emitExit: [
      1
      "the cluster did not emit 'exit'"
    ]
    cluster_exitCode: [
      EXIT_CODE
      "the cluster exited w/ incorrect exitCode"
    ]
    cluster_signalCode: [
      null
      "the cluster exited w/ incorrect signalCode"
    ]
    worker_emitDisconnect: [
      1
      "the worker did not emit 'disconnect'"
    ]
    worker_emitExit: [
      1
      "the worker did not emit 'exit'"
    ]
    worker_state: [
      "disconnected"
      "the worker state is incorrect"
    ]
    worker_suicideMode: [
      false
      "the worker.suicide flag is incorrect"
    ]
    worker_died: [
      true
      "the worker is still running"
    ]
    worker_exitCode: [
      EXIT_CODE
      "the worker exited w/ incorrect exitCode"
    ]
    worker_signalCode: [
      null
      "the worker exited w/ incorrect signalCode"
    ]

  results =
    cluster_emitDisconnect: 0
    cluster_emitExit: 0
    worker_emitDisconnect: 0
    worker_emitExit: 0

  worker = cluster.fork()
  worker.once "listening", ->

  cluster.on "disconnect", ->
    results.cluster_emitDisconnect += 1
    return

  cluster.on "exit", (worker) ->
    results.cluster_exitCode = worker.process.exitCode
    results.cluster_signalCode = worker.process.signalCode
    results.cluster_emitExit += 1
    assert.ok results.cluster_emitDisconnect, "cluster: 'exit' event before 'disconnect' event"
    return

  worker.on "disconnect", ->
    results.worker_emitDisconnect += 1
    results.worker_suicideMode = worker.suicide
    results.worker_state = worker.state
    return

  worker.once "exit", (exitCode, signalCode) ->
    results.worker_exitCode = exitCode
    results.worker_signalCode = signalCode
    results.worker_emitExit += 1
    results.worker_died = not alive(worker.process.pid)
    assert.ok results.worker_emitDisconnect, "worker: 'exit' event before 'disconnect' event"
    process.nextTick ->
      finish_test()
      return

    return

  finish_test = ->
    try
      checkResults expected_results, results
    catch exc
      console.error "FAIL: " + exc.message
      console.trace exc  unless exc.name is "AssertionError"
      process.exit 1
      return
    process.exit 0
    return
