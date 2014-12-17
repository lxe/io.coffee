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
fs = require("fs")
path = require("path")
net = require("net")
tls = require("tls")
assert = require("assert")
options = undefined
a = undefined
b = undefined
portA = undefined
portB = undefined
gotHello = false
options =
  key: fs.readFileSync(path.join(common.fixturesDir, "test_key.pem"))
  cert: fs.readFileSync(path.join(common.fixturesDir, "test_cert.pem"))


# the "proxy" server
a = tls.createServer(options, (socket) ->
  options =
    host: "127.0.0.1"
    port: b.address().port
    rejectUnauthorized: false

  dest = net.connect(options)
  dest.pipe socket
  socket.pipe dest
  return
)

# the "target" server
b = tls.createServer(options, (socket) ->
  socket.end "hello"
  return
)
process.on "exit", ->
  assert gotHello
  return

a.listen common.PORT, ->
  b.listen common.PORT + 1, ->
    options =
      host: "127.0.0.1"
      port: a.address().port
      rejectUnauthorized: false

    socket = tls.connect(options)
    ssl = undefined
    ssl = tls.connect(
      socket: socket
      rejectUnauthorized: false
    )
    ssl.setEncoding "utf8"
    ssl.once "data", (data) ->
      assert.equal "hello", data
      gotHello = true
      return

    ssl.on "end", ->
      ssl.end()
      a.close()
      b.close()
      return

    return

  return

