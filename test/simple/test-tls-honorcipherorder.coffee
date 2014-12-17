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

# test only in TLSv1 to use DES which is no longer supported TLSv1.2
# to be safe when the default method is updated in the future
test = (honorCipherOrder, clientCipher, expectedCipher, cb) ->
  soptions =
    secureProtocol: SSL_Method
    key: fs.readFileSync(common.fixturesDir + "/keys/agent2-key.pem")
    cert: fs.readFileSync(common.fixturesDir + "/keys/agent2-cert.pem")
    ciphers: "DES-CBC-SHA:AES256-SHA:RC4-SHA:ECDHE-RSA-AES256-SHA"
    honorCipherOrder: !!honorCipherOrder

  server = tls.createServer(soptions, (cleartextStream) ->
    nconns++
    
    # End socket to send CLOSE_NOTIFY and TCP FIN packet, otherwise
    # it may hang for ~30 seconds in FIN_WAIT_1 state (at least on OSX).
    cleartextStream.end()
    return
  )
  server.listen common.PORT, localhost, ->
    coptions =
      rejectUnauthorized: false
      secureProtocol: SSL_Method

    coptions.ciphers = clientCipher  if clientCipher
    client = tls.connect(common.PORT, localhost, coptions, ->
      cipher = client.getCipher()
      client.end()
      server.close()
      assert.equal cipher.name, expectedCipher
      cb()  if cb
      return
    )
    return

  return
test1 = ->
  
  # Client has the preference of cipher suites by default
  test false, "AES256-SHA:DES-CBC-SHA:RC4-SHA", "AES256-SHA", test2
  return
test2 = ->
  
  # Server has the preference of cipher suites where DES-CBC-SHA is in
  # the first.
  test true, "AES256-SHA:DES-CBC-SHA:RC4-SHA", "DES-CBC-SHA", test3
  return
test3 = ->
  
  # Server has the preference of cipher suites. RC4-SHA is given
  # higher priority over DES-CBC-SHA among client cipher suites.
  test true, "RC4-SHA:AES256-SHA", "AES256-SHA", test4
  return
test4 = ->
  
  # As client has only one cipher, server has no choice in regardless
  # of honorCipherOrder.
  test true, "RC4-SHA", "RC4-SHA", test5
  return
test5 = ->
  
  # Client did not explicitly set ciphers. Ensure that client defaults to
  # sane ciphers. Even though server gives top priority to DES-CBC-SHA
  # it should not be negotiated because it's not in default client ciphers.
  test true, null, "AES256-SHA", test6
  return
test6 = ->
  
  # Ensure that `tls.DEFAULT_CIPHERS` is used
  SSL_Method = "TLSv1_2_method"
  tls.DEFAULT_CIPHERS = "ECDHE-RSA-AES256-SHA"
  test true, null, "ECDHE-RSA-AES256-SHA"
  return
common = require("../common")
assert = require("assert")
tls = require("tls")
fs = require("fs")
nconns = 0
SSL_Method = "TLSv1_method"
localhost = "127.0.0.1"
process.on "exit", ->
  assert.equal nconns, 6
  return

test1()
