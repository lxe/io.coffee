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

# Verify that the 'upgrade' header causes an 'upgrade' event to be emitted to
# the HTTP client. This test uses a raw TCP server to better control server
# behavior.
common = require("../common")
assert = require("assert")
http = require("http")
net = require("net")

# Create a TCP server
srv = net.createServer((c) ->
  data = ""
  c.on "data", (d) ->
    data += d.toString("utf8")
    c.write "HTTP/1.1 101\r\n"
    c.write "hello: world\r\n"
    c.write "connection: upgrade\r\n"
    c.write "upgrade: websocket\r\n"
    c.write "\r\n"
    c.write "nurtzo"
    return

  c.on "end", ->
    c.end()
    return

  return
)
gotUpgrade = false
srv.listen common.PORT, "127.0.0.1", ->
  options =
    port: common.PORT
    host: "127.0.0.1"
    headers:
      upgrade: "websocket"

  name = options.host + ":" + options.port
  req = http.request(options)
  req.end()
  req.on "upgrade", (res, socket, upgradeHead) ->
    
    # XXX: This test isn't fantastic, as it assumes that the entire response
    #      from the server will arrive in a single data callback
    assert.equal upgradeHead, "nurtzo"
    console.log res.headers
    expectedHeaders =
      hello: "world"
      connection: "upgrade"
      upgrade: "websocket"

    assert.deepEqual expectedHeaders, res.headers
    
    # Make sure this request got removed from the pool.
    assert not http.globalAgent.sockets.hasOwnProperty(name)
    req.on "close", ->
      socket.end()
      srv.close()
      gotUpgrade = true
      return

    return

  return

process.on "exit", ->
  assert.ok gotUpgrade
  return

