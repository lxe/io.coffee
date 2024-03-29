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
doRequest = (i) ->
  req = http.get(
    port: common.PORT
    path: "/request" + i
  , (res) ->
    common.debug "Client got GET response"
    data = ""
    res.setEncoding "utf8"
    res.on "data", (chunk) ->
      data += chunk
      return

    res.on "end", ->
      assert.equal data, "/request" + i
      ++clientResponses
      server.close()  if clientResponses is 2
      return

    return
  )
  return
common = require("../common")
assert = require("assert")
http = require("http")
serverConnected = false
serverRequests = 0
clientResponses = 0
server = http.createServer((req, res) ->
  common.debug "Server got GET request"
  req.resume()
  ++serverRequests
  res.writeHead 200
  res.write ""
  setTimeout (->
    res.end req.url
    return
  ), 50
  return
)
server.on "connect", (req, socket, firstBodyChunk) ->
  common.debug "Server got CONNECT request"
  serverConnected = true
  socket.write "HTTP/1.1 200 Connection established\r\n\r\n"
  socket.resume()
  socket.on "end", ->
    socket.end()
    return

  return

server.listen common.PORT, ->
  req = http.request(
    port: common.PORT
    method: "CONNECT"
    path: "google.com:80"
  )
  req.on "connect", (res, socket, firstBodyChunk) ->
    common.debug "Client got CONNECT response"
    socket.end()
    socket.on "end", ->
      doRequest 0
      doRequest 1
      return

    socket.resume()
    return

  req.end()
  return

process.on "exit", ->
  assert serverConnected
  assert.equal serverRequests, 2
  assert.equal clientResponses, 2
  return

