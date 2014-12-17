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

#
# * Input data
# 

#
# * Expected result data
# 

# echo -n 'Hello node world!' | \
# openssl enc -aes-128-cbc -e -K 5333632e722e652e742e4b2e652e5921 \
# -iv 626c616846697a7a3230313142757a7a | xxd -p -c256

# echo -n 'Hello node world!AbC09876dDeFgHi' | \
# openssl enc -aes-128-cbc -e -K 5333632e722e652e742e4b2e652e5921 \
# -iv 626c616846697a7a3230313142757a7a | xxd -p -c256

# echo -n 'Hello node world!AbC09876dDeFgHi' | \
# openssl enc -aes-128-cbc -e -K 5333632e722e652e742e4b2e652e5921 \
# -iv 626c616846697a7a3230313142757a7a -nopad | xxd -p -c256

#
# * Helper wrappers
# 
enc = (plain, pad) ->
  encrypt = crypto.createCipheriv(CIPHER_NAME, KEY_PLAIN, IV_PLAIN)
  encrypt.setAutoPadding pad
  hex = encrypt.update(plain, "ascii", "hex")
  hex += encrypt.final("hex")
  hex
dec = (encd, pad) ->
  decrypt = crypto.createDecipheriv(CIPHER_NAME, KEY_PLAIN, IV_PLAIN)
  decrypt.setAutoPadding pad
  plain = decrypt.update(encd, "hex")
  plain += decrypt.final("binary")
  plain
common = require("../common")
assert = require("assert")
try
  crypto = require("crypto")
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
crypto.DEFAULT_ENCODING = "buffer"
ODD_LENGTH_PLAIN = "Hello node world!"
EVEN_LENGTH_PLAIN = "Hello node world!AbC09876dDeFgHi"
KEY_PLAIN = "S3c.r.e.t.K.e.Y!"
IV_PLAIN = "blahFizz2011Buzz"
CIPHER_NAME = "aes-128-cbc"
ODD_LENGTH_ENCRYPTED = "7f57859550d4d2fdb9806da2a750461a9fe77253cd1cbd4b07beee4e070d561f"
EVEN_LENGTH_ENCRYPTED = "7f57859550d4d2fdb9806da2a750461ab46e71b3d78ebe2d9684dfc87f7575b988" + "6119866912cb8c7bcaf76c5ebc2378"
EVEN_LENGTH_ENCRYPTED_NOPAD = "7f57859550d4d2fdb9806da2a750461ab46e" + "71b3d78ebe2d9684dfc87f7575b9"

#
# * Test encryption
# 
assert.equal enc(ODD_LENGTH_PLAIN, true), ODD_LENGTH_ENCRYPTED
assert.equal enc(EVEN_LENGTH_PLAIN, true), EVEN_LENGTH_ENCRYPTED
assert.throws ->
  
  # input must have block length %
  enc ODD_LENGTH_PLAIN, false
  return

assert.doesNotThrow ->
  assert.equal enc(EVEN_LENGTH_PLAIN, false), EVEN_LENGTH_ENCRYPTED_NOPAD
  return


#
# * Test decryption
# 
assert.equal dec(ODD_LENGTH_ENCRYPTED, true), ODD_LENGTH_PLAIN
assert.equal dec(EVEN_LENGTH_ENCRYPTED, true), EVEN_LENGTH_PLAIN
assert.doesNotThrow ->
  
  # returns including original padding
  assert.equal dec(ODD_LENGTH_ENCRYPTED, false).length, 32
  assert.equal dec(EVEN_LENGTH_ENCRYPTED, false).length, 48
  return

assert.throws ->
  
  # must have at least 1 byte of padding (PKCS):
  assert.equal dec(EVEN_LENGTH_ENCRYPTED_NOPAD, true), EVEN_LENGTH_PLAIN
  return

assert.doesNotThrow ->
  
  # no-pad encrypted string should return the same:
  assert.equal dec(EVEN_LENGTH_ENCRYPTED_NOPAD, false), EVEN_LENGTH_PLAIN
  return

