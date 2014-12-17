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
http = require("http")
assert = require("assert")
server = http.Server((req, res) ->
  console.log "Server accepted request."
  res.writeHead 200
  res.write "Part of my res."
  res.destroy()
  return
)
responseClose = false
server.listen common.PORT, ->
  client = http.get(
    port: common.PORT
    headers:
      connection: "keep-alive"
  , (res) ->
    server.close()
    console.log "Got res: " + res.statusCode
    console.dir res.headers
    res.on "data", (chunk) ->
      console.log "Read " + chunk.length + " bytes"
      console.log " chunk=%j", chunk.toString()
      return

    res.on "end", ->
      console.log "Response ended."
      return

    res.on "aborted", ->
      console.log "Response aborted."
      return

    res.socket.on "close", ->
      console.log "socket closed, but not res"
      return

    
    # it would be nice if this worked:
    res.on "close", ->
      console.log "Response aborted"
      responseClose = true
      return

    return
  )
  return

process.on "exit", ->
  assert.ok responseClose
  return

