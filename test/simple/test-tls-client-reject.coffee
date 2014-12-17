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
unauthorized = ->
  socket = tls.connect(
    port: common.PORT
    servername: "localhost"
    rejectUnauthorized: false
  , ->
    assert not socket.authorized
    socket.end()
    rejectUnauthorized()
    return
  )
  socket.on "error", (err) ->
    assert false
    return

  socket.write "ok"
  return
rejectUnauthorized = ->
  socket = tls.connect(common.PORT,
    servername: "localhost"
  , ->
    assert false
    return
  )
  socket.on "error", (err) ->
    common.debug err
    authorized()
    return

  socket.write "ng"
  return
authorized = ->
  socket = tls.connect(common.PORT,
    ca: [fs.readFileSync(path.join(common.fixturesDir, "test_cert.pem"))]
    servername: "localhost"
  , ->
    assert socket.authorized
    socket.end()
    server.close()
    return
  )
  socket.on "error", (err) ->
    assert false
    return

  socket.write "ok"
  return
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

connectCount = 0
server = tls.createServer(options, (socket) ->
  ++connectCount
  socket.on "data", (data) ->
    common.debug data.toString()
    assert.equal data, "ok"
    return

  return
).listen(common.PORT, ->
  unauthorized()
  return
)
process.on "exit", ->
  assert.equal connectCount, 3
  return

