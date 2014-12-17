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

# Cluster setup
if cluster.isWorker
  http = require("http")
  http.Server(->
  ).listen common.PORT, "127.0.0.1"
else if process.argv[2] is "cluster"
  totalWorkers = 2
  
  # Send PID to testcase process
  forkNum = 0
  cluster.on "fork", forkEvent = (worker) ->
    
    # Send PID
    process.send
      cmd: "worker"
      workerPID: worker.process.pid

    
    # Stop listening when done
    cluster.removeListener "fork", forkEvent  if ++forkNum is totalWorkers
    return

  
  # Throw accidently error when all workers are listening
  listeningNum = 0
  cluster.on "listening", listeningEvent = ->
    
    # When all workers are listening
    if ++listeningNum is totalWorkers
      
      # Stop listening
      cluster.removeListener "listening", listeningEvent
      
      # throw accidently error
      process.nextTick ->
        console.error "about to throw"
        throw new Error("accidently error")return

    return

  
  # Startup a basic cluster
  cluster.fork()
  cluster.fork()
else
  
  # This is the testcase
  fork = require("child_process").fork
  isAlive = (pid) ->
    try
      
      #this will throw an error if the process is dead
      process.kill pid, 0
      return true
    catch e
      return false
    return

  existMaster = false
  existWorker = false
  
  # List all workers
  workers = []
  
  # Spawn a cluster process
  master = fork(process.argv[1], ["cluster"],
    silent: true
  )
  
  # Handle messages from the cluster
  master.on "message", (data) ->
    
    # Add worker pid to list and progress tracker
    workers.push data.workerPID  if data.cmd is "worker"
    return

  
  # When cluster is dead
  master.on "exit", (code) ->
    
    # Check that the cluster died accidently
    
    # Give the workers time to shut down
    checkWorkers = ->
      
      # When master is dead all workers should be dead to
      alive = false
      workers.forEach (pid) ->
        alive = true  if isAlive(pid)
        return

      
      # If a worker was alive this did not act as expected
      existWorker = not alive
      return
    existMaster = !!code
    setTimeout checkWorkers, 200
    return

  process.once "exit", ->
    m = "The master did not die after an error was throwed"
    assert.ok existMaster, m
    m = "The workers did not die after an error in the master"
    assert.ok existWorker, m
    return

