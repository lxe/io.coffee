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

# start a tcp server that closes incoming connections immediately

# do a GET request, expect it to fail
onListen = ->
  req = http.request(options, (res) ->
    assert.ok false, "this should never run"
    return
  )
  req.on "error", (err) ->
    assert.equal err.code, "ECONNRESET"
    caughtError = true
    return

  req.end()
  return
common = require("../common")
assert = require("assert")
http = require("http")
net = require("net")
caughtError = false
options =
  host: "127.0.0.1"
  port: common.PORT

server = net.createServer((client) ->
  client.destroy()
  server.close()
  return
)
server.listen options.port, options.host, onListen
process.on "exit", ->
  assert.equal caughtError, true
  return

