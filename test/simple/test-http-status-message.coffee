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
test = ->
  bufs = []
  client = net.connect(common.PORT, ->
    client.write "GET / HTTP/1.1\r\nConnection: close\r\n\r\n"
    return
  )
  client.on "data", (chunk) ->
    bufs.push chunk
    return

  client.on "end", ->
    head = Buffer.concat(bufs).toString("binary").split("\r\n")[0]
    assert.equal "HTTP/1.1 200 Custom Message", head
    console.log "ok"
    s.close()
    return

  return
common = require("../common")
assert = require("assert")
http = require("http")
net = require("net")
s = http.createServer((req, res) ->
  res.statusCode = 200
  res.statusMessage = "Custom Message"
  res.end ""
  return
)
s.listen common.PORT, test
