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
fs = require("fs")
net = require("net")
have_openssl = undefined
try
  crypto = require("crypto")
  have_openssl = true
catch e
  have_openssl = false
  console.log "Not compiled with OPENSSL support."
  process.exit()
caPem = fs.readFileSync(common.fixturesDir + "/test_ca.pem", "ascii")
certPem = fs.readFileSync(common.fixturesDir + "/test_cert.pem", "ascii")
keyPem = fs.readFileSync(common.fixturesDir + "/test_key.pem", "ascii")
try
  credentials = crypto.createCredentials(
    key: keyPem
    cert: certPem
    ca: caPem
  )
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
testData = "TEST123"
serverData = ""
clientData = ""
gotSecureServer = false
gotSecureClient = false
secureServer = net.createServer((connection) ->
  self = this
  connection.setSecure credentials
  connection.setEncoding "UTF8"
  connection.on "secure", ->
    gotSecureServer = true
    verified = connection.verifyPeer()
    peerDN = JSON.stringify(connection.getPeerCertificate())
    assert.equal verified, true
    assert.equal peerDN, "{\"subject\":\"/C=UK/ST=Acknack Ltd/L=Rhys Jones" + "/O=node.js/OU=Test TLS Certificate/CN=localhost\"," + "\"issuer\":\"/C=UK/ST=Acknack Ltd/L=Rhys Jones/O=node.js" + "/OU=Test TLS Certificate/CN=localhost\"," + "\"valid_from\":\"Nov 11 09:52:22 2009 GMT\"," + "\"valid_to\":\"Nov  6 09:52:22 2029 GMT\"," + "\"fingerprint\":\"2A:7A:C2:DD:E5:F9:CC:53:72:35:99:7A:02:" + "5A:71:38:52:EC:8A:DF\"}"
    return

  connection.on "data", (chunk) ->
    serverData += chunk
    connection.write chunk
    return

  connection.on "end", ->
    assert.equal serverData, testData
    connection.end()
    self.close()
    return

  return
)
secureServer.listen common.PORT
secureServer.on "listening", ->
  secureClient = net.createConnection(common.PORT)
  secureClient.setEncoding "UTF8"
  secureClient.on "connect", ->
    secureClient.setSecure credentials
    return

  secureClient.on "secure", ->
    gotSecureClient = true
    verified = secureClient.verifyPeer()
    peerDN = JSON.stringify(secureClient.getPeerCertificate())
    assert.equal verified, true
    assert.equal peerDN, "{\"subject\":\"/C=UK/ST=Acknack Ltd/L=Rhys Jones" + "/O=node.js/OU=Test TLS Certificate/CN=localhost\"," + "\"issuer\":\"/C=UK/ST=Acknack Ltd/L=Rhys Jones/O=node.js" + "/OU=Test TLS Certificate/CN=localhost\"," + "\"valid_from\":\"Nov 11 09:52:22 2009 GMT\"," + "\"valid_to\":\"Nov  6 09:52:22 2029 GMT\"," + "\"fingerprint\":\"2A:7A:C2:DD:E5:F9:CC:53:72:35:99:7A:02:" + "5A:71:38:52:EC:8A:DF\"}"
    secureClient.write testData
    secureClient.end()
    return

  secureClient.on "data", (chunk) ->
    clientData += chunk
    return

  secureClient.on "end", ->
    assert.equal clientData, testData
    return

  return

process.on "exit", ->
  assert.ok gotSecureServer, "Did not get secure event for server"
  assert.ok gotSecureClient, "Did not get secure event for client"
  return

