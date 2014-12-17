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
  start = ->
    
    # No options left
    return server.close()  if i is clientsOptions.length
    options = clientsOptions[i++]
    client = tls.connect(options, ->
      clientResults.push client.authorizationError and /Hostname\/IP doesn't/.test(client.authorizationError)
      client.destroy()
      
      # Continue
      start()
      return
    )
    return
  i = 0
  start()
  return
unless process.features.tls_sni
  console.error "Skipping because node compiled without OpenSSL or " + "with old OpenSSL version."
  process.exit 0
common = require("../common")
assert = require("assert")
fs = require("fs")
tls = require("tls")
serverOptions =
  key: loadPEM("agent2-key")
  cert: loadPEM("agent2-cert")

SNIContexts =
  "a.example.com":
    key: loadPEM("agent1-key")
    cert: loadPEM("agent1-cert")

  "asterisk.test.com":
    key: loadPEM("agent3-key")
    cert: loadPEM("agent3-cert")

serverPort = common.PORT
clientsOptions = [
  {
    port: serverPort
    key: loadPEM("agent1-key")
    cert: loadPEM("agent1-cert")
    ca: [loadPEM("ca1-cert")]
    servername: "a.example.com"
    rejectUnauthorized: false
  }
  {
    port: serverPort
    key: loadPEM("agent2-key")
    cert: loadPEM("agent2-cert")
    ca: [loadPEM("ca2-cert")]
    servername: "b.test.com"
    rejectUnauthorized: false
  }
  {
    port: serverPort
    key: loadPEM("agent2-key")
    cert: loadPEM("agent2-cert")
    ca: [loadPEM("ca2-cert")]
    servername: "a.b.test.com"
    rejectUnauthorized: false
  }
  {
    port: serverPort
    key: loadPEM("agent3-key")
    cert: loadPEM("agent3-cert")
    ca: [loadPEM("ca1-cert")]
    servername: "c.wrong.com"
    rejectUnauthorized: false
  }
]
serverResults = []
clientResults = []
server = tls.createServer(serverOptions, (c) ->
  serverResults.push c.servername
  return
)
server.addContext "a.example.com", SNIContexts["a.example.com"]
server.addContext "*.test.com", SNIContexts["asterisk.test.com"]
server.listen serverPort, startTest
process.on "exit", ->
  assert.deepEqual serverResults, [
    "a.example.com"
    "b.test.com"
    "a.b.test.com"
    "c.wrong.com"
  ]
  assert.deepEqual clientResults, [
    true
    true
    false
    false
  ]
  return

