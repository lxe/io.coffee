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
pingPongTest = (port, host) ->
  N = 1000
  count = 0
  sentPongs = 0
  sent_final_ping = false
  server = net.createServer(
    allowHalfOpen: true
  , (socket) ->
    console.log "connection: " + socket.remoteAddress
    assert.equal server, socket.server
    assert.equal 1, server.connections
    socket.setNoDelay()
    socket.timeout = 0
    socket.setEncoding "utf8"
    socket.on "data", (data) ->
      
      # Since we never queue data (we're always waiting for the PING
      # before sending a pong) the writeQueueSize should always be less
      # than one message.
      assert.ok 0 <= socket.bufferSize and socket.bufferSize <= 4
      console.log "server got: " + data
      assert.equal true, socket.writable
      assert.equal true, socket.readable
      assert.equal true, count <= N
      if /PING/.exec(data)
        socket.write "PONG", ->
          sentPongs++
          console.error "sent PONG"
          return

      return

    socket.on "end", ->
      console.error socket
      assert.equal true, socket.allowHalfOpen
      assert.equal true, socket.writable # because allowHalfOpen
      assert.equal false, socket.readable
      socket.end()
      return

    socket.on "error", (e) ->
      throw ereturn

    socket.on "close", ->
      console.log "server socket.endd"
      assert.equal false, socket.writable
      assert.equal false, socket.readable
      socket.server.close()
      return

    return
  )
  server.listen port, host, ->
    console.log "server listening on " + port + " " + host
    client = net.createConnection(port, host)
    client.setEncoding "ascii"
    client.on "connect", ->
      assert.equal true, client.readable
      assert.equal true, client.writable
      client.write "PING"
      return

    client.on "data", (data) ->
      console.log "client got: " + data
      assert.equal "PONG", data
      count += 1
      if sent_final_ping
        assert.equal false, client.writable
        assert.equal true, client.readable
        return
      else
        assert.equal true, client.writable
        assert.equal true, client.readable
      if count < N
        client.write "PING"
      else
        sent_final_ping = true
        client.write "PING"
        client.end()
      return

    client.on "close", ->
      console.log "client.end"
      assert.equal N + 1, count
      assert.equal N + 1, sentPongs
      assert.equal true, sent_final_ping
      tests_run += 1
      return

    client.on "error", (e) ->
      throw ereturn

    return

  return
common = require("../common")
assert = require("assert")
net = require("net")
tests_run = 0

# All are run at once, so run on different ports 
console.log common.PIPE
pingPongTest common.PIPE
pingPongTest common.PORT
pingPongTest common.PORT + 1, "localhost"
pingPongTest common.PORT + 2, "::1"  if common.hasIPv6
process.on "exit", ->
  if common.hasIPv6
    assert.equal 4, tests_run
  else
    assert.equal 3, tests_run
  console.log "done"
  return

