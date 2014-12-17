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
tlsTest = (port, host, caPem, keyPem, certPem) ->
  N = 50
  count = 0
  sent_final_ping = false
  server = net.createServer((socket) ->
    assert.equal true, socket.remoteAddress isnt null
    assert.equal true, socket.remoteAddress isnt `undefined`
    if host is "127.0.0.1"
      assert.equal socket.remoteAddress, "127.0.0.1"
    else assert.equal socket.remoteAddress, "127.0.0.1"  unless host?
    socket.setEncoding "utf8"
    socket.setNoDelay()
    socket.timeout = 0
    socket.on "data", (data) ->
      verified = socket.verifyPeer()
      peerDN = socket.getPeerCertificate("DNstring")
      assert.equal verified, 1
      assert.equal peerDN, "C=UK,ST=Acknack Ltd,L=Rhys Jones,O=node.js," + "OU=Test TLS Certificate,CN=localhost"
      console.log "server got: " + JSON.stringify(data)
      assert.equal "open", socket.readyState
      assert.equal true, count <= N
      socket.write "PONG"  if /PING/.exec(data)
      return

    socket.on "end", ->
      assert.equal "writeOnly", socket.readyState
      socket.end()
      return

    socket.on "close", (had_error) ->
      assert.equal false, had_error
      assert.equal "closed", socket.readyState
      socket.server.close()
      return

    return
  )
  server.setSecure "X509_PEM", caPem, 0, keyPem, certPem
  server.listen port, host
  client = net.createConnection(port, host)
  client.setEncoding "utf8"
  client.setSecure "X509_PEM", caPem, 0, keyPem, caPem
  client.on "connect", ->
    assert.equal "open", client.readyState
    verified = client.verifyPeer()
    peerDN = client.getPeerCertificate("DNstring")
    assert.equal verified, 1
    assert.equal peerDN, "C=UK,ST=Acknack Ltd,L=Rhys Jones,O=node.js," + "OU=Test TLS Certificate,CN=localhost"
    client.write "PING"
    return

  client.on "data", (data) ->
    assert.equal "PONG", data
    count += 1
    console.log "client got PONG"
    if sent_final_ping
      assert.equal "readOnly", client.readyState
      return
    else
      assert.equal "open", client.readyState
    if count < N
      client.write "PING"
    else
      sent_final_ping = true
      client.write "PING"
      client.end()
    return

  client.on "close", ->
    assert.equal N + 1, count
    assert.equal true, sent_final_ping
    tests_run += 1
    return

  return
common = require("../common")
assert = require("assert")
net = require("net")
fs = require("fs")
tests_run = 0
have_tls = undefined
try
  dummy_server = net.createServer()
  dummy_server.setSecure()
  have_tls = true
catch e
  have_tls = false
if have_tls
  caPem = fs.readFileSync(common.fixturesDir + "/test_ca.pem")
  certPem = fs.readFileSync(common.fixturesDir + "/test_cert.pem")
  keyPem = fs.readFileSync(common.fixturesDir + "/test_key.pem")
  
  # All are run at once, so run on different ports 
  tlsTest common.PORT, "localhost", caPem, keyPem, certPem
  tlsTest common.PORT + 1, null, caPem, keyPem, certPem
  process.on "exit", ->
    assert.equal 2, tests_run
    return

else
  console.log "Not compiled with TLS support -- skipping test"
  process.exit 0
