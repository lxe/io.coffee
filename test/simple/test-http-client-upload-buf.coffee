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
N = 1024
bytesReceived = 0
server_req_complete = false
client_res_complete = false
server = http.createServer((req, res) ->
  assert.equal "POST", req.method
  req.on "data", (chunk) ->
    bytesReceived += chunk.length
    return

  req.on "end", ->
    server_req_complete = true
    console.log "request complete from server"
    res.writeHead 200,
      "Content-Type": "text/plain"

    res.write "hello\n"
    res.end()
    return

  return
)
server.listen common.PORT
server.on "listening", ->
  req = http.request(
    port: common.PORT
    method: "POST"
    path: "/"
  , (res) ->
    res.setEncoding "utf8"
    res.on "data", (chunk) ->
      console.log chunk
      return

    res.on "end", ->
      client_res_complete = true
      server.close()
      return

    return
  )
  req.write new Buffer(N)
  req.end()
  common.error "client finished sending request"
  return

process.on "exit", ->
  assert.equal N, bytesReceived
  assert.equal true, server_req_complete
  assert.equal true, client_res_complete
  return

