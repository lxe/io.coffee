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
startTest = ->
  connectClient = (options, callback) ->
    client = tls.connect(options, ->
      clientsResults.push client.npnProtocol
      client.destroy()
      callback()
      return
    )
    return
  connectClient clientsOptions[0], ->
    connectClient clientsOptions[1], ->
      connectClient clientsOptions[2], ->
        connectClient clientsOptions[3], ->
          server.close()
          return

        return

      return

    return

  return
unless process.features.tls_npn
  console.error "Skipping because node compiled without OpenSSL or " + "with old OpenSSL version."
  process.exit 0
common = require("../common")
assert = require("assert")
fs = require("fs")
tls = require("tls")
serverOptions =
  key: loadPEM("agent2-key")
  cert: loadPEM("agent2-cert")
  crl: loadPEM("ca2-crl")
  SNICallback: (servername, cb) ->
    cb null, tls.createSecureContext(
      key: loadPEM("agent2-key")
      cert: loadPEM("agent2-cert")
      crl: loadPEM("ca2-crl")
    )
    return

  NPNProtocols: [
    "a"
    "b"
    "c"
  ]

serverPort = common.PORT
clientsOptions = [
  {
    port: serverPort
    key: serverOptions.key
    cert: serverOptions.cert
    crl: serverOptions.crl
    NPNProtocols: [
      "a"
      "b"
      "c"
    ]
    rejectUnauthorized: false
  }
  {
    port: serverPort
    key: serverOptions.key
    cert: serverOptions.cert
    crl: serverOptions.crl
    NPNProtocols: [
      "c"
      "b"
      "e"
    ]
    rejectUnauthorized: false
  }
  {
    port: serverPort
    key: serverOptions.key
    cert: serverOptions.cert
    crl: serverOptions.crl
    rejectUnauthorized: false
  }
  {
    port: serverPort
    key: serverOptions.key
    cert: serverOptions.cert
    crl: serverOptions.crl
    NPNProtocols: [
      "first-priority-unsupported"
      "x"
      "y"
    ]
    rejectUnauthorized: false
  }
]
serverResults = []
clientsResults = []
server = tls.createServer(serverOptions, (c) ->
  serverResults.push c.npnProtocol
  return
)
server.listen serverPort, startTest
process.on "exit", ->
  assert.equal serverResults[0], clientsResults[0]
  assert.equal serverResults[1], clientsResults[1]
  assert.equal serverResults[2], "http/1.1"
  assert.equal clientsResults[2], false
  assert.equal serverResults[3], "first-priority-unsupported"
  assert.equal clientsResults[3], false
  return

