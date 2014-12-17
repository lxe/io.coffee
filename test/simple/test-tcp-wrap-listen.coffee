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
TCP = process.binding("tcp_wrap").TCP
WriteWrap = process.binding("stream_wrap").WriteWrap
server = new TCP()
r = server.bind("0.0.0.0", common.PORT)
assert.equal 0, r
server.listen 128
slice = undefined
sliceCount = 0
eofCount = 0
writeCount = 0
recvCount = 0
server.onconnection = (err, client) ->
  maybeCloseClient = ->
    if client.pendingWrites.length is 0 and client.gotEOF
      console.log "close client"
      client.close()
    return
  assert.equal 0, client.writeQueueSize
  console.log "got connection"
  client.readStart()
  client.pendingWrites = []
  client.onread = (err, buffer) ->
    if buffer
      
      # 11 bytes should flush
      done = (status, client_, req_) ->
        assert.equal req, client.pendingWrites.shift()
        
        # Check parameters.
        assert.equal 0, status
        assert.equal client, client_
        assert.equal req, req_
        console.log "client.writeQueueSize: " + client.writeQueueSize
        assert.equal 0, client.writeQueueSize
        writeCount++
        console.log "write " + writeCount
        maybeCloseClient()
        return
      assert.ok buffer.length > 0
      assert.equal 0, client.writeQueueSize
      req = new WriteWrap()
      req.async = false
      err = client.writeBuffer(req, buffer)
      assert.equal err, 0
      client.pendingWrites.push req
      console.log "client.writeQueueSize: " + client.writeQueueSize
      assert.equal 0, client.writeQueueSize
      if req.async
        req.oncomplete = done
      else
        process.nextTick done.bind(null, 0, client, req)
      sliceCount++
    else
      console.log "eof"
      client.gotEOF = true
      server.close()
      eofCount++
      maybeCloseClient()
    return

  return

net = require("net")
c = net.createConnection(common.PORT)
c.on "connect", ->
  c.end "hello world"
  return

c.setEncoding "utf8"
c.on "data", (d) ->
  assert.equal "hello world", d
  recvCount++
  return

c.on "close", ->
  console.error "client closed"
  return

process.on "exit", ->
  assert.equal 1, sliceCount
  assert.equal 1, eofCount
  assert.equal 1, writeCount
  assert.equal 1, recvCount
  return

