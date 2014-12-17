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

#
# * 5MB of random buffer.
# 
startClient = ->
  listenCount++
  return  if listenCount < 2
  console.log "Making request"
  req = http.request(
    port: common.PORT
    method: "GET"
    path: "/"
    headers:
      "content-length": buffer.length
  , (res) ->
    console.log "Got response"
    res.setEncoding "utf8"
    res.on "data", (string) ->
      assert.equal "thanks", string
      gotThanks = true
      return

    return
  )
  req.write buffer
  req.end()
  console.error "ended request", req
  return
common = require("../common")
assert = require("assert")
http = require("http")
net = require("net")
webPort = common.PORT
tcpPort = webPort + 1
listenCount = 0
gotThanks = false
tcpLengthSeen = 0
bufferSize = 5 * 1024 * 1024
buffer = Buffer(bufferSize)
i = 0

while i < buffer.length
  buffer[i] = parseInt(Math.random() * 10000) % 256
  i++
web = http.Server((req, res) ->
  web.close()
  console.log req.headers
  socket = net.Stream()
  socket.connect tcpPort
  socket.on "connect", ->
    console.log "socket connected"
    return

  req.pipe socket
  req.on "end", ->
    res.writeHead 200
    res.write "thanks"
    res.end()
    console.log "response with 'thanks'"
    return

  req.connection.on "error", (e) ->
    console.log "http server-side error: " + e.message
    process.exit 1
    return

  return
)
web.listen webPort, startClient
tcp = net.Server((s) ->
  tcp.close()
  console.log "tcp server connection"
  i = 0
  s.on "data", (d) ->
    process.stdout.write "."
    tcpLengthSeen += d.length
    j = 0

    while j < d.length
      assert.equal buffer[i], d[j]
      i++
      j++
    return

  s.on "end", ->
    console.log "tcp socket disconnect"
    s.end()
    return

  s.on "error", (e) ->
    console.log "tcp server-side error: " + e.message
    process.exit 1
    return

  return
)
tcp.listen tcpPort, startClient
process.on "exit", ->
  assert.ok gotThanks
  assert.equal bufferSize, tcpLengthSeen
  return

