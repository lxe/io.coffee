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
# 1mb
Mediator = ->
  stream.Writable.call this
  @buf = ""
  return
common = require("../common")
assert = require("assert")
tls = require("tls")
fs = require("fs")
stream = require("stream")
util = require("util")
clientConnected = 0
serverConnected = 0
request = new Buffer(new Array(1024 * 256).join("ABCD"))
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")

util.inherits Mediator, stream.Writable
Mediator::_write = write = (data, enc, cb) ->
  @buf += data
  setTimeout cb, 0
  if @buf.length >= request.length
    assert.equal @buf, request.toString()
    server.close()
  return

mediator = new Mediator()
server = tls.Server(options, (socket) ->
  socket.pipe mediator
  serverConnected++
  return
)
server.listen common.PORT, ->
  client1 = tls.connect(
    port: common.PORT
    rejectUnauthorized: false
  , ->
    ++clientConnected
    client1.end request
    return
  )
  return

process.on "exit", ->
  assert.equal clientConnected, 1
  assert.equal serverConnected, 1
  return

