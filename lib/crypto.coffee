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

# Note: In 0.8 and before, crypto functions all defaulted to using
# binary-encoded strings rather than buffers.

# This is here because many functions accepted binary strings without
# any explicit encoding in older versions of node, and we don't want
# to break them unnecessarily.
toBuf = (str, encoding) ->
  encoding = encoding or "binary"
  if util.isString(str)
    encoding = "binary"  if encoding is "buffer"
    str = new Buffer(str, encoding)
  str
LazyTransform = (options) ->
  @_options = options
  return
Hash = (algorithm, options) ->
  return new Hash(algorithm, options)  unless this instanceof Hash
  @_handle = new binding.Hash(algorithm)
  LazyTransform.call this, options
  return
Hmac = (hmac, key, options) ->
  return new Hmac(hmac, key, options)  unless this instanceof Hmac
  @_handle = new binding.Hmac()
  @_handle.init hmac, toBuf(key)
  LazyTransform.call this, options
  return
getDecoder = (decoder, encoding) ->
  encoding = "utf8"  if encoding is "utf-8" # Normalize encoding.
  decoder = decoder or new StringDecoder(encoding)
  assert decoder.encoding is encoding, "Cannot change encoding"
  decoder
Cipher = (cipher, password, options) ->
  return new Cipher(cipher, password, options)  unless this instanceof Cipher
  @_handle = new binding.CipherBase(true)
  @_handle.init cipher, toBuf(password)
  @_decoder = null
  LazyTransform.call this, options
  return
Cipheriv = (cipher, key, iv, options) ->
  return new Cipheriv(cipher, key, iv, options)  unless this instanceof Cipheriv
  @_handle = new binding.CipherBase(true)
  @_handle.initiv cipher, toBuf(key), toBuf(iv)
  @_decoder = null
  LazyTransform.call this, options
  return
Decipher = (cipher, password, options) ->
  return new Decipher(cipher, password, options)  unless this instanceof Decipher
  @_handle = new binding.CipherBase(false)
  @_handle.init cipher, toBuf(password)
  @_decoder = null
  LazyTransform.call this, options
  return
Decipheriv = (cipher, key, iv, options) ->
  return new Decipheriv(cipher, key, iv, options)  unless this instanceof Decipheriv
  @_handle = new binding.CipherBase(false)
  @_handle.initiv cipher, toBuf(key), toBuf(iv)
  @_decoder = null
  LazyTransform.call this, options
  return
Sign = (algorithm, options) ->
  return new Sign(algorithm, options)  unless this instanceof Sign
  @_handle = new binding.Sign()
  @_handle.init algorithm
  stream.Writable.call this, options
  return
Verify = (algorithm, options) ->
  return new Verify(algorithm, options)  unless this instanceof Verify
  @_handle = new binding.Verify
  @_handle.init algorithm
  stream.Writable.call this, options
  return
DiffieHellman = (sizeOrKey, keyEncoding, generator, genEncoding) ->
  return new DiffieHellman(sizeOrKey, keyEncoding, generator, genEncoding)  unless this instanceof DiffieHellman
  throw new TypeError("First argument should be number, string or Buffer")  if not util.isBuffer(sizeOrKey) and typeof sizeOrKey isnt "number" and typeof sizeOrKey isnt "string"
  if keyEncoding
    if typeof keyEncoding isnt "string" or (not Buffer.isEncoding(keyEncoding) and keyEncoding isnt "buffer")
      genEncoding = generator
      generator = keyEncoding
      keyEncoding = false
  keyEncoding = keyEncoding or exports.DEFAULT_ENCODING
  genEncoding = genEncoding or exports.DEFAULT_ENCODING
  sizeOrKey = toBuf(sizeOrKey, keyEncoding)  if typeof sizeOrKey isnt "number"
  unless generator
    generator = DH_GENERATOR
  else generator = toBuf(generator, genEncoding)  if typeof generator isnt "number"
  @_handle = new binding.DiffieHellman(sizeOrKey, generator)
  Object.defineProperty this, "verifyError",
    enumerable: true
    value: @_handle.verifyError
    writable: false

  return
DiffieHellmanGroup = (name) ->
  return new DiffieHellmanGroup(name)  unless this instanceof DiffieHellmanGroup
  @_handle = new binding.DiffieHellmanGroup(name)
  Object.defineProperty this, "verifyError",
    enumerable: true
    value: @_handle.verifyError
    writable: false

  return
dhGenerateKeys = (encoding) ->
  keys = @_handle.generateKeys()
  encoding = encoding or exports.DEFAULT_ENCODING
  keys = keys.toString(encoding)  if encoding and encoding isnt "buffer"
  keys
dhComputeSecret = (key, inEnc, outEnc) ->
  inEnc = inEnc or exports.DEFAULT_ENCODING
  outEnc = outEnc or exports.DEFAULT_ENCODING
  ret = @_handle.computeSecret(toBuf(key, inEnc))
  ret = ret.toString(outEnc)  if outEnc and outEnc isnt "buffer"
  ret
dhGetPrime = (encoding) ->
  prime = @_handle.getPrime()
  encoding = encoding or exports.DEFAULT_ENCODING
  prime = prime.toString(encoding)  if encoding and encoding isnt "buffer"
  prime
dhGetGenerator = (encoding) ->
  generator = @_handle.getGenerator()
  encoding = encoding or exports.DEFAULT_ENCODING
  generator = generator.toString(encoding)  if encoding and encoding isnt "buffer"
  generator
dhGetPublicKey = (encoding) ->
  key = @_handle.getPublicKey()
  encoding = encoding or exports.DEFAULT_ENCODING
  key = key.toString(encoding)  if encoding and encoding isnt "buffer"
  key
dhGetPrivateKey = (encoding) ->
  key = @_handle.getPrivateKey()
  encoding = encoding or exports.DEFAULT_ENCODING
  key = key.toString(encoding)  if encoding and encoding isnt "buffer"
  key
ECDH = (curve) ->
  throw new TypeError("curve should be a string")  unless util.isString(curve)
  @_handle = new binding.ECDH(curve)
  return

# Default
pbkdf2 = (password, salt, iterations, keylen, digest, callback) ->
  password = toBuf(password)
  salt = toBuf(salt)
  return binding.PBKDF2(password, salt, iterations, keylen, digest, callback)  if exports.DEFAULT_ENCODING is "buffer"
  
  # at this point, we need to handle encodings.
  encoding = exports.DEFAULT_ENCODING
  if callback
    next = (er, ret) ->
      ret = ret.toString(encoding)  if ret
      callback er, ret
      return

    binding.PBKDF2 password, salt, iterations, keylen, digest, next
  else
    ret = binding.PBKDF2(password, salt, iterations, keylen, digest)
    ret.toString encoding
  return
Certificate = ->
  return new Certificate()  unless this instanceof Certificate
  @_handle = new binding.Certificate()
  return

# Use provided engine for everything by default
filterDuplicates = (names) ->
  
  # Drop all-caps names in favor of their lowercase aliases,
  # for example, 'sha1' instead of 'SHA1'.
  ctx = {}
  names.forEach (name) ->
    key = name
    key = key.toLowerCase()  if /^[0-9A-Z\-]+$/.test(key)
    ctx[key] = name  if not ctx.hasOwnProperty(key) or ctx[key] < name
    return

  Object.getOwnPropertyNames(ctx).map((key) ->
    ctx[key]
  ).sort()
"use strict"
exports.DEFAULT_ENCODING = "buffer"
try
  binding = process.binding("crypto")
  randomBytes = binding.randomBytes
  pseudoRandomBytes = binding.pseudoRandomBytes
  getCiphers = binding.getCiphers
  getHashes = binding.getHashes
catch e
  throw new Error("node.js not compiled with openssl crypto support.")
constants = require("constants")
stream = require("stream")
util = require("util")
DH_GENERATOR = 2
exports._toBuf = toBuf
assert = require("assert")
StringDecoder = require("string_decoder").StringDecoder
util.inherits LazyTransform, stream.Transform
[
  "_readableState"
  "_writableState"
  "_transformState"
].forEach (prop, i, props) ->
  Object.defineProperty LazyTransform::, prop,
    get: ->
      stream.Transform.call this, @_options
      @_writableState.decodeStrings = false
      @_writableState.defaultEncoding = "binary"
      this[prop]

    set: (val) ->
      Object.defineProperty this, prop,
        value: val
        enumerable: true
        configurable: true
        writable: true

      return

    configurable: true
    enumerable: true

  return

exports.createHash = exports.Hash = Hash
util.inherits Hash, LazyTransform
Hash::_transform = (chunk, encoding, callback) ->
  @_handle.update chunk, encoding
  callback()
  return

Hash::_flush = (callback) ->
  encoding = @_readableState.encoding or "buffer"
  @push @_handle.digest(encoding), encoding
  callback()
  return

Hash::update = (data, encoding) ->
  encoding = encoding or exports.DEFAULT_ENCODING
  encoding = "binary"  if encoding is "buffer" and util.isString(data)
  @_handle.update data, encoding
  this

Hash::digest = (outputEncoding) ->
  outputEncoding = outputEncoding or exports.DEFAULT_ENCODING
  @_handle.digest outputEncoding

exports.createHmac = exports.Hmac = Hmac
util.inherits Hmac, LazyTransform
Hmac::update = Hash::update
Hmac::digest = Hash::digest
Hmac::_flush = Hash::_flush
Hmac::_transform = Hash::_transform
exports.createCipher = exports.Cipher = Cipher
util.inherits Cipher, LazyTransform
Cipher::_transform = (chunk, encoding, callback) ->
  @push @_handle.update(chunk, encoding)
  callback()
  return

Cipher::_flush = (callback) ->
  try
    @push @_handle.final()
  catch e
    callback e
    return
  callback()
  return

Cipher::update = (data, inputEncoding, outputEncoding) ->
  inputEncoding = inputEncoding or exports.DEFAULT_ENCODING
  outputEncoding = outputEncoding or exports.DEFAULT_ENCODING
  ret = @_handle.update(data, inputEncoding)
  if outputEncoding and outputEncoding isnt "buffer"
    @_decoder = getDecoder(@_decoder, outputEncoding)
    ret = @_decoder.write(ret)
  ret

Cipher::final = (outputEncoding) ->
  outputEncoding = outputEncoding or exports.DEFAULT_ENCODING
  ret = @_handle.final()
  if outputEncoding and outputEncoding isnt "buffer"
    @_decoder = getDecoder(@_decoder, outputEncoding)
    ret = @_decoder.end(ret)
  ret

Cipher::setAutoPadding = (ap) ->
  @_handle.setAutoPadding ap
  this

Cipher::getAuthTag = ->
  @_handle.getAuthTag()

Cipher::setAuthTag = (tagbuf) ->
  @_handle.setAuthTag tagbuf
  return

Cipher::setAAD = (aadbuf) ->
  @_handle.setAAD aadbuf
  return

exports.createCipheriv = exports.Cipheriv = Cipheriv
util.inherits Cipheriv, LazyTransform
Cipheriv::_transform = Cipher::_transform
Cipheriv::_flush = Cipher::_flush
Cipheriv::update = Cipher::update
Cipheriv::final = Cipher::final
Cipheriv::setAutoPadding = Cipher::setAutoPadding
Cipheriv::getAuthTag = Cipher::getAuthTag
Cipheriv::setAuthTag = Cipher::setAuthTag
Cipheriv::setAAD = Cipher::setAAD
exports.createDecipher = exports.Decipher = Decipher
util.inherits Decipher, LazyTransform
Decipher::_transform = Cipher::_transform
Decipher::_flush = Cipher::_flush
Decipher::update = Cipher::update
Decipher::final = Cipher::final
Decipher::finaltol = Cipher::final
Decipher::setAutoPadding = Cipher::setAutoPadding
Decipher::getAuthTag = Cipher::getAuthTag
Decipher::setAuthTag = Cipher::setAuthTag
Decipher::setAAD = Cipher::setAAD
exports.createDecipheriv = exports.Decipheriv = Decipheriv
util.inherits Decipheriv, LazyTransform
Decipheriv::_transform = Cipher::_transform
Decipheriv::_flush = Cipher::_flush
Decipheriv::update = Cipher::update
Decipheriv::final = Cipher::final
Decipheriv::finaltol = Cipher::final
Decipheriv::setAutoPadding = Cipher::setAutoPadding
Decipheriv::getAuthTag = Cipher::getAuthTag
Decipheriv::setAuthTag = Cipher::setAuthTag
Decipheriv::setAAD = Cipher::setAAD
exports.createSign = exports.Sign = Sign
util.inherits Sign, stream.Writable
Sign::_write = (chunk, encoding, callback) ->
  @_handle.update chunk, encoding
  callback()
  return

Sign::update = Hash::update
Sign::sign = (options, encoding) ->
  throw new Error("No key provided to sign")  unless options
  key = options.key or options
  passphrase = options.passphrase or null
  ret = @_handle.sign(toBuf(key), null, passphrase)
  encoding = encoding or exports.DEFAULT_ENCODING
  ret = ret.toString(encoding)  if encoding and encoding isnt "buffer"
  ret

exports.createVerify = exports.Verify = Verify
util.inherits Verify, stream.Writable
Verify::_write = Sign::_write
Verify::update = Sign::update
Verify::verify = (object, signature, sigEncoding) ->
  sigEncoding = sigEncoding or exports.DEFAULT_ENCODING
  @_handle.verify toBuf(object), toBuf(signature, sigEncoding)

exports.publicEncrypt = (options, buffer) ->
  key = options.key or options
  padding = options.padding or constants.RSA_PKCS1_OAEP_PADDING
  binding.publicEncrypt toBuf(key), buffer, padding

exports.privateDecrypt = (options, buffer) ->
  key = options.key or options
  passphrase = options.passphrase or null
  padding = options.padding or constants.RSA_PKCS1_OAEP_PADDING
  binding.privateDecrypt toBuf(key), buffer, padding, passphrase

exports.createDiffieHellman = exports.DiffieHellman = DiffieHellman
exports.DiffieHellmanGroup = exports.createDiffieHellmanGroup = exports.getDiffieHellman = DiffieHellmanGroup
DiffieHellmanGroup::generateKeys = DiffieHellman::generateKeys = dhGenerateKeys
DiffieHellmanGroup::computeSecret = DiffieHellman::computeSecret = dhComputeSecret
DiffieHellmanGroup::getPrime = DiffieHellman::getPrime = dhGetPrime
DiffieHellmanGroup::getGenerator = DiffieHellman::getGenerator = dhGetGenerator
DiffieHellmanGroup::getPublicKey = DiffieHellman::getPublicKey = dhGetPublicKey
DiffieHellmanGroup::getPrivateKey = DiffieHellman::getPrivateKey = dhGetPrivateKey
DiffieHellman::setPublicKey = (key, encoding) ->
  encoding = encoding or exports.DEFAULT_ENCODING
  @_handle.setPublicKey toBuf(key, encoding)
  this

DiffieHellman::setPrivateKey = (key, encoding) ->
  encoding = encoding or exports.DEFAULT_ENCODING
  @_handle.setPrivateKey toBuf(key, encoding)
  this

exports.createECDH = createECDH = (curve) ->
  new ECDH(curve)

ECDH::computeSecret = DiffieHellman::computeSecret
ECDH::setPrivateKey = DiffieHellman::setPrivateKey
ECDH::setPublicKey = DiffieHellman::setPublicKey
ECDH::getPrivateKey = DiffieHellman::getPrivateKey
ECDH::generateKeys = generateKeys = (encoding, format) ->
  @_handle.generateKeys()
  @getPublicKey encoding, format

ECDH::getPublicKey = getPublicKey = (encoding, format) ->
  f = undefined
  if format
    f = format  if typeof format is "number"
    if format is "compressed"
      f = constants.POINT_CONVERSION_COMPRESSED
    else if format is "hybrid"
      f = constants.POINT_CONVERSION_HYBRID
    else if format is "uncompressed"
      f = constants.POINT_CONVERSION_UNCOMPRESSED
    else
      throw TypeError("Bad format: " + format)
  else
    f = constants.POINT_CONVERSION_UNCOMPRESSED
  key = @_handle.getPublicKey(f)
  encoding = encoding or exports.DEFAULT_ENCODING
  key = key.toString(encoding)  if encoding and encoding isnt "buffer"
  key

exports.pbkdf2 = (password, salt, iterations, keylen, digest, callback) ->
  if util.isFunction(digest)
    callback = digest
    digest = `undefined`
  throw new Error("No callback provided to pbkdf2")  unless util.isFunction(callback)
  pbkdf2 password, salt, iterations, keylen, digest, callback

exports.pbkdf2Sync = (password, salt, iterations, keylen, digest) ->
  pbkdf2 password, salt, iterations, keylen, digest

exports.Certificate = Certificate
Certificate::verifySpkac = (object) ->
  @_handle.verifySpkac object

Certificate::exportPublicKey = (object, encoding) ->
  @_handle.exportPublicKey toBuf(object, encoding)

Certificate::exportChallenge = (object, encoding) ->
  @_handle.exportChallenge toBuf(object, encoding)

exports.setEngine = setEngine = (id, flags) ->
  throw new TypeError("id should be a string")  unless util.isString(id)
  throw new TypeError("flags should be a number, if present")  if flags and not util.isNumber(flags)
  flags = flags >>> 0
  flags = constants.ENGINE_METHOD_ALL  if flags is 0
  binding.setEngine id, flags

exports.randomBytes = randomBytes
exports.pseudoRandomBytes = pseudoRandomBytes
exports.rng = randomBytes
exports.prng = pseudoRandomBytes
exports.getCiphers = ->
  filterDuplicates getCiphers.call(null, arguments)

exports.getHashes = ->
  filterDuplicates getHashes.call(null, arguments)


# Legacy API
exports.__defineGetter__ "createCredentials", util.deprecate(->
  require("tls").createSecureContext
, "createCredentials() is deprecated, use tls.createSecureContext instead")
exports.__defineGetter__ "Credentials", util.deprecate(->
  require("tls").SecureContext
, "Credentials is deprecated, use tls.createSecureContext instead")
