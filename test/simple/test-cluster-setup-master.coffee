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
  
  # Just keep the worker alive
  process.send process.argv[2]
else if cluster.isMaster
  checks =
    args: false
    setupEvent: false
    settingsObject: false

  totalWorkers = 2
  
  # Setup master
  cluster.setupMaster
    args: ["custom argument"]
    silent: true

  cluster.once "setup", ->
    checks.setupEvent = true
    settings = cluster.settings
    checks.settingsObject = true  if settings and settings.args and settings.args[0] is "custom argument" and settings.silent is true and settings.exec is process.argv[1]
    return

  correctIn = 0
  cluster.on "online", lisenter = (worker) ->
    worker.once "message", (data) ->
      correctIn += ((if data is "custom argument" then 1 else 0))
      checks.args = true  if correctIn is totalWorkers
      worker.kill()
      return

    
    # All workers are online
    checks.workers = true  if cluster.onlineWorkers is totalWorkers
    return

  
  # Start all workers
  cluster.fork()
  cluster.fork()
  
  # Check all values
  process.once "exit", ->
    assert.ok checks.args, "The arguments was noy send to the worker"
    assert.ok checks.setupEvent, "The setup event was never emitted"
    m = "The settingsObject do not have correct properties"
    assert.ok checks.settingsObject, m
    return

