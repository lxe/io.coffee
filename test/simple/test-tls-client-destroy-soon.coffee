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

# Create an ssl server.  First connection, validate that not resume.
# Cache session and close connection.  Use session on second connection.
# ASSERT resumption.
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
common = require("../common")
assert = require("assert")
tls = require("tls")
fs = require("fs")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent2-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent2-cert.pem")

big = new Buffer(2 * 1024 * 1024)
connections = 0
bytesRead = 0
big.fill "Y"

# create server
server = tls.createServer(options, (socket) ->
  socket.end big
  socket.destroySoon()
  connections++
  return
)

# start listening
server.listen common.PORT, ->
  client = tls.connect(
    port: common.PORT
    rejectUnauthorized: false
  , ->
    client.on "readable", ->
      d = client.read()
      bytesRead += d.length  if d
      return

    client.on "end", ->
      server.close()
      return

    return
  )
  return

process.on "exit", ->
  assert.equal 1, connections
  assert.equal big.length, bytesRead
  return

