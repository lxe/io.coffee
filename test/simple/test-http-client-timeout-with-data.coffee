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
ntimeouts = 0
nchunks = 0
process.on "exit", ->
  assert.equal ntimeouts, 1
  assert.equal nchunks, 2
  return

options =
  method: "GET"
  port: common.PORT
  host: "127.0.0.1"
  path: "/"

server = http.createServer((req, res) ->
  res.writeHead 200,
    "Content-Length": "2"

  res.write "*"
  setTimeout (->
    res.end "*"
    return
  ), 100
  return
)
server.listen options.port, options.host, ->
  onresponse = (res) ->
    req.setTimeout 50, ->
      assert.equal nchunks, 1 # should have received the first chunk by now
      ntimeouts++
      return

    res.on "data", (data) ->
      assert.equal "" + data, "*"
      nchunks++
      return

    res.on "end", ->
      assert.equal nchunks, 2
      server.close()
      return

    return
  req = http.request(options, onresponse)
  req.end()
  return

