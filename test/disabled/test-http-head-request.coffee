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
assert = require("assert")
http = require("http")
util = require("util")
body = "hello world"
server = http.createServer((req, res) ->
  res.writeHeader 200,
    "Content-Length": body.length.toString()
    "Content-Type": "text/plain"

  console.log "method: " + req.method
  res.write body  unless req.method is "HEAD"
  res.end()
  return
)
server.listen common.PORT
gotEnd = false
server.on "listening", ->
  request = http.request(
    port: common.PORT
    method: "HEAD"
    path: "/"
  , (response) ->
    console.log "got response"
    response.on "data", ->
      process.exit 2
      return

    response.on "end", ->
      process.exit 0
      return

    return
  )
  request.end()
  return


#give a bit of time for the server to respond before we check it
setTimeout (->
  process.exit 1
  return
), 2000
