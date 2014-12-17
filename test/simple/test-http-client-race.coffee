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
url = require("url")
body1_s = "1111111111111111"
body2_s = "22222"
server = http.createServer((req, res) ->
  body = (if url.parse(req.url).pathname is "/1" then body1_s else body2_s)
  res.writeHead 200,
    "Content-Type": "text/plain"
    "Content-Length": body.length

  res.end body
  return
)
server.listen common.PORT
body1 = ""
body2 = ""
server.on "listening", ->
  req1 = http.request(
    port: common.PORT
    path: "/1"
  )
  req1.end()
  req1.on "response", (res1) ->
    res1.setEncoding "utf8"
    res1.on "data", (chunk) ->
      body1 += chunk
      return

    res1.on "end", ->
      req2 = http.request(
        port: common.PORT
        path: "/2"
      )
      req2.end()
      req2.on "response", (res2) ->
        res2.setEncoding "utf8"
        res2.on "data", (chunk) ->
          body2 += chunk
          return

        res2.on "end", ->
          server.close()
          return

        return

      return

    return

  return

process.on "exit", ->
  assert.equal body1_s, body1
  assert.equal body2_s, body2
  return

