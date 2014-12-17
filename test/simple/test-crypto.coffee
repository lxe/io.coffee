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

# Test Certificates

# TODO(indunty): move to a separate test eventually

# 'this' safety
# https://github.com/joyent/node/issues/6690

# PFX tests

# Test HMAC

# Test HMAC (Wikipedia Test Cases)
# HMACs lifted from Wikipedia.
# Intermediate test to help debugging.
# Intermediate test to help debugging.
# HMACs lifted from Wikipedia.

# Test HMAC-SHA-* (rfc 4231 Test Cases)
# 'Hi There'
# 'Jefe'
# 'what do ya want for nothing?'

# 'Test With Truncation'

# 'Test Using Larger Than Block-Size Key - Hash Key First'

# 'This is a test using a larger than block-size key and a larger ' +
# 'than block-size data. The key needs to be hashed before being ' +
# 'used by the HMAC algorithm.'
# first 128 bits == 32 hex chars

# Test HMAC-MD5/SHA1 (rfc 2202 Test Cases)

# Test hashing
# binary

# stream interface

# stream interface should produce the same result.

# Test multiple updates to same hash

# Test hashing for binary files

# Issue #2227: unknown digest method should throw an error.

# Test signing and verifying
testCipher1 = (key) ->
  
  # Test encryption and decryption
  plaintext = "Keep this a secret? No! Tell everyone about node.js!"
  cipher = crypto.createCipher("aes192", key)
  
  # encrypt plaintext which is in utf8 format
  # to a ciphertext which will be in hex
  ciph = cipher.update(plaintext, "utf8", "hex")
  
  # Only use binary or hex, not base64.
  ciph += cipher.final("hex")
  decipher = crypto.createDecipher("aes192", key)
  txt = decipher.update(ciph, "hex", "utf8")
  txt += decipher.final("utf8")
  assert.equal txt, plaintext, "encryption and decryption"
  
  # streaming cipher interface
  # NB: In real life, it's not guaranteed that you can get all of it
  # in a single read() like this.  But in this case, we know it's
  # quite small, so there's no harm.
  cStream = crypto.createCipher("aes192", key)
  cStream.end plaintext
  ciph = cStream.read()
  dStream = crypto.createDecipher("aes192", key)
  dStream.end ciph
  txt = dStream.read().toString("utf8")
  assert.equal txt, plaintext, "encryption and decryption with streams"
  return
testCipher2 = (key) ->
  
  # encryption and decryption with Base64
  # reported in https://github.com/joyent/node/issues/738
  plaintext = "32|RmVZZkFUVmpRRkp0TmJaUm56ZU9qcnJkaXNNWVNpTTU*|iXmckfRWZBGWWELw" + "eCBsThSsfUHLeRe0KCsK8ooHgxie0zOINpXxfZi/oNG7uq9JWFVCk70gfzQH8ZUJ" + "jAfaFg**"
  cipher = crypto.createCipher("aes256", key)
  
  # encrypt plaintext which is in utf8 format
  # to a ciphertext which will be in Base64
  ciph = cipher.update(plaintext, "utf8", "base64")
  ciph += cipher.final("base64")
  decipher = crypto.createDecipher("aes256", key)
  txt = decipher.update(ciph, "base64", "utf8")
  txt += decipher.final("utf8")
  assert.equal txt, plaintext, "encryption and decryption with Base64"
  return
testCipher3 = (key, iv) ->
  
  # Test encyrption and decryption with explicit key and iv
  plaintext = "32|RmVZZkFUVmpRRkp0TmJaUm56ZU9qcnJkaXNNWVNpTTU*|iXmckfRWZBGWWELw" + "eCBsThSsfUHLeRe0KCsK8ooHgxie0zOINpXxfZi/oNG7uq9JWFVCk70gfzQH8ZUJ" + "jAfaFg**"
  cipher = crypto.createCipheriv("des-ede3-cbc", key, iv)
  ciph = cipher.update(plaintext, "utf8", "hex")
  ciph += cipher.final("hex")
  decipher = crypto.createDecipheriv("des-ede3-cbc", key, iv)
  txt = decipher.update(ciph, "hex", "utf8")
  txt += decipher.final("utf8")
  assert.equal txt, plaintext, "encryption and decryption with key and iv"
  
  # streaming cipher interface
  # NB: In real life, it's not guaranteed that you can get all of it
  # in a single read() like this.  But in this case, we know it's
  # quite small, so there's no harm.
  cStream = crypto.createCipheriv("des-ede3-cbc", key, iv)
  cStream.end plaintext
  ciph = cStream.read()
  dStream = crypto.createDecipheriv("des-ede3-cbc", key, iv)
  dStream.end ciph
  txt = dStream.read().toString("utf8")
  assert.equal txt, plaintext, "streaming cipher iv"
  return
testCipher4 = (key, iv) ->
  
  # Test encyrption and decryption with explicit key and iv
  plaintext = "32|RmVZZkFUVmpRRkp0TmJaUm56ZU9qcnJkaXNNWVNpTTU*|iXmckfRWZBGWWELw" + "eCBsThSsfUHLeRe0KCsK8ooHgxie0zOINpXxfZi/oNG7uq9JWFVCk70gfzQH8ZUJ" + "jAfaFg**"
  cipher = crypto.createCipheriv("des-ede3-cbc", key, iv)
  ciph = cipher.update(plaintext, "utf8", "buffer")
  ciph = Buffer.concat([
    ciph
    cipher.final("buffer")
  ])
  decipher = crypto.createDecipheriv("des-ede3-cbc", key, iv)
  txt = decipher.update(ciph, "buffer", "utf8")
  txt += decipher.final("utf8")
  assert.equal txt, plaintext, "encryption and decryption with key and iv"
  return

# update() should only take buffers / strings

# Test Diffie-Hellman with two parties sharing a secret,
# using various encodings as we go along

# Create "another dh1" using generated keys from dh1,
# and compute secret again

# Run this one twice to make sure that the dh3 clears its error properly

# Create a shared using a DH group.

# Ensure specific generator (buffer) works as expected.

# Ensure specific generator (string with encoding) works as expected.

# Ensure specific generator (string without encoding) works as expected.

# Ensure specific generator (numeric) works as expected.

# Test RSA encryption/decryption
test_rsa = (padding) ->
  input = new Buffer((if padding is "RSA_NO_PADDING" then 1024 / 8 else 32))
  i = 0

  while i < input.length
    input[i] = (i * 7 + 11) & 0xff
    i++
  bufferToEncrypt = new Buffer(input)
  padding = constants[padding]
  encryptedBuffer = crypto.publicEncrypt(
    key: rsaPubPem
    padding: padding
  , bufferToEncrypt)
  decryptedBuffer = crypto.privateDecrypt(
    key: rsaKeyPem
    padding: padding
  , encryptedBuffer)
  assert.equal input, decryptedBuffer.toString()
  return

# Test RSA key signing/verification

# Test RSA key signing/verification with encrypted key

#
# Test RSA signing and verification
#

#
# Test DSA signing and verification
#

# DSA signatures vary across runs so there is no static string to verify
# against

#
# Test DSA signing and verification with encrypted key
#

# DSA signatures vary across runs so there is no static string to verify
# against

#
# Test PBKDF2 with RFC 6070 test vectors (except #4)
#
testPBKDF2 = (password, salt, iterations, keylen, expected) ->
  actual = crypto.pbkdf2Sync(password, salt, iterations, keylen)
  assert.equal actual.toString("binary"), expected
  crypto.pbkdf2 password, salt, iterations, keylen, (err, actual) ->
    assert.equal actual.toString("binary"), expected
    return

  return
assertSorted = (list) ->
  
  # Array#sort() modifies the list in place so make a copy.
  sorted = util._extend([], list).sort()
  assert.deepEqual list, sorted
  return
common = require("../common")
assert = require("assert")
util = require("util")
try
  crypto = require("crypto")
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
crypto.DEFAULT_ENCODING = "buffer"
fs = require("fs")
path = require("path")
constants = require("constants")
caPem = fs.readFileSync(common.fixturesDir + "/test_ca.pem", "ascii")
certPem = fs.readFileSync(common.fixturesDir + "/test_cert.pem", "ascii")
certPfx = fs.readFileSync(common.fixturesDir + "/test_cert.pfx")
keyPem = fs.readFileSync(common.fixturesDir + "/test_key.pem", "ascii")
rsaPubPem = fs.readFileSync(common.fixturesDir + "/test_rsa_pubkey.pem", "ascii")
rsaKeyPem = fs.readFileSync(common.fixturesDir + "/test_rsa_privkey.pem", "ascii")
rsaKeyPemEncrypted = fs.readFileSync(common.fixturesDir + "/test_rsa_privkey_encrypted.pem", "ascii")
dsaPubPem = fs.readFileSync(common.fixturesDir + "/test_dsa_pubkey.pem", "ascii")
dsaKeyPem = fs.readFileSync(common.fixturesDir + "/test_dsa_privkey.pem", "ascii")
dsaKeyPemEncrypted = fs.readFileSync(common.fixturesDir + "/test_dsa_privkey_encrypted.pem", "ascii")
try
  tls = require("tls")
  context = tls.createSecureContext(
    key: keyPem
    cert: certPem
    ca: caPem
  )
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
assert.throws (->
  options =
    key: keyPem
    cert: certPem
    ca: caPem

  credentials = crypto.createCredentials(options)
  context = credentials.context
  notcontext =
    setOptions: context.setOptions
    setKey: context.setKey

  crypto.createCredentials
    secureOptions: 1
  , notcontext
  return
), TypeError
assert.doesNotThrow ->
  tls.createSecureContext
    pfx: certPfx
    passphrase: "sample"

  return

assert.throws (->
  tls.createSecureContext pfx: certPfx
  return
), "mac verify failure"
assert.throws (->
  tls.createSecureContext
    pfx: certPfx
    passphrase: "test"

  return
), "mac verify failure"
assert.throws (->
  tls.createSecureContext
    pfx: "sample"
    passphrase: "test"

  return
), "not enough data"
h1 = crypto.createHmac("sha1", "Node").update("some data").update("to hmac").digest("hex")
assert.equal h1, "19fd6e1ba73d9ed2224dd5094a71babe85d9a892", "test HMAC"
wikipedia = [
  {
    key: "key"
    data: "The quick brown fox jumps over the lazy dog"
    hmac:
      md5: "80070713463e7749b90c2dc24911e275"
      sha1: "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"
      sha256: "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc" + "2d1a3cd8"
  }
  {
    key: "key"
    data: ""
    hmac:
      md5: "63530468a04e386459855da0063b6596"
      sha1: "f42bb0eeb018ebbd4597ae7213711ec60760843f"
      sha256: "5d5d139563c95b5967b9bd9a8c9b233a9dedb45072794cd232dc1b74" + "832607d0"
  }
  {
    key: ""
    data: "The quick brown fox jumps over the lazy dog"
    hmac:
      md5: "ad262969c53bc16032f160081c4a07a0"
      sha1: "2ba7f707ad5f187c412de3106583c3111d668de8"
      sha256: "fb011e6154a19b9a4c767373c305275a5a69e8b68b0b4c9200c383dc" + "ed19a416"
  }
  {
    key: ""
    data: ""
    hmac:
      md5: "74e6f7298a9c2d168935f58c001bad88"
      sha1: "fbdb1d1b18aa6c08324b7d64b71fb76370690e1d"
      sha256: "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c71214" + "4292c5ad"
  }
]
i = 0
l = wikipedia.length

while i < l
  for hash of wikipedia[i]["hmac"]
    result = crypto.createHmac(hash, wikipedia[i]["key"]).update(wikipedia[i]["data"]).digest("hex")
    assert.equal wikipedia[i]["hmac"][hash], result, "Test HMAC-" + hash + ": Test case " + (i + 1) + " wikipedia"
  i++
rfc4231 = [
  {
    key: new Buffer("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b", "hex")
    data: new Buffer("4869205468657265", "hex")
    hmac:
      sha224: "896fb1128abbdf196832107cd49df33f47b4b1169912ba4f53684b22"
      sha256: "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c" + "2e32cff7"
      sha384: "afd03944d84895626b0825f4ab46907f15f9dadbe4101ec682aa034c" + "7cebc59cfaea9ea9076ede7f4af152e8b2fa9cb6"
      sha512: "87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b305" + "45e17cdedaa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f170" + "2e696c203a126854"
  }
  {
    key: new Buffer("4a656665", "hex")
    data: new Buffer("7768617420646f2079612077616e7420666f72206e6f74686" + "96e673f", "hex")
    hmac:
      sha224: "a30e01098bc6dbbf45690f3a7e9e6d0f8bbea2a39e6148008fd05e44"
      sha256: "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b9" + "64ec3843"
      sha384: "af45d2e376484031617f78d2b58a6b1b9c7ef464f5a01b47e42ec373" + "6322445e8e2240ca5e69e2c78b3239ecfab21649"
      sha512: "164b7a7bfcf819e2e395fbe73b56e0a387bd64222e831fd610270cd7" + "ea2505549758bf75c05a994a6d034f65f8f0e6fdcaeab1a34d4a6b4b" + "636e070a38bce737"
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "hex")
    data: new Buffer("ddddddddddddddddddddddddddddddddddddddddddddddddd" + "ddddddddddddddddddddddddddddddddddddddddddddddddddd", "hex")
    hmac:
      sha224: "7fb3cb3588c6c1f6ffa9694d7d6ad2649365b0c1f65d69d1ec8333ea"
      sha256: "773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514" + "ced565fe"
      sha384: "88062608d3e6ad8a0aa2ace014c8a86f0aa635d947ac9febe83ef4e5" + "5966144b2a5ab39dc13814b94e3ab6e101a34f27"
      sha512: "fa73b0089d56a284efb0f0756c890be9b1b5dbdd8ee81a3655f83e33" + "b2279d39bf3e848279a722c806b485a47e67c807b946a337bee89426" + "74278859e13292fb"
  }
  {
    key: new Buffer("0102030405060708090a0b0c0d0e0f10111213141516171819", "hex")
    data: new Buffer("cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc" + "dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd", "hex")
    hmac:
      sha224: "6c11506874013cac6a2abc1bb382627cec6a90d86efc012de7afec5a"
      sha256: "82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff4" + "6729665b"
      sha384: "3e8a69b7783c25851933ab6290af6ca77a9981480850009cc5577c6e" + "1f573b4e6801dd23c4a7d679ccf8a386c674cffb"
      sha512: "b0ba465637458c6990e5a8c5f61d4af7e576d97ff94b872de76f8050" + "361ee3dba91ca5c11aa25eb4d679275cc5788063a5f19741120c4f2d" + "e2adebeb10a298dd"
  }
  {
    key: new Buffer("0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c", "hex")
    data: new Buffer("546573742057697468205472756e636174696f6e", "hex")
    hmac:
      sha224: "0e2aea68a90c8d37c988bcdb9fca6fa8"
      sha256: "a3b6167473100ee06e0c796c2955552b"
      sha384: "3abf34c3503b2a23a46efc619baef897"
      sha512: "415fad6271580a531d4179bc891d87a6"

    truncate: true
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaa", "hex")
    data: new Buffer("54657374205573696e67204c6172676572205468616e20426" + "c6f636b2d53697a65204b6579202d2048617368204b657920" + "4669727374", "hex")
    hmac:
      sha224: "95e9a0db962095adaebe9b2d6f0dbce2d499f112f2d2b7273fa6870e"
      sha256: "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f" + "0ee37f54"
      sha384: "4ece084485813e9088d2c63a041bc5b44f9ef1012a2b588f3cd11f05" + "033ac4c60c2ef6ab4030fe8296248df163f44952"
      sha512: "80b24263c7c1a3ebb71493c1dd7be8b49b46d1f41b4aeec1121b0137" + "83f8f3526b56d037e05f2598bd0fd2215d6a1e5295e64f73f63f0aec" + "8b915a985d786598"
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaa", "hex")
    data: new Buffer("5468697320697320612074657374207573696e672061206c6" + "172676572207468616e20626c6f636b2d73697a65206b6579" + "20616e642061206c6172676572207468616e20626c6f636b2" + "d73697a6520646174612e20546865206b6579206e65656473" + "20746f20626520686173686564206265666f7265206265696" + "e6720757365642062792074686520484d414320616c676f72" + "6974686d2e", "hex")
    hmac:
      sha224: "3a854166ac5d9f023f54d517d0b39dbd946770db9c2b95c9f6f565d1"
      sha256: "9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f5153" + "5c3a35e2"
      sha384: "6617178e941f020d351e2f254e8fd32c602420feb0b8fb9adccebb82" + "461e99c5a678cc31e799176d3860e6110c46523e"
      sha512: "e37b6a775dc87dbaa4dfa9f96e5e3ffddebd71f8867289865df5a32d" + "20cdc944b6022cac3c4982b10d5eeb55c3e4de15134676fb6de04460" + "65c97440fa8c6a58"
  }
]
i = 0
l = rfc4231.length

while i < l
  for hash of rfc4231[i]["hmac"]
    str = crypto.createHmac(hash, rfc4231[i].key)
    str.end rfc4231[i].data
    strRes = str.read().toString("hex")
    result = crypto.createHmac(hash, rfc4231[i]["key"]).update(rfc4231[i]["data"]).digest("hex")
    if rfc4231[i]["truncate"]
      result = result.substr(0, 32)
      strRes = strRes.substr(0, 32)
    assert.equal rfc4231[i]["hmac"][hash], result, "Test HMAC-" + hash + ": Test case " + (i + 1) + " rfc 4231"
    assert.equal strRes, result, "Should get same result from stream"
  i++
rfc2202_md5 = [
  {
    key: new Buffer("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b", "hex")
    data: "Hi There"
    hmac: "9294727a3638bb1c13f48ef8158bfc9d"
  }
  {
    key: "Jefe"
    data: "what do ya want for nothing?"
    hmac: "750c783e6ab0b503eaa86e310a5db738"
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "hex")
    data: new Buffer("ddddddddddddddddddddddddddddddddddddddddddddddddd" + "ddddddddddddddddddddddddddddddddddddddddddddddddddd", "hex")
    hmac: "56be34521d144c88dbb8c733f0e8b3f6"
  }
  {
    key: new Buffer("0102030405060708090a0b0c0d0e0f10111213141516171819", "hex")
    data: new Buffer("cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc" + "dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" + "cdcdcdcdcd", "hex")
    hmac: "697eaf0aca3a3aea3a75164746ffaa79"
  }
  {
    key: new Buffer("0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c", "hex")
    data: "Test With Truncation"
    hmac: "56461ef2342edc00f9bab995690efd4c"
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaa", "hex")
    data: "Test Using Larger Than Block-Size Key - Hash Key First"
    hmac: "6b1ab7fe4bd7bf8f0b62e6ce61b9d0cd"
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaa", "hex")
    data: "Test Using Larger Than Block-Size Key and Larger Than One " + "Block-Size Data"
    hmac: "6f630fad67cda0ee1fb1f562db3aa53e"
  }
]
rfc2202_sha1 = [
  {
    key: new Buffer("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b", "hex")
    data: "Hi There"
    hmac: "b617318655057264e28bc0b6fb378c8ef146be00"
  }
  {
    key: "Jefe"
    data: "what do ya want for nothing?"
    hmac: "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79"
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "hex")
    data: new Buffer("ddddddddddddddddddddddddddddddddddddddddddddd" + "ddddddddddddddddddddddddddddddddddddddddddddd" + "dddddddddd", "hex")
    hmac: "125d7342b9ac11cd91a39af48aa17b4f63f175d3"
  }
  {
    key: new Buffer("0102030405060708090a0b0c0d0e0f10111213141516171819", "hex")
    data: new Buffer("cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc" + "dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" + "cdcdcdcdcd", "hex")
    hmac: "4c9007f4026250c6bc8414f9bf50c86c2d7235da"
  }
  {
    key: new Buffer("0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c", "hex")
    data: "Test With Truncation"
    hmac: "4c1a03424b55e07fe7f27be1d58bb9324a9a5a04"
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaa", "hex")
    data: "Test Using Larger Than Block-Size Key - Hash Key First"
    hmac: "aa4ae5e15272d00e95705637ce8a3b55ed402112"
  }
  {
    key: new Buffer("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + "aaaaaaaaaaaaaaaaaaaaaa", "hex")
    data: "Test Using Larger Than Block-Size Key and Larger Than One " + "Block-Size Data"
    hmac: "e8e99d0f45237d786d6bbaa7965c7808bbff1a91"
  }
]
i = 0
l = rfc2202_md5.length

while i < l
  assert.equal rfc2202_md5[i]["hmac"], crypto.createHmac("md5", rfc2202_md5[i]["key"]).update(rfc2202_md5[i]["data"]).digest("hex"), "Test HMAC-MD5 : Test case " + (i + 1) + " rfc 2202"
  i++
i = 0
l = rfc2202_sha1.length

while i < l
  assert.equal rfc2202_sha1[i]["hmac"], crypto.createHmac("sha1", rfc2202_sha1[i]["key"]).update(rfc2202_sha1[i]["data"]).digest("hex"), "Test HMAC-SHA1 : Test case " + (i + 1) + " rfc 2202"
  i++
a0 = crypto.createHash("sha1").update("Test123").digest("hex")
a1 = crypto.createHash("md5").update("Test123").digest("binary")
a2 = crypto.createHash("sha256").update("Test123").digest("base64")
a3 = crypto.createHash("sha512").update("Test123").digest()
a4 = crypto.createHash("sha1").update("Test123").digest("buffer")
a5 = crypto.createHash("sha512")
a5.end "Test123"
a5 = a5.read()
a6 = crypto.createHash("sha512")
a6.write "Te"
a6.write "st"
a6.write "123"
a6.end()
a6 = a6.read()
a7 = crypto.createHash("sha512")
a7.end()
a7 = a7.read()
a8 = crypto.createHash("sha512")
a8.write ""
a8.end()
a8 = a8.read()
assert.equal a0, "8308651804facb7b9af8ffc53a33a22d6a1c8ac2", "Test SHA1"
assert.equal a1, "hêËØo\fF!ú+\u000e\u0017Ê" + "½", "Test MD5 as binary"
assert.equal a2, "2bX1jws4GYKTlxhloUB09Z66PoJZW+y+hq5R8dnx9l4=", "Test SHA256 as base64"
assert.deepEqual a3, new Buffer("Á(4ñ\u0003\u001fd!O'ÔC/&QzÔ" + "\u0015l¸Q+Û\u001dÄµ}²" + "Ö£ß¢i¡\n\n*\u000f" + "×Ö¢¨ã<" + "Â\u0006Ú0¡9(Gí'", "binary"), "Test SHA512 as assumed buffer"
assert.deepEqual a4, new Buffer("8308651804facb7b9af8ffc53a33a22d6a1c8ac2", "hex"), "Test SHA1"
assert.deepEqual a5, a3, "stream interface is consistent"
assert.deepEqual a6, a3, "stream interface is consistent"
assert.notEqual a7, `undefined`, "no data should return data"
assert.notEqual a8, `undefined`, "empty string should generate data"
h1 = crypto.createHash("sha1").update("Test123").digest("hex")
h2 = crypto.createHash("sha1").update("Test").update("123").digest("hex")
assert.equal h1, h2, "multipled updates"
fn = path.join(common.fixturesDir, "sample.png")
sha1Hash = crypto.createHash("sha1")
fileStream = fs.createReadStream(fn)
fileStream.on "data", (data) ->
  sha1Hash.update data
  return

fileStream.on "close", ->
  assert.equal sha1Hash.digest("hex"), "22723e553129a336ad96e10f6aecdf0f45e4149e", "Test SHA1 of sample.png"
  return

assert.throws ->
  crypto.createHash "xyzzy"
  return

s1 = crypto.createSign("RSA-SHA1").update("Test123").sign(keyPem, "base64")
s1stream = crypto.createSign("RSA-SHA1")
s1stream.end "Test123"
s1stream = s1stream.sign(keyPem, "base64")
assert.equal s1, s1stream, "Stream produces same output"
verified = crypto.createVerify("RSA-SHA1").update("Test").update("123").verify(certPem, s1, "base64")
assert.strictEqual verified, true, "sign and verify (base 64)"
s2 = crypto.createSign("RSA-SHA256").update("Test123").sign(keyPem, "binary")
s2stream = crypto.createSign("RSA-SHA256")
s2stream.end "Test123"
s2stream = s2stream.sign(keyPem, "binary")
assert.equal s2, s2stream, "Stream produces same output"
verified = crypto.createVerify("RSA-SHA256").update("Test").update("123").verify(certPem, s2, "binary")
assert.strictEqual verified, true, "sign and verify (binary)"
verStream = crypto.createVerify("RSA-SHA256")
verStream.write "Tes"
verStream.write "t12"
verStream.end "3"
verified = verStream.verify(certPem, s2, "binary")
assert.strictEqual verified, true, "sign and verify (stream)"
s3 = crypto.createSign("RSA-SHA1").update("Test123").sign(keyPem, "buffer")
verified = crypto.createVerify("RSA-SHA1").update("Test").update("123").verify(certPem, s3)
assert.strictEqual verified, true, "sign and verify (buffer)"
verStream = crypto.createVerify("RSA-SHA1")
verStream.write "Tes"
verStream.write "t12"
verStream.end "3"
verified = verStream.verify(certPem, s3)
assert.strictEqual verified, true, "sign and verify (stream)"
testCipher1 "MySecretKey123"
testCipher1 new Buffer("MySecretKey123")
testCipher2 "0123456789abcdef"
testCipher2 new Buffer("0123456789abcdef")
testCipher3 "0123456789abcd0123456789", "12345678"
testCipher3 "0123456789abcd0123456789", new Buffer("12345678")
testCipher3 new Buffer("0123456789abcd0123456789"), "12345678"
testCipher3 new Buffer("0123456789abcd0123456789"), new Buffer("12345678")
testCipher4 new Buffer("0123456789abcd0123456789"), new Buffer("12345678")
assert.throws (->
  crypto.createHash("sha1").update foo: "bar"
  return
), /buffer/
dh1 = crypto.createDiffieHellman(256)
p1 = dh1.getPrime("buffer")
dh2 = crypto.createDiffieHellman(p1, "buffer")
key1 = dh1.generateKeys()
key2 = dh2.generateKeys("hex")
secret1 = dh1.computeSecret(key2, "hex", "base64")
secret2 = dh2.computeSecret(key1, "binary", "buffer")
assert.equal secret1, secret2.toString("base64")
assert.equal dh1.verifyError, 0
assert.equal dh2.verifyError, 0
assert.throws ->
  crypto.createDiffieHellman [
    0x1
    0x2
  ]
  return

assert.throws ->
  crypto.createDiffieHellman ->

  return

assert.throws ->
  crypto.createDiffieHellman /abc/
  return

assert.throws ->
  crypto.createDiffieHellman {}
  return

dh3 = crypto.createDiffieHellman(p1, "buffer")
privkey1 = dh1.getPrivateKey()
dh3.setPublicKey key1
dh3.setPrivateKey privkey1
assert.deepEqual dh1.getPrime(), dh3.getPrime()
assert.deepEqual dh1.getGenerator(), dh3.getGenerator()
assert.deepEqual dh1.getPublicKey(), dh3.getPublicKey()
assert.deepEqual dh1.getPrivateKey(), dh3.getPrivateKey()
assert.equal dh3.verifyError, 0
secret3 = dh3.computeSecret(key2, "hex", "base64")
assert.equal secret1, secret3
(->
  c = crypto.createDecipher("aes-128-ecb", "")
  assert.throws (->
    c.final "utf8"
    return
  ), /wrong final block length/
  return
)()
assert.throws (->
  dh3.computeSecret ""
  return
), /key is too small/i
(->
  c = crypto.createDecipher("aes-128-ecb", "")
  assert.throws (->
    c.final "utf8"
    return
  ), /wrong final block length/
  return
)()
alice = crypto.createDiffieHellmanGroup("modp5")
bob = crypto.createDiffieHellmanGroup("modp5")
alice.generateKeys()
bob.generateKeys()
aSecret = alice.computeSecret(bob.getPublicKey()).toString("hex")
bSecret = bob.computeSecret(alice.getPublicKey()).toString("hex")
assert.equal aSecret, bSecret
assert.equal alice.verifyError, constants.DH_NOT_SUITABLE_GENERATOR
assert.equal bob.verifyError, constants.DH_NOT_SUITABLE_GENERATOR
modp1 = crypto.createDiffieHellmanGroup("modp1")
modp1buf = new Buffer([
  0xff
  0xff
  0xff
  0xff
  0xff
  0xff
  0xff
  0xff
  0xc9
  0x0f
  0xda
  0xa2
  0x21
  0x68
  0xc2
  0x34
  0xc4
  0xc6
  0x62
  0x8b
  0x80
  0xdc
  0x1c
  0xd1
  0x29
  0x02
  0x4e
  0x08
  0x8a
  0x67
  0xcc
  0x74
  0x02
  0x0b
  0xbe
  0xa6
  0x3b
  0x13
  0x9b
  0x22
  0x51
  0x4a
  0x08
  0x79
  0x8e
  0x34
  0x04
  0xdd
  0xef
  0x95
  0x19
  0xb3
  0xcd
  0x3a
  0x43
  0x1b
  0x30
  0x2b
  0x0a
  0x6d
  0xf2
  0x5f
  0x14
  0x37
  0x4f
  0xe1
  0x35
  0x6d
  0x6d
  0x51
  0xc2
  0x45
  0xe4
  0x85
  0xb5
  0x76
  0x62
  0x5e
  0x7e
  0xc6
  0xf4
  0x4c
  0x42
  0xe9
  0xa6
  0x3a
  0x36
  0x20
  0xff
  0xff
  0xff
  0xff
  0xff
  0xff
  0xff
  0xff
])
exmodp1 = crypto.createDiffieHellman(modp1buf, new Buffer([2]))
modp1.generateKeys()
exmodp1.generateKeys()
modp1Secret = modp1.computeSecret(exmodp1.getPublicKey()).toString("hex")
exmodp1Secret = exmodp1.computeSecret(modp1.getPublicKey()).toString("hex")
assert.equal modp1Secret, exmodp1Secret
assert.equal modp1.verifyError, constants.DH_NOT_SUITABLE_GENERATOR
assert.equal exmodp1.verifyError, constants.DH_NOT_SUITABLE_GENERATOR
exmodp1_2 = crypto.createDiffieHellman(modp1buf, "02", "hex")
exmodp1_2.generateKeys()
modp1Secret = modp1.computeSecret(exmodp1_2.getPublicKey()).toString("hex")
exmodp1_2Secret = exmodp1_2.computeSecret(modp1.getPublicKey()).toString("hex")
assert.equal modp1Secret, exmodp1_2Secret
assert.equal exmodp1_2.verifyError, constants.DH_NOT_SUITABLE_GENERATOR
exmodp1_3 = crypto.createDiffieHellman(modp1buf, "\u0002")
exmodp1_3.generateKeys()
modp1Secret = modp1.computeSecret(exmodp1_3.getPublicKey()).toString("hex")
exmodp1_3Secret = exmodp1_3.computeSecret(modp1.getPublicKey()).toString("hex")
assert.equal modp1Secret, exmodp1_3Secret
assert.equal exmodp1_3.verifyError, constants.DH_NOT_SUITABLE_GENERATOR
exmodp1_4 = crypto.createDiffieHellman(modp1buf, 2)
exmodp1_4.generateKeys()
modp1Secret = modp1.computeSecret(exmodp1_4.getPublicKey()).toString("hex")
exmodp1_4Secret = exmodp1_4.computeSecret(modp1.getPublicKey()).toString("hex")
assert.equal modp1Secret, exmodp1_4Secret
assert.equal exmodp1_4.verifyError, constants.DH_NOT_SUITABLE_GENERATOR
p = "FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74" + "020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F1437" + "4FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED" + "EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381FFFFFFFFFFFFFFFF"
bad_dh = crypto.createDiffieHellman(p, "hex")
assert.equal bad_dh.verifyError, constants.DH_NOT_SUITABLE_GENERATOR
(->
  input = "I AM THE WALRUS"
  bufferToEncrypt = new Buffer(input)
  encryptedBuffer = crypto.publicEncrypt(rsaPubPem, bufferToEncrypt)
  decryptedBuffer = crypto.privateDecrypt(rsaKeyPem, encryptedBuffer)
  assert.equal input, decryptedBuffer.toString()
  decryptedBufferWithPassword = crypto.privateDecrypt(
    key: rsaKeyPemEncrypted
    passphrase: "password"
  , encryptedBuffer)
  assert.equal input, decryptedBufferWithPassword.toString()
  encryptedBuffer = crypto.publicEncrypt(certPem, bufferToEncrypt)
  decryptedBuffer = crypto.privateDecrypt(keyPem, encryptedBuffer)
  assert.equal input, decryptedBuffer.toString()
  encryptedBuffer = crypto.publicEncrypt(keyPem, bufferToEncrypt)
  decryptedBuffer = crypto.privateDecrypt(keyPem, encryptedBuffer)
  assert.equal input, decryptedBuffer.toString()
  assert.throws ->
    crypto.privateDecrypt
      key: rsaKeyPemEncrypted
      passphrase: "wrong"
    , encryptedBuffer
    return

  return
)()
test_rsa "RSA_NO_PADDING"
test_rsa "RSA_PKCS1_PADDING"
test_rsa "RSA_PKCS1_OAEP_PADDING"
rsaSign = crypto.createSign("RSA-SHA1")
rsaVerify = crypto.createVerify("RSA-SHA1")
assert.ok rsaSign
assert.ok rsaVerify
rsaSign.update rsaPubPem
rsaSignature = rsaSign.sign(rsaKeyPem, "hex")
assert.equal rsaSignature, "5c50e3145c4e2497aadb0eabc83b342d0b0021ece0d4c4a064b7c" + "8f020d7e2688b122bfb54c724ac9ee169f83f66d2fe90abeb95e8" + "e1290e7e177152a4de3d944cf7d4883114a20ed0f78e70e25ef0f" + "60f06b858e6af42a2f276ede95bbc6bc9a9bbdda15bd663186a6f" + "40819a7af19e577bb2efa5e579a1f5ce8a0d4ca8b8f6"
rsaVerify.update rsaPubPem
assert.strictEqual rsaVerify.verify(rsaPubPem, rsaSignature, "hex"), true
rsaSign = crypto.createSign("RSA-SHA1")
rsaSign.update rsaPubPem
assert.doesNotThrow ->
  signOptions =
    key: rsaKeyPemEncrypted
    passphrase: "password"

  rsaSignature = rsaSign.sign(signOptions, "hex")
  return

assert.equal rsaSignature, "5c50e3145c4e2497aadb0eabc83b342d0b0021ece0d4c4a064b7c" + "8f020d7e2688b122bfb54c724ac9ee169f83f66d2fe90abeb95e8" + "e1290e7e177152a4de3d944cf7d4883114a20ed0f78e70e25ef0f" + "60f06b858e6af42a2f276ede95bbc6bc9a9bbdda15bd663186a6f" + "40819a7af19e577bb2efa5e579a1f5ce8a0d4ca8b8f6"
rsaVerify = crypto.createVerify("RSA-SHA1")
rsaVerify.update rsaPubPem
assert.strictEqual rsaVerify.verify(rsaPubPem, rsaSignature, "hex"), true
rsaSign = crypto.createSign("RSA-SHA1")
rsaSign.update rsaPubPem
assert.throws ->
  signOptions =
    key: rsaKeyPemEncrypted
    passphrase: "wrong"

  rsaSign.sign signOptions, "hex"
  return

(->
  privateKey = fs.readFileSync(common.fixturesDir + "/test_rsa_privkey_2.pem")
  publicKey = fs.readFileSync(common.fixturesDir + "/test_rsa_pubkey_2.pem")
  input = "I AM THE WALRUS"
  signature = "79d59d34f56d0e94aa6a3e306882b52ed4191f07521f25f505a078dc2f89" + "396e0c8ac89e996fde5717f4cb89199d8fec249961fcb07b74cd3d2a4ffa" + "235417b69618e4bcd76b97e29975b7ce862299410e1b522a328e44ac9bb2" + "8195e0268da7eda23d9825ac43c724e86ceeee0d0d4465678652ccaf6501" + "0ddfb299bedeb1ad"
  sign = crypto.createSign("RSA-SHA256")
  sign.update input
  output = sign.sign(privateKey, "hex")
  assert.equal output, signature
  verify = crypto.createVerify("RSA-SHA256")
  verify.update input
  assert.strictEqual verify.verify(publicKey, signature, "hex"), true
  return
)()
(->
  input = "I AM THE WALRUS"
  sign = crypto.createSign("DSS1")
  sign.update input
  signature = sign.sign(dsaKeyPem, "hex")
  verify = crypto.createVerify("DSS1")
  verify.update input
  assert.strictEqual verify.verify(dsaPubPem, signature, "hex"), true
  return
)()
(->
  input = "I AM THE WALRUS"
  sign = crypto.createSign("DSS1")
  sign.update input
  assert.throws ->
    sign.sign
      key: dsaKeyPemEncrypted
      passphrase: "wrong"
    , "hex"
    return

  sign = crypto.createSign("DSS1")
  sign.update input
  signature = undefined
  assert.doesNotThrow ->
    signOptions =
      key: dsaKeyPemEncrypted
      passphrase: "password"

    signature = sign.sign(signOptions, "hex")
    return

  verify = crypto.createVerify("DSS1")
  verify.update input
  assert.strictEqual verify.verify(dsaPubPem, signature, "hex"), true
  return
)()
testPBKDF2 "password", "salt", 1, 20, "\f`È\u000f\u001f\u000eqó©µ$" + "¯`\u0012\u0006/à7¦"
testPBKDF2 "password", "salt", 2, 20, "êl\u0001MÇ-oÍ\u001eÙ*" + "Î\u001dAðØÞW"
testPBKDF2 "password", "salt", 4096, 20, "K\u0000y\u0001·eH¾­IÙ&" + "÷!Ðe¤)Á"
testPBKDF2 "passwordPASSWORDpassword", "saltSALTsaltSALTsaltSALTsaltSALTsalt", 4096, 25, "=.ìOä\u001cÈØ6b" + "ÀäJ)\u001aLòðp8"
testPBKDF2 "pass\u0000word", "sa\u0000lt", 4096, 16, "Vúj§UH\tÌ7×ð4" + "%àÃ"
(->
  ondone = (err, key) ->
    throw err  if err
    assert.equal key.toString("hex"), expected
    return
  expected = "64c486c55d30d4c5a079b8823b7d7cb37ff0556f537da8410233bcec330ed956"
  key = crypto.pbkdf2Sync("password", "salt", 32, 32, "sha256")
  assert.equal key.toString("hex"), expected
  crypto.pbkdf2 "password", "salt", 32, 32, "sha256", common.mustCall(ondone)
  return
)()

# Assume that we have at least AES-128-CBC.
assert.notEqual 0, crypto.getCiphers().length
assert.notEqual -1, crypto.getCiphers().indexOf("aes-128-cbc")
assert.equal -1, crypto.getCiphers().indexOf("AES-128-CBC")
assertSorted crypto.getCiphers()

# Assume that we have at least AES256-SHA.
tls = require("tls")
assert.notEqual 0, tls.getCiphers().length
assert.notEqual -1, tls.getCiphers().indexOf("aes256-sha")
assert.equal -1, tls.getCiphers().indexOf("AES256-SHA")
assertSorted tls.getCiphers()

# Assert that we have sha and sha1 but not SHA and SHA1.
assert.notEqual 0, crypto.getHashes().length
assert.notEqual -1, crypto.getHashes().indexOf("sha1")
assert.notEqual -1, crypto.getHashes().indexOf("sha")
assert.equal -1, crypto.getHashes().indexOf("SHA1")
assert.equal -1, crypto.getHashes().indexOf("SHA")
assert.notEqual -1, crypto.getHashes().indexOf("RSA-SHA1")
assert.equal -1, crypto.getHashes().indexOf("rsa-sha1")
assertSorted crypto.getHashes()

# Base64 padding regression test, see #4837.
(->
  c = crypto.createCipher("aes-256-cbc", "secret")
  s = c.update("test", "utf8", "base64") + c.final("base64")
  assert.equal s, "375oxUQCIocvxmC5At+rvA=="
  return
)()

# Error path should not leak memory (check with valgrind).
assert.throws ->
  crypto.pbkdf2 "password", "salt", 1, 20, null
  return


# Calling Cipher.final() or Decipher.final() twice should error but
# not assert. See #4886.
(->
  c = crypto.createCipher("aes-256-cbc", "secret")
  try # Ignore.
    c.final "xxx"
  try # Ignore.
    c.final "xxx"
  try # Ignore.
    c.final "xxx"
  d = crypto.createDecipher("aes-256-cbc", "secret")
  try # Ignore.
    d.final "xxx"
  try # Ignore.
    d.final "xxx"
  try # Ignore.
    d.final "xxx"
  return
)()

# Regression test for #5482: string to Cipher#update() should not assert.
(->
  c = crypto.createCipher("aes192", "0123456789abcdef")
  c.update "update"
  c.final()
  return
)()

# #5655 regression tests, 'utf-8' and 'utf8' are identical.
(->
  c = crypto.createCipher("aes192", "0123456789abcdef")
  c.update "update", "" # Defaults to "utf8".
  c.final "utf-8" # Should not throw.
  c = crypto.createCipher("aes192", "0123456789abcdef")
  c.update "update", "utf8"
  c.final "utf-8" # Should not throw.
  c = crypto.createCipher("aes192", "0123456789abcdef")
  c.update "update", "utf-8"
  c.final "utf8" # Should not throw.
  return
)()

# Regression tests for #5725: hex input that's not a power of two should
# throw, not assert in C++ land.
assert.throws (->
  crypto.createCipher("aes192", "test").update "0", "hex"
  return
), /Bad input string/
assert.throws (->
  crypto.createDecipher("aes192", "test").update "0", "hex"
  return
), /Bad input string/
assert.throws (->
  crypto.createHash("sha1").update "0", "hex"
  return
), /Bad input string/
assert.throws (->
  crypto.createSign("RSA-SHA1").update "0", "hex"
  return
), /Bad input string/
assert.throws (->
  crypto.createVerify("RSA-SHA1").update "0", "hex"
  return
), /Bad input string/
assert.throws (->
  private_ = [
    "-----BEGIN RSA PRIVATE KEY-----"
    "MIGrAgEAAiEA+3z+1QNF2/unumadiwEr+C5vfhezsb3hp4jAnCNRpPcCAwEAAQIgQNriSQK4"
    "EFwczDhMZp2dvbcz7OUUyt36z3S4usFPHSECEQD/41K7SujrstBfoCPzwC1xAhEA+5kt4BJy"
    "eKN7LggbF3Dk5wIQN6SL+fQ5H/+7NgARsVBp0QIRANxYRukavs4QvuyNhMx+vrkCEQCbf6j/"
    "Ig6/HueCK/0Jkmp+"
    "-----END RSA PRIVATE KEY-----"
    ""
  ].join("\n")
  crypto.createSign("RSA-SHA256").update("test").sign private_
  return
), /RSA_sign:digest too big for rsa key/

# Make sure memory isn't released before being returned
console.log crypto.randomBytes(16)

# Test ECDH
ecdh1 = crypto.createECDH("prime256v1")
ecdh2 = crypto.createECDH("prime256v1")
key1 = ecdh1.generateKeys()
key2 = ecdh2.generateKeys("hex")
secret1 = ecdh1.computeSecret(key2, "hex", "base64")
secret2 = ecdh2.computeSecret(key1, "binary", "buffer")
assert.equal secret1, secret2.toString("base64")

# Point formats
assert.equal ecdh1.getPublicKey("buffer", "uncompressed")[0], 4
firstByte = ecdh1.getPublicKey("buffer", "compressed")[0]
assert firstByte is 2 or firstByte is 3
firstByte = ecdh1.getPublicKey("buffer", "hybrid")[0]
assert firstByte is 6 or firstByte is 7

# ECDH should check that point is on curve
ecdh3 = crypto.createECDH("secp256k1")
key3 = ecdh3.generateKeys()
assert.throws ->
  secret3 = ecdh2.computeSecret(key3, "binary", "buffer")
  return


# ECDH should allow .setPrivateKey()/.setPublicKey()
ecdh4 = crypto.createECDH("prime256v1")
ecdh4.setPrivateKey ecdh1.getPrivateKey()
ecdh4.setPublicKey ecdh1.getPublicKey()
assert.throws ->
  ecdh4.setPublicKey ecdh3.getPublicKey()
  return

