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

# This test is to make sure that when the HTTP server
# responds to a HEAD request, it does not send any body.
# In this case it was sending '0\r\n\r\n'
server = http.createServer((req, res) ->
  res.writeHead 200 # broken: defaults to TE chunked
  res.end()
  return
)
server.listen common.PORT
responseComplete = false
server.on "listening", ->
  req = http.request(
    port: common.PORT
    method: "HEAD"
    path: "/"
  , (res) ->
    common.error "response"
    res.on "end", ->
      common.error "response end"
      server.close()
      responseComplete = true
      return

    res.resume()
    return
  )
  common.error "req"
  req.end()
  return

process.on "exit", ->
  assert.ok responseComplete
  return

