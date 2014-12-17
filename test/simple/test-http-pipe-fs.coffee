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
fs = require("fs")
path = require("path")
file = path.join(common.tmpDir, "http-pipe-fs-test.txt")
requests = 0
server = http.createServer((req, res) ->
  ++requests
  stream = fs.createWriteStream(file)
  req.pipe stream
  stream.on "close", ->
    res.writeHead 200
    res.end()
    return

  return
).listen(common.PORT, ->
  http.globalAgent.maxSockets = 1
  i = 0

  while i < 2
    ((i) ->
      req = http.request(
        port: common.PORT
        method: "POST"
        headers:
          "Content-Length": 5
      , (res) ->
        res.on "end", ->
          common.debug "res" + i + " end"
          server.close()  if i is 2
          return

        res.resume()
        return
      )
      req.on "socket", (s) ->
        common.debug "req" + i + " start"
        return

      req.end "12345"
      return
    ) i + 1
    ++i
  return
)
process.on "exit", ->
  assert.equal requests, 2
  return

