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
forEach = (obj, fn) ->
  Object.keys(obj).forEach (name, index) ->
    fn obj[name], name, index
    return

  return
common = require("../common")
assert = require("assert")
cluster = require("cluster")
assert.equal "NODE_UNIQUE_ID" of process.env, false, "NODE_UNIQUE_ID should be removed on startup"
if cluster.isWorker
  http = require("http")
  http.Server(->
  ).listen common.PORT, "127.0.0.1"
else if cluster.isMaster
  checks =
    cluster:
      events:
        fork: false
        online: false
        listening: false
        exit: false

      equal:
        fork: false
        online: false
        listening: false
        exit: false

    worker:
      events:
        online: false
        listening: false
        exit: false

      equal:
        online: false
        listening: false
        exit: false

      states:
        none: false
        online: false
        listening: false
        dead: false

  worker = undefined
  stateNames = Object.keys(checks.worker.states)
  
  #Check events, states, and emit arguments
  forEach checks.cluster.events, (bool, name, index) ->
    
    #Listen on event
    cluster.on name, -> # worker
      
      #Set event
      checks.cluster.events[name] = true
      
      #Check argument
      checks.cluster.equal[name] = worker is arguments[0]
      
      #Check state
      state = stateNames[index]
      checks.worker.states[state] = (state is worker.state)
      return

    return

  
  #Kill worker when listening
  cluster.on "listening", ->
    worker.kill()
    return

  
  #Kill process when worker is killed
  cluster.on "exit", ->
    process.exit 0
    return

  
  #Create worker
  worker = cluster.fork()
  assert.equal worker.id, 1
  assert.ok worker instanceof cluster.Worker, "the worker is not a instance of the Worker constructor"
  
  #Check event
  forEach checks.worker.events, (bool, name, index) ->
    worker.on name, ->
      
      #Set event
      checks.worker.events[name] = true
      
      #Check argument
      checks.worker.equal[name] = (worker is this)
      switch name
        when "exit"
          assert.equal arguments[0], worker.process.exitCode
          assert.equal arguments[1], worker.process.signalCode
          assert.equal arguments.length, 2
        when "listening"
          assert.equal arguments.length, 1
          expect =
            address: "127.0.0.1"
            port: common.PORT
            addressType: 4
            fd: `undefined`

          assert.deepEqual arguments[0], expect
        else
          assert.equal arguments.length, 0

    return

  
  #Check all values
  process.once "exit", ->
    
    #Check cluster events
    forEach checks.cluster.events, (check, name) ->
      assert.ok check, "The cluster event \"" + name + "\" on the cluster " + "object did not fire"
      return

    
    #Check cluster event arguments
    forEach checks.cluster.equal, (check, name) ->
      assert.ok check, "The cluster event \"" + name + "\" did not emit " + "with correct argument"
      return

    
    #Check worker states
    forEach checks.worker.states, (check, name) ->
      assert.ok check, "The worker state \"" + name + "\" was not set to true"
      return

    
    #Check worker events
    forEach checks.worker.events, (check, name) ->
      assert.ok check, "The worker event \"" + name + "\" on the worker object " + "did not fire"
      return

    
    #Check worker event arguments
    forEach checks.worker.equal, (check, name) ->
      assert.ok check, "The worker event \"" + name + "\" did not emit with " + "corrent argument"
      return

    return

