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
reqEndCount = 0
server = http.Server((req, res) ->
  res.writeHead 200
  res.end "hello world\n"
  buffer = ""
  req.setEncoding "utf8"
  req.on "data", (s) ->
    buffer += s
    return

  req.on "end", ->
    reqEndCount++
    assert.equal body, buffer
    return

  return
)
responses = 0
N = 10
M = 10
body = ""
i = 0

while i < 1000
  body += "hello world"
  i++
options =
  port: common.PORT
  path: "/"
  method: "PUT"

server.listen common.PORT, ->
  i = 0

  while i < N
    setTimeout (->
      j = 0

      while j < M
        req = http.request(options, (res) ->
          console.log res.statusCode
          server.close()  if ++responses is N * M
          return
        ).on("error", (e) ->
          console.log e.message
          process.exit 1
          return
        )
        req.end body
        j++
      return
    ), i
    i++
  return

process.on "exit", ->
  assert.equal N * M, responses
  assert.equal N * M, reqEndCount
  return

