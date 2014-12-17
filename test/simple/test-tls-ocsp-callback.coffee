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
test = (testOptions, cb) ->
  keyFile = join(common.fixturesDir, "keys", "agent1-key.pem")
  certFile = join(common.fixturesDir, "keys", "agent1-cert.pem")
  caFile = join(common.fixturesDir, "keys", "ca1-cert.pem")
  key = fs.readFileSync(keyFile)
  cert = fs.readFileSync(certFile)
  ca = fs.readFileSync(caFile)
  options =
    key: key
    cert: cert
    ca: [ca]

  requestCount = 0
  clientSecure = 0
  ocspCount = 0
  ocspResponse = undefined
  session = undefined
  server = tls.createServer(options, (cleartext) ->
    cleartext.on "error", (er) ->
      
      # We're ok with getting ECONNRESET in this test, but it's
      # timing-dependent, and thus unreliable. Any other errors
      # are just failures, though.
      throw er  if er.code isnt "ECONNRESET"
      return

    ++requestCount
    cleartext.end()
    return
  )
  server.on "OCSPRequest", (cert, issuer, callback) ->
    ++ocspCount
    assert.ok Buffer.isBuffer(cert)
    assert.ok Buffer.isBuffer(issuer)
    
    # Just to check that async really works there
    setTimeout (->
      callback null, (if testOptions.response then new Buffer(testOptions.response) else null)
      return
    ), 100
    return

  server.listen common.PORT, ->
    client = tls.connect(
      port: common.PORT
      requestOCSP: testOptions.ocsp isnt false
      secureOptions: (if testOptions.ocsp is false then constants.SSL_OP_NO_TICKET else 0)
      rejectUnauthorized: false
    , ->
      clientSecure++
      return
    )
    client.on "OCSPResponse", (resp) ->
      ocspResponse = resp
      client.destroy()  if resp
      return

    client.on "close", ->
      server.close cb
      return

    return

  process.on "exit", ->
    if testOptions.ocsp is false
      assert.equal requestCount, clientSecure
      assert.equal requestCount, 1
      return
    if testOptions.response
      assert.equal ocspResponse.toString(), testOptions.response
    else
      assert.ok ocspResponse is null
    assert.equal requestCount, (if testOptions.response then 0 else 1)
    assert.equal clientSecure, requestCount
    assert.equal ocspCount, 1
    return

  return
common = require("../common")
unless process.features.tls_ocsp
  console.error "Skipping because node compiled without OpenSSL or " + "with old OpenSSL version."
  process.exit 0
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
assert = require("assert")
tls = require("tls")
constants = require("constants")
fs = require("fs")
join = require("path").join
test
  response: false
, ->
  test
    response: "hello world"
  , ->
    test ocsp: false
    return

  return

