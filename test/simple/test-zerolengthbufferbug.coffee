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

# Serving up a zero-length buffer should work.
common = require("../common")
assert = require("assert")
http = require("http")
server = http.createServer((req, res) ->
  buffer = new Buffer(0)
  
  # FIXME: WTF gjslint want this?
  res.writeHead 200,
    "Content-Type": "text/html"
    "Content-Length": buffer.length

  res.end buffer
  return
)
gotResponse = false
resBodySize = 0
server.listen common.PORT, ->
  http.get
    port: common.PORT
  , (res) ->
    gotResponse = true
    res.on "data", (d) ->
      resBodySize += d.length
      return

    res.on "end", (d) ->
      server.close()
      return

    return

  return

process.on "exit", ->
  assert.ok gotResponse
  assert.equal 0, resBodySize
  return

