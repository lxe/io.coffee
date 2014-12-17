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
  callbacks = 0
  N = 500
  count = 0
  sent_final_ping = false
  server = dgram.createSocket("udp4", (msg, rinfo) ->
    console.log "server got: " + msg + " from " + rinfo.address + ":" + rinfo.port  if debug
    if /PING/.exec(msg)
      buf = new Buffer(4)
      buf.write "PONG"
      server.send buf, 0, buf.length, rinfo.port, rinfo.address, (err, sent) ->
        callbacks++
        return

    return
  )
  server.on "error", (e) ->
    throw ereturn

  server.on "listening", ->
    console.log "server listening on " + port + " " + host
    buf = new Buffer("PING")
    client = dgram.createSocket("udp4")
    client.on "message", (msg, rinfo) ->
      console.log "client got: " + msg + " from " + rinfo.address + ":" + rinfo.port  if debug
      assert.equal "PONG", msg.toString("ascii")
      count += 1
      if count < N
        client.send buf, 0, buf.length, port, "localhost"
      else
        sent_final_ping = true
        client.send buf, 0, buf.length, port, "localhost", ->
          client.close()
          return

      return

    client.on "close", ->
      console.log "client has closed, closing server"
      assert.equal N, count
      tests_run += 1
      server.close()
      assert.equal N - 1, callbacks
      return

    client.on "error", (e) ->
      throw ereturn

    console.log "Client sending to " + port + ", localhost " + buf
    client.send buf, 0, buf.length, port, "localhost", (err, bytes) ->
      throw err  if err
      console.log "Client sent " + bytes + " bytes"
      return

    count += 1
    return

  server.bind port, host
  return
common = require("../common")
assert = require("assert")
Buffer = require("buffer").Buffer
dgram = require("dgram")
debug = false
tests_run = 0

# All are run at once, so run on different ports
pingPongTest common.PORT + 0, "localhost"
pingPongTest common.PORT + 1, "localhost"
pingPongTest common.PORT + 2

#pingPongTest('/tmp/pingpong.sock');
process.on "exit", ->
  assert.equal 3, tests_run
  console.log "done"
  return

