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
util = require("util")
join = require("path").join
spawn = require("child_process").spawn
options =
  key: fs.readFileSync(join(common.fixturesDir, "keys", "agent1-key.pem"))
  cert: fs.readFileSync(join(common.fixturesDir, "keys", "agent1-cert.pem"))
  ca: [fs.readFileSync(join(common.fixturesDir, "keys", "ca1-cert.pem"))]

verified = false
server = tls.createServer(options, (cleartext) ->
  cleartext.end "World"
  return
)
server.listen common.PORT, ->
  socket = tls.connect(
    port: common.PORT
    rejectUnauthorized: false
  , ->
    peerCert = socket.getPeerCertificate()
    assert.ok not peerCert.issuerCertificate
    
    # Verify that detailed return value has all certs
    peerCert = socket.getPeerCertificate(true)
    assert.ok peerCert.issuerCertificate
    common.debug util.inspect(peerCert)
    assert.equal peerCert.subject.emailAddress, "ry@tinyclouds.org"
    assert.equal peerCert.serialNumber, "9A84ABCFB8A72ABE"
    assert.deepEqual peerCert.infoAccess["OCSP - URI"], ["http://ocsp.nodejs.org/"]
    issuer = peerCert.issuerCertificate
    assert.ok issuer.issuerCertificate is issuer
    assert.equal issuer.serialNumber, "B5090C899FC2FF93"
    verified = true
    server.close()
    return
  )
  socket.end "Hello"
  return

process.on "exit", ->
  assert.ok verified
  return

