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
net = require("net")
tcpPort = common.PORT
dataWritten = false
connectHappened = false
tcp = net.Server((s) ->
  tcp.close()
  console.log "tcp server connection"
  buf = ""
  s.on "data", (d) ->
    buf += d
    return

  s.on "end", ->
    console.error "SERVER: end", buf.toString()
    assert.equal buf, "L'État, c'est moi"
    console.log "tcp socket disconnect"
    s.end()
    return

  s.on "error", (e) ->
    console.log "tcp server-side error: " + e.message
    process.exit 1
    return

  return
)
tcp.listen common.PORT, ->
  socket = net.Stream(highWaterMark: 0)
  console.log "Connecting to socket "
  socket.connect tcpPort, ->
    console.log "socket connected"
    connectHappened = true
    return

  console.log "_connecting = " + socket._connecting
  assert.equal "opening", socket.readyState
  
  # Make sure that anything besides a buffer or a string throws.
  [
    null
    true
    false
    `undefined`
    1
    1.0
    1 / 0
    +Infinity
    -Infinity
    []
    {
      {}
    }
  ].forEach (v) ->
    f = ->
      console.error "write", v
      socket.write v
      return
    assert.throws f, TypeError
    return

  
  # Write a string that contains a multi-byte character sequence to test that
  # `bytesWritten` is incremented with the # of bytes, not # of characters.
  a = "L'État, c'est "
  b = "moi"
  
  # We're still connecting at this point so the datagram is first pushed onto
  # the connect queue. Make sure that it's not added to `bytesWritten` again
  # when the actual write happens.
  r = socket.write(a, (er) ->
    console.error "write cb"
    dataWritten = true
    assert.ok connectHappened
    console.error "socket.bytesWritten", socket.bytesWritten
    
    #assert.equal(socket.bytesWritten, Buffer(a + b).length);
    console.error "data written"
    return
  )
  console.error "socket.bytesWritten", socket.bytesWritten
  console.error "write returned", r
  assert.equal socket.bytesWritten, Buffer(a).length
  assert.equal false, r
  socket.end b
  assert.equal "opening", socket.readyState
  return

process.on "exit", ->
  assert.ok connectHappened
  assert.ok dataWritten
  return

