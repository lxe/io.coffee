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
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
common = require("../common")
assert = require("assert")
tls = require("tls")
fs = require("fs")
path = require("path")
options =
  key: fs.readFileSync(path.join(common.fixturesDir, "test_key.pem"))
  cert: fs.readFileSync(path.join(common.fixturesDir, "test_cert.pem"))

bufSize = 1024 * 1024
sent = 0
received = 0
server = tls.Server(options, (socket) ->
  socket.pipe socket
  socket.on "data", (c) ->
    console.error "data", c.length
    return

  return
)
server.listen common.PORT, ->
  resumed = false
  client = tls.connect(
    port: common.PORT
    rejectUnauthorized: false
  , ->
    send = ->
      console.error "sending"
      ret = client.write(new Buffer(bufSize))
      console.error "write => %j", ret
      if false isnt ret
        console.error "write again"
        sent += bufSize
        assert.ok sent < 100 * 1024 * 1024 # max 100MB
        return process.nextTick(send)
      sent += bufSize
      common.debug "sent: " + sent
      resumed = true
      client.resume()
      console.error "resumed", client
      return
    console.error "connected"
    client.pause()
    common.debug "paused"
    send()
    return
  )
  client.on "data", (data) ->
    console.error "data"
    assert.ok resumed
    received += data.length
    console.error "received", received
    console.error "sent", sent
    if received >= sent
      common.debug "received: " + received
      client.end()
      server.close()
    return

  return

process.on "exit", ->
  assert.equal sent, received
  return

