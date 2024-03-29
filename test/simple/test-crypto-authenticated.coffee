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
try
  crypto = require("crypto")
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
crypto.DEFAULT_ENCODING = "buffer"

#
# Test authenticated encryption modes.
#
# !NEVER USE STATIC IVs IN REAL LIFE!
#
TEST_CASES = [
  {
    algo: "aes-128-gcm"
    key: "6970787039613669314d623455536234"
    iv: "583673497131313748307652"
    plain: "Hello World!"
    ct: "4BE13896F64DFA2C2D0F2C76"
    tag: "272B422F62EB545EAA15B5FF84092447"
    tampered: false
  }
  {
    algo: "aes-128-gcm"
    key: "6970787039613669314d623455536234"
    iv: "583673497131313748307652"
    plain: "Hello World!"
    ct: "4BE13896F64DFA2C2D0F2C76"
    aad: "000000FF"
    tag: "BA2479F66275665A88CB7B15F43EB005"
    tampered: false
  }
  {
    algo: "aes-128-gcm"
    key: "6970787039613669314d623455536234"
    iv: "583673497131313748307652"
    plain: "Hello World!"
    ct: "4BE13596F64DFA2C2D0FAC76"
    tag: "272B422F62EB545EAA15B5FF84092447"
    tampered: true
  }
  {
    algo: "aes-256-gcm"
    key: "337a54767a7233703637564336316a6d56353472495975313534357834546c59"
    iv: "36306950306836764a6f4561"
    plain: "Hello node.js world!"
    ct: "58E62CFE7B1D274111A82267EBB93866E72B6C2A"
    tag: "9BB44F663BADABACAE9720881FB1EC7A"
    tampered: false
  }
  {
    algo: "aes-256-gcm"
    key: "337a54767a7233703637564336316a6d56353472495975313534357834546c59"
    iv: "36306950306836764a6f4561"
    plain: "Hello node.js world!"
    ct: "58E62CFF7B1D274011A82267EBB93866E72B6C2B"
    tag: "9BB44F663BADABACAE9720881FB1EC7A"
    tampered: true
  }
  {
    algo: "aes-192-gcm"
    key: "1ed2233fa2223ef5d7df08546049406c7305220bca40d4c9"
    iv: "0e1791e9db3bd21a9122c416"
    plain: "Hello node.js world!"
    password: "very bad password"
    aad: "63616c76696e"
    ct: "DDA53A4059AA17B88756984995F7BBA3C636CC44"
    tag: "D2A35E5C611E5E3D2258360241C5B045"
    tampered: false
  }
]
ciphers = crypto.getCiphers()
for i of TEST_CASES
  test = TEST_CASES[i]
  if ciphers.indexOf(test.algo) is -1
    console.log "skipping unsupported " + test.algo + " test"
    continue
  (->
    encrypt = crypto.createCipheriv(test.algo, new Buffer(test.key, "hex"), new Buffer(test.iv, "hex"))
    encrypt.setAAD new Buffer(test.aad, "hex")  if test.aad
    hex = encrypt.update(test.plain, "ascii", "hex")
    hex += encrypt.final("hex")
    auth_tag = encrypt.getAuthTag()
    
    # only test basic encryption run if output is marked as tampered.
    unless test.tampered
      assert.equal hex.toUpperCase(), test.ct
      assert.equal auth_tag.toString("hex").toUpperCase(), test.tag
    return
  )()
  (->
    decrypt = crypto.createDecipheriv(test.algo, new Buffer(test.key, "hex"), new Buffer(test.iv, "hex"))
    decrypt.setAuthTag new Buffer(test.tag, "hex")
    decrypt.setAAD new Buffer(test.aad, "hex")  if test.aad
    msg = decrypt.update(test.ct, "hex", "ascii")
    unless test.tampered
      msg += decrypt.final("ascii")
      assert.equal msg, test.plain
    else
      
      # assert that final throws if input data could not be verified!
      assert.throws (->
        decrypt.final "ascii"
        return
      ), RegExp(" auth")
    return
  )()
  (->
    return  unless test.password
    encrypt = crypto.createCipher(test.algo, test.password)
    encrypt.setAAD new Buffer(test.aad, "hex")  if test.aad
    hex = encrypt.update(test.plain, "ascii", "hex")
    hex += encrypt.final("hex")
    auth_tag = encrypt.getAuthTag()
    
    # only test basic encryption run if output is marked as tampered.
    unless test.tampered
      assert.equal hex.toUpperCase(), test.ct
      assert.equal auth_tag.toString("hex").toUpperCase(), test.tag
    return
  )()
  (->
    return  unless test.password
    decrypt = crypto.createDecipher(test.algo, test.password)
    decrypt.setAuthTag new Buffer(test.tag, "hex")
    decrypt.setAAD new Buffer(test.aad, "hex")  if test.aad
    msg = decrypt.update(test.ct, "hex", "ascii")
    unless test.tampered
      msg += decrypt.final("ascii")
      assert.equal msg, test.plain
    else
      
      # assert that final throws if input data could not be verified!
      assert.throws (->
        decrypt.final "ascii"
        return
      ), RegExp(" auth")
    return
  )()
  
  # after normal operation, test some incorrect ways of calling the API:
  # it's most certainly enough to run these tests with one algorithm only.
  continue  if i > 0
  (->
    
    # non-authenticating mode:
    encrypt = crypto.createCipheriv("aes-128-cbc", "ipxp9a6i1Mb4USb4", "6fKjEjR3Vl30EUYC")
    encrypt.update "blah", "ascii"
    encrypt.final()
    assert.throws (->
      encrypt.getAuthTag()
      return
    ), RegExp(" state")
    assert.throws (->
      encrypt.setAAD new Buffer("123", "ascii")
      return
    ), RegExp(" state")
    return
  )()
  (->
    
    # trying to get tag before inputting all data:
    encrypt = crypto.createCipheriv(test.algo, new Buffer(test.key, "hex"), new Buffer(test.iv, "hex"))
    encrypt.update "blah", "ascii"
    assert.throws (->
      encrypt.getAuthTag()
      return
    ), RegExp(" state")
    return
  )()
  (->
    
    # trying to set tag on encryption object:
    encrypt = crypto.createCipheriv(test.algo, new Buffer(test.key, "hex"), new Buffer(test.iv, "hex"))
    assert.throws (->
      encrypt.setAuthTag new Buffer(test.tag, "hex")
      return
    ), RegExp(" state")
    return
  )()
  (->
    
    # trying to read tag from decryption object:
    decrypt = crypto.createDecipheriv(test.algo, new Buffer(test.key, "hex"), new Buffer(test.iv, "hex"))
    assert.throws (->
      decrypt.getAuthTag()
      return
    ), RegExp(" state")
    return
  )()
