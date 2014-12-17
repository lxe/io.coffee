# throughput benchmark
# creates a single hasher, then pushes a bunch of data through it
main = (conf) ->
  api = conf.api
  if api is "stream" and process.version.match(/^v0\.[0-8]\./)
    console.error "Crypto streams not available until v0.10"
    
    # use the legacy, just so that we can compare them.
    api = "legacy"
  crypto = require("crypto")
  assert = require("assert")
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
  bench.start()
  fn conf.algo, message, encoding, conf.writes, conf.len, conf.out
  return
legacyWrite = (algo, message, encoding, writes, len, outEnc) ->
  written = writes * len
  bits = written * 8
  gbits = bits / (1024 * 1024 * 1024)
  while writes-- > 0
    h = crypto.createHash(algo)
    h.update message, encoding
    res = h.digest(outEnc)
    
    # include buffer creation costs for older versions
    res = new Buffer(res, "binary")  if outEnc is "buffer" and typeof res is "string"
  bench.end gbits
  return
streamWrite = (algo, message, encoding, writes, len, outEnc) ->
  written = writes * len
  bits = written * 8
  gbits = bits / (1024 * 1024 * 1024)
  while writes-- > 0
    h = crypto.createHash(algo)
    h.setEncoding outEnc  if outEnc isnt "buffer"
    h.write message, encoding
    h.end()
    h.read()
  bench.end gbits
  return
common = require("../common.js")
crypto = require("crypto")
bench = common.createBenchmark(main,
  writes: [500]
  algo: [
    "sha256"
    "md5"
  ]
  type: [
    "asc"
    "utf"
    "buf"
  ]
  out: [
    "hex"
    "binary"
    "buffer"
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
