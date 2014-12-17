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
request_count = 1000
body = "{\"ok\": true}"
server = http.createServer((req, res) ->
  res.writeHead 200,
    "Content-Type": "text/javascript"

  res.write body
  res.end()
  return
)
server.listen common.PORT
requests_ok = 0
requests_complete = 0
server.on "listening", ->
  i = 0

  while i < request_count
    http.cat "http://localhost:" + common.PORT + "/", "utf8", (err, content) ->
      requests_complete++
      if err
        common.print "-"
      else
        assert.equal body, content
        common.print "."
        requests_ok++
      if requests_complete is request_count
        console.log "\nrequests ok: " + requests_ok
        server.close()
      return

    i++
  return

process.on "exit", ->
  assert.equal request_count, requests_complete
  assert.equal request_count, requests_ok
  return

