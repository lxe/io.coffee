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

# progress tracker
ProgressTracker = (missing, callback) ->
  @missing = missing
  @callback = callback
  return
assert = require("assert")
common = require("../common")
fork = require("child_process").fork
net = require("net")
ProgressTracker::done = ->
  @missing -= 1
  @check()
  return

ProgressTracker::check = ->
  @callback()  if @missing is 0
  return

if process.argv[2] is "child"
  serverScope = undefined
  process.on "message", onServer = (msg, server) ->
    return  if msg.what isnt "server"
    process.removeListener "message", onServer
    serverScope = server
    server.on "connection", (socket) ->
      console.log "CHILD: got connection"
      process.send what: "connection"
      socket.destroy()
      return

    
    # start making connection from parent
    console.log "CHILD: server listening"
    process.send what: "listening"
    return

  process.on "message", onClose = (msg) ->
    return  if msg.what isnt "close"
    process.removeListener "message", onClose
    serverScope.on "close", ->
      process.send what: "close"
      return

    serverScope.close()
    return

  process.on "message", onSocket = (msg, socket) ->
    return  if msg.what isnt "socket"
    process.removeListener "message", onSocket
    socket.end "echo"
    console.log "CHILD: got socket"
    return

  process.send what: "ready"
else
  child = fork(process.argv[1], ["child"])
  child.on "exit", ->
    console.log "CHILD: died"
    return

  
  # send net.Server to child and test by connecting
  testServer = (callback) ->
    
    # destroy server execute callback when done
    progress = new ProgressTracker(2, ->
      server.on "close", ->
        console.log "PARENT: server closed"
        child.send what: "close"
        return

      server.close()
      return
    )
    
    # we expect 10 connections and close events
    connections = new ProgressTracker(10, progress.done.bind(progress))
    closed = new ProgressTracker(10, progress.done.bind(progress))
    
    # create server and send it to child
    server = net.createServer()
    server.on "connection", (socket) ->
      console.log "PARENT: got connection"
      socket.destroy()
      connections.done()
      return

    server.on "listening", ->
      console.log "PARENT: server listening"
      child.send
        what: "server"
      , server
      return

    server.listen common.PORT
    
    # handle client messages
    messageHandlers = (msg) ->
      if msg.what is "listening"
        
        # make connections
        socket = undefined
        i = 0

        while i < 10
          socket = net.connect(common.PORT, ->
            console.log "CLIENT: connected"
            return
          )
          socket.on "close", ->
            closed.done()
            console.log "CLIENT: closed"
            return

          i++
      else if msg.what is "connection"
        
        # child got connection
        connections.done()
      else if msg.what is "close"
        child.removeListener "message", messageHandlers
        callback()
      return

    child.on "message", messageHandlers
    return

  
  # send net.Socket to child
  testSocket = (callback) ->
    
    # create a new server and connect to it,
    # but the socket will be handled by the child
    server = net.createServer()
    server.on "connection", (socket) ->
      socket.on "close", ->
        console.log "CLIENT: socket closed"
        return

      child.send
        what: "socket"
      , socket
      return

    server.on "close", ->
      console.log "PARENT: server closed"
      callback()
      return

    
    # don't listen on the same port, because SmartOS sometimes says
    # that the server's fd is closed, but it still cannot listen
    # on the same port again.
    #
    # An isolated test for this would be lovely, but for now, this
    # will have to do.
    server.listen common.PORT + 1, ->
      console.error "testSocket, listening"
      connect = net.connect(common.PORT + 1)
      store = ""
      connect.on "data", (chunk) ->
        store += chunk
        console.log "CLIENT: got data"
        return

      connect.on "close", ->
        console.log "CLIENT: closed"
        assert.equal store, "echo"
        server.close()
        return

      return

    return

  
  # create server and send it to child
  serverSuccess = false
  socketSuccess = false
  child.on "message", onReady = (msg) ->
    return  if msg.what isnt "ready"
    child.removeListener "message", onReady
    testServer ->
      serverSuccess = true
      testSocket ->
        socketSuccess = true
        child.kill()
        return

      return

    return

  process.on "exit", ->
    assert.ok serverSuccess
    assert.ok socketSuccess
    return

