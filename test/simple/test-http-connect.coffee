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
http = require("http")
serverGotConnect = false
clientGotConnect = false
server = http.createServer((req, res) ->
  assert false
  return
)
server.on "connect", (req, socket, firstBodyChunk) ->
  assert.equal req.method, "CONNECT"
  assert.equal req.url, "google.com:443"
  common.debug "Server got CONNECT request"
  serverGotConnect = true
  socket.write "HTTP/1.1 200 Connection established\r\n\r\n"
  data = firstBodyChunk.toString()
  socket.on "data", (buf) ->
    data += buf.toString()
    return

  socket.on "end", ->
    socket.end data
    return

  return

server.listen common.PORT, ->
  req = http.request(
    port: common.PORT
    method: "CONNECT"
    path: "google.com:443"
  , (res) ->
    assert false
    return
  )
  clientRequestClosed = false
  req.on "close", ->
    clientRequestClosed = true
    return

  req.on "connect", (res, socket, firstBodyChunk) ->
    common.debug "Client got CONNECT request"
    clientGotConnect = true
    
    # Make sure this request got removed from the pool.
    name = "localhost:" + common.PORT
    assert not http.globalAgent.sockets.hasOwnProperty(name)
    assert not http.globalAgent.requests.hasOwnProperty(name)
    
    # Make sure this socket has detached.
    assert not socket.ondata
    assert not socket.onend
    assert.equal socket.listeners("connect").length, 0
    assert.equal socket.listeners("data").length, 0
    
    # the stream.Duplex onend listener
    # allow 0 here, so that i can run the same test on streams1 impl
    assert socket.listeners("end").length <= 1
    assert.equal socket.listeners("free").length, 0
    assert.equal socket.listeners("close").length, 0
    assert.equal socket.listeners("error").length, 0
    assert.equal socket.listeners("agentRemove").length, 0
    data = firstBodyChunk.toString()
    socket.on "data", (buf) ->
      data += buf.toString()
      return

    socket.on "end", ->
      assert.equal data, "HeadBody"
      assert clientRequestClosed
      server.close()
      return

    socket.write "Body"
    socket.end()
    return

  
  # It is legal for the client to send some data intended for the server
  # before the "200 Connection established" (or any other success or
  # error code) is received.
  req.write "Head"
  req.end()
  return

process.on "exit", ->
  assert.ok serverGotConnect
  assert.ok clientGotConnect
  return

