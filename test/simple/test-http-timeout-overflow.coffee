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
port = common.PORT
serverRequests = 0
clientRequests = 0
server = http.createServer((req, res) ->
  serverRequests++
  res.writeHead 200,
    "Content-Type": "text/plain"

  res.end "OK"
  return
)
server.listen port, ->
  callback = ->
  req = http.request(
    port: port
    path: "/"
    agent: false
  , (res) ->
    req.clearTimeout callback
    res.on "end", ->
      clientRequests++
      server.close()
      return

    res.resume()
    return
  )
  
  # Overflow signed int32
  req.setTimeout 0xffffffff, callback
  req.end()
  return

process.once "exit", ->
  assert.equal clientRequests, 1
  assert.equal serverRequests, 1
  return

