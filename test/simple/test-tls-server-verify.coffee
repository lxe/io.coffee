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

# This is a rather complex test which sets up various TLS servers with node
# and connects to them using the 'openssl s_client' command line utility
# with various keys. Depending on the certificate authority and other
# parameters given to the server, the various clients are
# - rejected,
# - accepted and "unauthorized", or
# - accepted and "authorized".

# Agent4 has a cert in the CRL.
filenamePEM = (n) ->
  require("path").join common.fixturesDir, "keys", n + ".pem"
loadPEM = (n) ->
  fs.readFileSync filenamePEM(n)
runClient = (options, cb) ->
  
  # Client can connect in three ways:
  # - Self-signed cert
  # - Certificate, but not signed by CA.
  # - Certificate signed by CA.
  args = [
    "s_client"
    "-connect"
    "127.0.0.1:" + common.PORT
  ]
  console.log "  connecting with", options.name
  switch options.name
    when "agent1"
      
      # Signed by CA1
      args.push "-key"
      args.push filenamePEM("agent1-key")
      args.push "-cert"
      args.push filenamePEM("agent1-cert")
    when "agent2"
      
      # Self-signed
      # This is also the key-cert pair that the server will use.
      args.push "-key"
      args.push filenamePEM("agent2-key")
      args.push "-cert"
      args.push filenamePEM("agent2-cert")
    when "agent3"
      
      # Signed by CA2
      args.push "-key"
      args.push filenamePEM("agent3-key")
      args.push "-cert"
      args.push filenamePEM("agent3-cert")
    when "agent4"
      
      # Signed by CA2 (rejected by ca2-crl)
      args.push "-key"
      args.push filenamePEM("agent4-key")
      args.push "-cert"
      args.push filenamePEM("agent4-cert")
    when "nocert"
    
    # Do not send certificate
    else
      throw new Error("Unknown agent name")
  
  # To test use: openssl s_client -connect localhost:8000
  client = spawn(common.opensslCli, args)
  out = ""
  rejected = true
  authed = false
  goodbye = false
  client.stdout.setEncoding "utf8"
  client.stdout.on "data", (d) ->
    out += d
    if not goodbye and /_unauthed/g.test(out)
      console.error "  * unauthed"
      goodbye = true
      client.stdin.end "goodbye\n"
      authed = false
      rejected = false
    if not goodbye and /_authed/g.test(out)
      console.error "  * authed"
      goodbye = true
      client.stdin.end "goodbye\n"
      authed = true
      rejected = false
    return

  
  #client.stdout.pipe(process.stdout);
  client.on "exit", (code) ->
    
    #assert.equal(0, code, options.name +
    #      ": s_client exited with error code " + code);
    if options.shouldReject
      assert.equal true, rejected, options.name + " NOT rejected, but should have been"
    else
      assert.equal false, rejected, options.name + " rejected, but should NOT have been"
      assert.equal options.shouldAuth, authed
    cb()
    return

  return

# Run the tests
runTest = (testIndex) ->
  
  #
  #   * If renegotiating - session might be resumed and openssl won't request
  #   * client's certificate (probably because of bug in the openssl)
  #   
  runNextClient = (clientIndex) ->
    options = tcase.clients[clientIndex]
    if options
      runClient options, ->
        runNextClient clientIndex + 1
        return

    else
      server.close()
      successfulTests++
      runTest testIndex + 1
    return
  tcase = testCases[testIndex]
  return  unless tcase
  console.error "Running '%s'", tcase.title
  cas = tcase.CAs.map(loadPEM)
  crl = (if tcase.crl then loadPEM(tcase.crl) else null)
  serverOptions =
    key: serverKey
    cert: serverCert
    ca: cas
    crl: crl
    requestCert: tcase.requestCert
    rejectUnauthorized: tcase.rejectUnauthorized

  connections = 0
  serverOptions.secureOptions = constants.SSL_OP_NO_SESSION_RESUMPTION_ON_RENEGOTIATION  if tcase.renegotiate
  renegotiated = false
  server = tls.Server(serverOptions, handleConnection = (c) ->
    if tcase.renegotiate and not renegotiated
      renegotiated = true
      setTimeout (->
        console.error "- connected, renegotiating"
        c.write "\n_renegotiating\n"
        c.renegotiate
          requestCert: true
          rejectUnauthorized: false
        , (err) ->
          assert not err
          c.write "\n_renegotiated\n"
          handleConnection c
          return

      ), 200
      return
    connections++
    if c.authorized
      console.error "- authed connection: " + c.getPeerCertificate().subject.CN
      c.write "\n_authed\n"
    else
      console.error "- unauthed connection: %s", c.authorizationError
      c.write "\n_unauthed\n"
    return
  )
  server.listen common.PORT, ->
    if tcase.debug
      console.error "TLS server running on port " + common.PORT
    else
      runNextClient 0
    return

  return
common = require("../common")
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
testCases = [
  {
    title: "Do not request certs. Everyone is unauthorized."
    requestCert: false
    rejectUnauthorized: false
    renegotiate: false
    CAs: ["ca1-cert"]
    clients: [
      {
        name: "agent1"
        shouldReject: false
        shouldAuth: false
      }
      {
        name: "agent2"
        shouldReject: false
        shouldAuth: false
      }
      {
        name: "agent3"
        shouldReject: false
        shouldAuth: false
      }
      {
        name: "nocert"
        shouldReject: false
        shouldAuth: false
      }
    ]
  }
  {
    title: "Allow both authed and unauthed connections with CA1"
    requestCert: true
    rejectUnauthorized: false
    renegotiate: false
    CAs: ["ca1-cert"]
    clients: [
      {
        name: "agent1"
        shouldReject: false
        shouldAuth: true
      }
      {
        name: "agent2"
        shouldReject: false
        shouldAuth: false
      }
      {
        name: "agent3"
        shouldReject: false
        shouldAuth: false
      }
      {
        name: "nocert"
        shouldReject: false
        shouldAuth: false
      }
    ]
  }
  {
    title: "Do not request certs at connection. Do that later"
    requestCert: false
    rejectUnauthorized: false
    renegotiate: true
    CAs: ["ca1-cert"]
    clients: [
      {
        name: "agent1"
        shouldReject: false
        shouldAuth: true
      }
      {
        name: "agent2"
        shouldReject: false
        shouldAuth: false
      }
      {
        name: "agent3"
        shouldReject: false
        shouldAuth: false
      }
      {
        name: "nocert"
        shouldReject: false
        shouldAuth: false
      }
    ]
  }
  {
    title: "Allow only authed connections with CA1"
    requestCert: true
    rejectUnauthorized: true
    renegotiate: false
    CAs: ["ca1-cert"]
    clients: [
      {
        name: "agent1"
        shouldReject: false
        shouldAuth: true
      }
      {
        name: "agent2"
        shouldReject: true
      }
      {
        name: "agent3"
        shouldReject: true
      }
      {
        name: "nocert"
        shouldReject: true
      }
    ]
  }
  {
    title: "Allow only authed connections with CA1 and CA2"
    requestCert: true
    rejectUnauthorized: true
    renegotiate: false
    CAs: [
      "ca1-cert"
      "ca2-cert"
    ]
    clients: [
      {
        name: "agent1"
        shouldReject: false
        shouldAuth: true
      }
      {
        name: "agent2"
        shouldReject: true
      }
      {
        name: "agent3"
        shouldReject: false
        shouldAuth: true
      }
      {
        name: "nocert"
        shouldReject: true
      }
    ]
  }
  {
    title: "Allow only certs signed by CA2 but not in the CRL"
    requestCert: true
    rejectUnauthorized: true
    renegotiate: false
    CAs: ["ca2-cert"]
    crl: "ca2-crl"
    clients: [
      {
        name: "agent1"
        shouldReject: true
        shouldAuth: false
      }
      {
        name: "agent2"
        shouldReject: true
        shouldAuth: false
      }
      {
        name: "agent3"
        shouldReject: false
        shouldAuth: true
      }
      {
        name: "agent4"
        shouldReject: true
        shouldAuth: false
      }
      {
        name: "nocert"
        shouldReject: true
      }
    ]
  }
]
constants = require("constants")
assert = require("assert")
fs = require("fs")
tls = require("tls")
spawn = require("child_process").spawn
serverKey = loadPEM("agent2-key")
serverCert = loadPEM("agent2-cert")
successfulTests = 0
runTest 0
process.on "exit", ->
  assert.equal successfulTests, testCases.length
  return

