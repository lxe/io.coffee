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
assert = require("assert")
common = require("../common")
fork = require("child_process").fork
net = require("net")

# child
if process.argv[2] is "child"
  
  # Check that the 'disconnect' event is deferred to the next event loop tick.
  disconnect = process.disconnect
  process.disconnect = ->
    
    # If the event is emitted synchronously, we're too late by now.
    
    # The funky function name makes it show up legible in mustCall errors.
    disconnectIsNotAsync = ->
    disconnect.apply this, arguments
    process.once "disconnect", common.mustCall(disconnectIsNotAsync)
    return

  server = net.createServer()
  server.on "connection", (socket) ->
    socket.resume()
    process.on "disconnect", ->
      socket.end (process.connected).toString()
      return

    
    # when the socket is closed, we will close the server
    # allowing the process to self terminate
    socket.on "end", ->
      server.close()
      return

    socket.write "ready"
    return

  
  # when the server is ready tell parent
  server.on "listening", ->
    process.send "ready"
    return

  server.listen common.PORT
else
  
  # testcase
  child = fork(process.argv[1], ["child"])
  childFlag = false
  childSelfTerminate = false
  parentEmit = false
  parentFlag = false
  
  # when calling .disconnect the event should emit
  # and the disconnected flag should be true.
  child.on "disconnect", ->
    parentEmit = true
    parentFlag = child.connected
    return

  
  # the process should also self terminate without using signals
  child.on "exit", ->
    childSelfTerminate = true
    return

  
  # when child is listening
  child.on "message", (msg) ->
    if msg is "ready"
      
      # connect to child using TCP to know if disconnect was emitted
      socket = net.connect(common.PORT)
      socket.on "data", (data) ->
        data = data.toString()
        
        # ready to be disconnected
        if data is "ready"
          child.disconnect()
          assert.throws child.disconnect.bind(child), Error
          return
        
        # disconnect is emitted
        childFlag = (data is "true")
        return

    return

  process.on "exit", ->
    assert.equal childFlag, false
    assert.equal parentFlag, false
    assert.ok childSelfTerminate
    assert.ok parentEmit
    return

