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
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
common = require("../common")
assert = require("assert")
fs = require("fs")
net = require("net")
http = require("http")
https = require("https")
proxyPort = common.PORT + 1
gotRequest = false
key = fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
cert = fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")
options =
  key: key
  cert: cert

server = https.createServer(options, (req, res) ->
  console.log "SERVER: got request"
  res.writeHead 200,
    "content-type": "text/plain"

  console.log "SERVER: sending response"
  res.end "hello world\n"
  return
)
proxy = net.createServer((clientSocket) ->
  console.log "PROXY: got a client connection"
  serverSocket = null
  clientSocket.on "data", (chunk) ->
    unless serverSocket
      
      # Verify the CONNECT request
      assert.equal "CONNECT localhost:" + common.PORT + " HTTP/1.1\r\n" + "Proxy-Connections: keep-alive\r\n" + "Host: localhost:" + proxyPort + "\r\n\r\n", chunk
      console.log "PROXY: got CONNECT request"
      console.log "PROXY: creating a tunnel"
      
      # create the tunnel
      serverSocket = net.connect(common.PORT, ->
        console.log "PROXY: replying to client CONNECT request"
        
        # Send the response
        clientSocket.write "HTTP/1.1 200 OK\r\nProxy-Connections: keep" + "-alive\r\nConnections: keep-alive\r\nVia: " + "localhost:" + proxyPort + "\r\n\r\n"
        return
      )
      serverSocket.on "data", (chunk) ->
        clientSocket.write chunk
        return

      serverSocket.on "end", ->
        clientSocket.destroy()
        return

    else
      serverSocket.write chunk
    return

  clientSocket.on "end", ->
    serverSocket.destroy()
    return

  return
)
server.listen common.PORT
proxy.listen proxyPort, ->
  # for v0.6
  # for v0.6
  # for v0.6
  # for v0.7 or later
  onResponse = (res) ->
    
    # Very hacky. This is necessary to avoid http-parser leaks.
    res.upgrade = true
    return
  onUpgrade = (res, socket, head) ->
    
    # Hacky.
    process.nextTick ->
      onConnect res, socket, head
      return

    return
  onConnect = (res, socket, header) ->
    assert.equal 200, res.statusCode
    console.log "CLIENT: got CONNECT response"
    
    # detach the socket
    socket.removeAllListeners "data"
    socket.removeAllListeners "close"
    socket.removeAllListeners "error"
    socket.removeAllListeners "drain"
    socket.removeAllListeners "end"
    socket.ondata = null
    socket.onend = null
    socket.ondrain = null
    console.log "CLIENT: Making HTTPS request"
    # reuse the socket
    
    # We're ok with getting ECONNRESET in this test, but it's
    # timing-dependent, and thus unreliable. Any other errors
    # are just failures, though.
    https.get(
      path: "/foo"
      key: key
      cert: cert
      socket: socket
      agent: false
      rejectUnauthorized: false
    , (res) ->
      assert.equal 200, res.statusCode
      res.on "data", (chunk) ->
        assert.equal "hello world\n", chunk
        console.log "CLIENT: got HTTPS response"
        gotRequest = true
        return

      res.on "end", ->
        proxy.close()
        server.close()
        return

      return
    ).on("error", (er) ->
      throw er  if er.code isnt "ECONNRESET"
      return
    ).end()
    return
  console.log "CLIENT: Making CONNECT request"
  req = http.request(
    port: proxyPort
    method: "CONNECT"
    path: "localhost:" + common.PORT
    headers:
      "Proxy-Connections": "keep-alive"
  )
  req.useChunkedEncodingByDefault = false
  req.on "response", onResponse
  req.on "upgrade", onUpgrade
  req.on "connect", onConnect
  req.end()
  return

process.on "exit", ->
  assert.ok gotRequest
  return

