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
pingPongTest = (port, host, on_complete) ->
  N = 100
  DELAY = 1
  count = 0
  client_ended = false
  server = net.createServer(
    allowHalfOpen: true
  , (socket) ->
    socket.setEncoding "utf8"
    socket.on "data", (data) ->
      console.log data
      assert.equal "PING", data
      assert.equal "open", socket.readyState
      assert.equal true, count <= N
      setTimeout (->
        assert.equal "open", socket.readyState
        socket.write "PONG"
        return
      ), DELAY
      return

    socket.on "timeout", ->
      common.debug "server-side timeout!!"
      assert.equal false, true
      return

    socket.on "end", ->
      console.log "server-side socket EOF"
      assert.equal "writeOnly", socket.readyState
      socket.end()
      return

    socket.on "close", (had_error) ->
      console.log "server-side socket.end"
      assert.equal false, had_error
      assert.equal "closed", socket.readyState
      socket.server.close()
      return

    return
  )
  server.listen port, host, ->
    client = net.createConnection(port, host)
    client.setEncoding "utf8"
    client.on "connect", ->
      assert.equal "open", client.readyState
      client.write "PING"
      return

    client.on "data", (data) ->
      console.log data
      assert.equal "PONG", data
      assert.equal "open", client.readyState
      setTimeout (->
        assert.equal "open", client.readyState
        if count++ < N
          client.write "PING"
        else
          console.log "closing client"
          client.end()
          client_ended = true
        return
      ), DELAY
      return

    client.on "timeout", ->
      common.debug "client-side timeout!!"
      assert.equal false, true
      return

    client.on "close", ->
      console.log "client.end"
      assert.equal N + 1, count
      assert.ok client_ended
      on_complete()  if on_complete
      tests_run += 1
      return

    return

  return
common = require("../common")
assert = require("assert")
net = require("net")
tests_run = 0
pingPongTest common.PORT
process.on "exit", ->
  assert.equal 1, tests_run
  return

