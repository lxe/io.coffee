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

# Just to test asynchronous callback
startTest = ->
  connectClient = (i, callback) ->
    next = ->
      clientErrors.push clientError
      serverErrors.push serverError
      if i is clientsOptions.length - 1
        callback()
      else
        connectClient i + 1, callback
      return
    options = clientsOptions[i]
    clientError = null
    serverError = null
    client = tls.connect(options, ->
      clientResults.push /Hostname\/IP doesn't/.test(client.authorizationError or "")
      client.destroy()
      next()
      return
    )
    client.on "error", (err) ->
      clientResults.push false
      clientError = err.message
      next()
      return

    return
  connectClient 0, ->
    server.close()
    return

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
  SNICallback: (servername, callback) ->
    context = SNIContexts[servername]
    setTimeout (->
      if context
        if context.emptyRegression
          callback null, {}
        else
          callback null, tls.createSecureContext(context)
      else
        callback null, null
      return
    ), 100
    return

SNIContexts =
  "a.example.com":
    key: loadPEM("agent1-key")
    cert: loadPEM("agent1-cert")

  "b.example.com":
    key: loadPEM("agent3-key")
    cert: loadPEM("agent3-cert")

  "c.another.com":
    emptyRegression: true

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
    servername: "b.example.com"
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
  {
    port: serverPort
    key: loadPEM("agent3-key")
    cert: loadPEM("agent3-cert")
    ca: [loadPEM("ca1-cert")]
    servername: "c.another.com"
    rejectUnauthorized: false
  }
]
serverResults = []
clientResults = []
serverErrors = []
clientErrors = []
serverError = undefined
clientError = undefined
server = tls.createServer(serverOptions, (c) ->
  serverResults.push c.servername
  return
)
server.on "clientError", (err) ->
  serverResults.push null
  serverError = err.message
  return

server.listen serverPort, startTest
process.on "exit", ->
  assert.deepEqual serverResults, [
    "a.example.com"
    "b.example.com"
    "c.wrong.com"
    null
  ]
  assert.deepEqual clientResults, [
    true
    true
    false
    false
  ]
  assert.deepEqual clientErrors, [
    null
    null
    null
    "socket hang up"
  ]
  assert.deepEqual serverErrors, [
    null
    null
    null
    "Invalid SNI context"
  ]
  return

