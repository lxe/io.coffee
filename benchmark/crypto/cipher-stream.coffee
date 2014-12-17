main = (conf) ->
  api = conf.api
  if api is "stream" and process.version.match(/^v0\.[0-8]\./)
    console.error "Crypto streams not available until v0.10"
    
    # use the legacy, just so that we can compare them.
    api = "legacy"
  crypto = require("crypto")
  assert = require("assert")
  alice = crypto.getDiffieHellman("modp5")
  bob = crypto.getDiffieHellman("modp5")
  alice.generateKeys()
  bob.generateKeys()
  pubEnc = (if /^v0\.[0-8]/.test(process.version) then "binary" else null)
  alice_secret = alice.computeSecret(bob.getPublicKey(), pubEnc, "hex")
  bob_secret = bob.computeSecret(alice.getPublicKey(), pubEnc, "hex")
  
  # alice_secret and bob_secret should be the same
  assert alice_secret is bob_secret
  alice_cipher = crypto.createCipher(conf.cipher, alice_secret)
  bob_cipher = crypto.createDecipher(conf.cipher, bob_secret)
  message = undefined
  encoding = undefined
  switch conf.type
    when "asc"
      message = new Array(conf.len + 1).join("a")
      encoding = "ascii"
    when "utf"
      message = new Array(conf.len / 2 + 1).join("ü")
      encoding = "utf8"
    when "buf"
      message = new Buffer(conf.len)
      message.fill "b"
    else
      throw new Error("unknown message type: " + conf.type)
  fn = (if api is "stream" then streamWrite else legacyWrite)
  
  # write data as fast as possible to alice, and have bob decrypt.
  # use old API for comparison to v0.8
  bench.start()
  fn alice_cipher, bob_cipher, message, encoding, conf.writes
  return
streamWrite = (alice, bob, message, encoding, writes) ->
  written = 0
  bob.on "data", (c) ->
    written += c.length
    return

  bob.on "end", ->
    
    # Gbits
    bits = written * 8
    gbits = bits / (1024 * 1024 * 1024)
    bench.end gbits
    return

  alice.pipe bob
  alice.write message, encoding  while writes-- > 0
  alice.end()
  return
legacyWrite = (alice, bob, message, encoding, writes) ->
  written = 0
  i = 0

  while i < writes
    enc = alice.update(message, encoding)
    dec = bob.update(enc)
    written += dec.length
    i++
  enc = alice.final()
  dec = bob.update(enc)
  written += dec.length
  dec = bob.final()
  written += dec.length
  bits = written * 8
  gbits = written / (1024 * 1024 * 1024)
  bench.end gbits
  return
common = require("../common.js")
bench = common.createBenchmark(main,
  writes: [500]
  cipher: [
    "AES192"
    "AES256"
  ]
  type: [
    "asc"
    "utf"
    "buf"
  ]
  len: [
    2
    1024
    102400
    1024 * 1024
  ]
  api: [
    "legacy"
    "stream"
  ]
)
