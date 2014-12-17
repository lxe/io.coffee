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
https = require("https")
tls = require("tls")
fs = require("fs")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent2-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent2-cert.pem")

connections = 0

# create server
server = https.createServer(options, (res, res) ->
  res.end "Goodbye"
  connections++
  return
)

# start listening
server.listen common.PORT, ->
  session1 = null
  client1 = tls.connect(
    port: common.PORT
    rejectUnauthorized: false
  , ->
    console.log "connect1"
    assert.ok not client1.isSessionReused(), "Session *should not* be reused."
    session1 = client1.getSession()
    client1.write "GET / HTTP/1.0\r\n" + "Server: 127.0.0.1\r\n" + "\r\n"
    return
  )
  client1.on "close", ->
    console.log "close1"
    opts =
      port: common.PORT
      rejectUnauthorized: false
      session: session1

    client2 = tls.connect(opts, ->
      console.log "connect2"
      assert.ok client2.isSessionReused(), "Session *should* be reused."
      client2.write "GET / HTTP/1.0\r\n" + "Server: 127.0.0.1\r\n" + "\r\n"
      return
    )
    client2.on "close", ->
      console.log "close2"
      server.close()
      return

    return

  return

process.on "exit", ->
  assert.equal 2, connections
  return

