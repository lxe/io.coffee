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
  
  # keep the worker alive
  http = require("http")
  http.Server().listen common.PORT, "127.0.0.1"
else if process.argv[2] is "cluster"
  worker = cluster.fork()
  
  # send PID info to testcase process
  process.send pid: worker.process.pid
  
  # terminate the cluster process
  worker.once "listening", ->
    setTimeout (->
      process.exit 0
      return
    ), 1000
    return

else
  
  # This is the testcase
  fork = require("child_process").fork
  
  # is process alive helper
  isAlive = (pid) ->
    try
      
      #this will throw an error if the process is dead
      process.kill pid, 0
      return true
    catch e
      return false
    return

  
  # Spawn a cluster process
  master = fork(process.argv[1], ["cluster"])
  
  # get pid info
  pid = null
  master.once "message", (data) ->
    pid = data.pid
    return

  
  # When master is dead
  alive = true
  master.on "exit", (code) ->
    
    # make sure that the master died by purpose
    assert.equal code, 0
    
    # check worker process status
    setTimeout (->
      alive = isAlive(pid)
      return
    ), 200
    return

  process.once "exit", ->
    
    # cleanup: kill the worker if alive
    process.kill pid  if alive
    assert.equal typeof pid, "number", "did not get worker pid info"
    assert.equal alive, false, "worker was alive after master died"
    return

