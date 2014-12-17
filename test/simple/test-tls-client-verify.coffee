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
filenamePEM = (n) ->
  require("path").join common.fixturesDir, "keys", n + ".pem"
loadPEM = (n) ->
  fs.readFileSync filenamePEM(n)
testServers = (index, servers, clientOptions, cb) ->
  serverOptions = servers[index]
  unless serverOptions
    cb()
    return
  ok = serverOptions.ok
  serverOptions.key = loadPEM(serverOptions.key)  if serverOptions.key
  serverOptions.cert = loadPEM(serverOptions.cert)  if serverOptions.cert
  server = tls.createServer(serverOptions, (s) ->
    s.end "hello world\n"
    return
  )
  server.listen common.PORT, ->
    b = ""
    console.error "connecting..."
    client = tls.connect(clientOptions, ->
      authorized = client.authorized or hosterr.test(client.authorizationError)
      console.error "expected: " + ok + " authed: " + authorized
      assert.equal ok, authorized
      server.close()
      return
    )
    client.on "data", (d) ->
      b += d.toString()
      return

    client.on "end", ->
      assert.equal "hello world\n", b
      return

    client.on "close", ->
      testServers index + 1, servers, clientOptions, cb
      return

    return

  return
runTest = (testIndex) ->
  tcase = testCases[testIndex]
  return  unless tcase
  clientOptions =
    port: common.PORT
    ca: tcase.ca.map(loadPEM)
    key: loadPEM(tcase.key)
    cert: loadPEM(tcase.cert)
    rejectUnauthorized: false

  testServers 0, tcase.servers, clientOptions, ->
    successfulTests++
    runTest testIndex + 1
    return

  return
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
hosterr = /Hostname\/IP doesn\'t match certificate\'s altnames/g
testCases = [
  {
    ca: ["ca1-cert"]
    key: "agent2-key"
    cert: "agent2-cert"
    servers: [
      {
        ok: true
        key: "agent1-key"
        cert: "agent1-cert"
      }
      {
        ok: false
        key: "agent2-key"
        cert: "agent2-cert"
      }
      {
        ok: false
        key: "agent3-key"
        cert: "agent3-cert"
      }
    ]
  }
  {
    ca: []
    key: "agent2-key"
    cert: "agent2-cert"
    servers: [
      {
        ok: false
        key: "agent1-key"
        cert: "agent1-cert"
      }
      {
        ok: false
        key: "agent2-key"
        cert: "agent2-cert"
      }
      {
        ok: false
        key: "agent3-key"
        cert: "agent3-cert"
      }
    ]
  }
  {
    ca: [
      "ca1-cert"
      "ca2-cert"
    ]
    key: "agent2-key"
    cert: "agent2-cert"
    servers: [
      {
        ok: true
        key: "agent1-key"
        cert: "agent1-cert"
      }
      {
        ok: false
        key: "agent2-key"
        cert: "agent2-cert"
      }
      {
        ok: true
        key: "agent3-key"
        cert: "agent3-cert"
      }
    ]
  }
]
common = require("../common")
assert = require("assert")
fs = require("fs")
tls = require("tls")
successfulTests = 0
runTest 0
process.on "exit", ->
  console.log "successful tests: %d", successfulTests
  assert.equal successfulTests, testCases.length
  return

