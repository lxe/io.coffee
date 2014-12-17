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
net = require("net")
server = http.createServer((req, res) ->
  common.error "got req"
  throw new Error("This shouldn't happen.")return
)
server.on "upgrade", (req, socket, upgradeHead) ->
  common.error "got upgrade event"
  
  # test that throwing an error from upgrade gets
  # is uncaught
  throw new Error("upgrade error")return

gotError = false
process.on "uncaughtException", (e) ->
  common.error "got 'clientError' event"
  assert.equal "upgrade error", e.message
  gotError = true
  process.exit 0
  return

server.listen common.PORT, ->
  c = net.createConnection(common.PORT)
  c.on "connect", ->
    common.error "client wrote message"
    c.write "GET /blah HTTP/1.1\r\n" + "Upgrade: WebSocket\r\n" + "Connection: Upgrade\r\n" + "\r\n\r\nhello world"
    return

  c.on "end", ->
    c.end()
    return

  c.on "close", ->
    common.error "client close"
    server.close()
    return

  return

process.on "exit", ->
  assert.ok gotError
  return

