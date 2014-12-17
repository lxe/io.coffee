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
fs = require("fs")
http = require("http")
status_ok = false # status code == 200?
headers_ok = false
body_ok = false
server = http.createServer((req, res) ->
  res.writeHead 200,
    "Content-Type": "text/plain"
    Connection: "close"

  res.write "hello "
  res.write "world\n"
  res.end()
  return
)
server.listen common.PIPE, ->
  options =
    socketPath: common.PIPE
    path: "/"

  req = http.get(options, (res) ->
    assert.equal res.statusCode, 200
    status_ok = true
    assert.equal res.headers["content-type"], "text/plain"
    headers_ok = true
    res.body = ""
    res.setEncoding "utf8"
    res.on "data", (chunk) ->
      res.body += chunk
      return

    res.on "end", ->
      assert.equal res.body, "hello world\n"
      body_ok = true
      server.close (error) ->
        assert.equal error, `undefined`
        server.close (error) ->
          assert.equal error and error.message, "Not running"
          return

        return

      return

    return
  )
  req.on "error", (e) ->
    console.log e.stack
    process.exit 1
    return

  req.end()
  return

process.on "exit", ->
  assert.ok status_ok
  assert.ok headers_ok
  assert.ok body_ok
  return

