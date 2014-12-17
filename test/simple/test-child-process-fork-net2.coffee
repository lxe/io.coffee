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
count = 12
if process.argv[2] is "child"
  needEnd = []
  id = process.argv[3]
  process.on "message", (m, socket) ->
    return  unless socket
    console.error "[%d] got socket", id, m
    
    # will call .end('end') or .write('write');
    socket[m] m
    socket.resume()
    socket.on "data", ->
      console.error "[%d] socket.data", id, m
      return

    socket.on "end", ->
      console.error "[%d] socket.end", id, m
      return

    
    # store the unfinished socket
    needEnd.push socket  if m is "write"
    socket.on "close", (had_error) ->
      console.error "[%d] socket.close", id, had_error, m
      return

    socket.on "finish", ->
      console.error "[%d] socket finished", id, m
      return

    return

  process.on "message", (m) ->
    return  if m isnt "close"
    console.error "[%d] got close message", id
    needEnd.forEach (endMe, i) ->
      console.error "[%d] ending %d/%d", id, i, needEnd.length
      endMe.end "end"
      return

    return

  process.on "disconnect", ->
    console.error "[%d] process disconnect, ending", id
    needEnd.forEach (endMe, i) ->
      console.error "[%d] ending %d/%d", id, i, needEnd.length
      endMe.end "end"
      return

    return

else
  child1 = fork(process.argv[1], [
    "child"
    "1"
  ])
  child2 = fork(process.argv[1], [
    "child"
    "2"
  ])
  child3 = fork(process.argv[1], [
    "child"
    "3"
  ])
  server = net.createServer()
  connected = 0
  closed = 0
  server.on "connection", (socket) ->
    switch connected % 6
      when 0
        child1.send "end", socket,
          track: false

      when 1
        child1.send "write", socket,
          track: true

      when 2
        child2.send "end", socket,
          track: true

      when 3
        child2.send "write", socket,
          track: false

      when 4
        child3.send "end", socket,
          track: false

      when 5
        child3.send "write", socket,
          track: false

    connected += 1
    socket.once "close", ->
      console.log "[m] socket closed, total %d", ++closed
      return

    closeServer()  if connected is count
    return

  disconnected = 0
  server.on "listening", ->
    j = count
    client = undefined
    while j--
      client = net.connect(common.PORT, "127.0.0.1")
      client.on "error", ->
        
        # This can happen if we kill the child too early.
        # The client should still get a close event afterwards.
        console.error "[m] CLIENT: error event"
        return

      client.on "close", ->
        console.error "[m] CLIENT: close event"
        disconnected += 1
        return

      
      # XXX This resume() should be unnecessary.
      # a stream high water mark should be enough to keep
      # consuming the input.
      client.resume()
    return

  closeEmitted = false
  server.on "close", ->
    console.error "[m] server close"
    closeEmitted = true
    console.error "[m] killing child processes"
    child1.kill()
    child2.kill()
    child3.kill()
    return

  server.listen common.PORT, "127.0.0.1"
  timeElasped = 0
  closeServer = ->
    console.error "[m] closeServer"
    startTime = Date.now()
    server.on "close", ->
      console.error "[m] emit(close)"
      timeElasped = Date.now() - startTime
      return

    console.error "[m] calling server.close"
    server.close()
    setTimeout (->
      assert not closeEmitted
      console.error "[m] sending close to children"
      child1.send "close"
      child2.send "close"
      child3.disconnect()
      return
    ), 200
    return

  process.on "exit", ->
    assert.equal disconnected, count
    assert.equal connected, count
    assert.ok closeEmitted
    assert.ok timeElasped >= 190 and timeElasped <= 1000, "timeElasped was not between 190 and 1000 ms"
    return

