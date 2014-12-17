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
net = require("net")
if cluster.isWorker
  
  # Create a tcp server. This will be used as cluster-shared-server and as an
  # alternative IPC channel.
  maybeReply = ->
    return  if not socket or not message
    
    # Tell master using TCP socket that a message is received.
    socket.write JSON.stringify(
      code: "received message"
      echo: message
    )
    return
  server = net.Server()
  socket = undefined
  message = undefined
  server.on "connection", (socket_) ->
    socket = socket_
    maybeReply()
    
    # Send a message back over the IPC channel.
    process.send "message from worker"
    return

  process.on "message", (message_) ->
    message = message_
    maybeReply()
    return

  server.listen common.PORT, "127.0.0.1"
else if cluster.isMaster
  checks =
    master:
      receive: false
      correct: false

    worker:
      receive: false
      correct: false

  client = undefined
  check = (type, result) ->
    checks[type].receive = true
    checks[type].correct = result
    console.error "check", checks
    missing = false
    forEach checks, (type) ->
      missing = true  if type.receive is false
      return

    if missing is false
      console.error "end client"
      client.end()
    return

  
  # Spawn worker
  worker = cluster.fork()
  
  # When a IPC message is received form the worker
  worker.on "message", (message) ->
    check "master", message is "message from worker"
    return

  
  # When a TCP connection is made with the worker connect to it
  worker.on "listening", ->
    client = net.connect(common.PORT, ->
      
      # Send message to worker.
      worker.send "message from master"
      return
    )
    client.on "data", (data) ->
      
      # All data is JSON
      data = JSON.parse(data.toString())
      if data.code is "received message"
        check "worker", data.echo is "message from master"
      else
        throw new Error("wrong TCP message recived: " + data)
      return

    
    # When the connection ends kill worker and shutdown process
    client.on "end", ->
      worker.kill()
      return

    worker.on "exit", ->
      process.exit 0
      return

    return

  process.once "exit", ->
    forEach checks, (check, type) ->
      assert.ok check.receive, "The " + type + " did not receive any message"
      assert.ok check.correct, "The " + type + " did not get the correct message"
      return

    return

