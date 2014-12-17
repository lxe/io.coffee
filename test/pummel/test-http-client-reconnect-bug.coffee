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
util = require("util")
http = require("http")
errorCount = 0
eofCount = 0
server = net.createServer((socket) ->
  socket.end()
  return
)
server.on "listening", ->
  client = http.createClient(common.PORT)
  client.on "error", (err) ->
    
    # We should receive one error
    console.log "ERROR! " + err.message
    errorCount++
    return

  client.on "end", ->
    
    # When we remove the old Client interface this will most likely have to be
    # changed.
    console.log "EOF!"
    eofCount++
    return

  request = client.request("GET", "/",
    host: "localhost"
  )
  request.end()
  request.on "response", (response) ->
    console.log "STATUS: " + response.statusCode
    return

  return

server.listen common.PORT
setTimeout (->
  server.close()
  return
), 500
process.on "exit", ->
  assert.equal 1, errorCount
  assert.equal 1, eofCount
  return

