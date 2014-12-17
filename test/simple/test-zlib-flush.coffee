common = require("../common.js")
assert = require("assert")
zlib = require("zlib")
path = require("path")
fs = require("fs")
file = fs.readFileSync(path.resolve(common.fixturesDir, "person.jpg"))
chunkSize = 16
opts = level: 0
deflater = zlib.createDeflate(opts)
chunk = file.slice(0, chunkSize)
expectedNone = new Buffer([
  0x78
  0x01
])
blkhdr = new Buffer([
  0x00
  0x10
  0x00
  0xef
  0xff
])
adler32 = new Buffer([
  0x00
  0x00
  0x00
  0xff
  0xff
])
expectedFull = Buffer.concat([
  blkhdr
  chunk
  adler32
])
actualNone = undefined
actualFull = undefined
deflater.write chunk, ->
  deflater.flush zlib.Z_NO_FLUSH, ->
    actualNone = deflater.read()
    deflater.flush ->
      bufs = []
      buf = undefined
      bufs.push buf  while buf = deflater.read()
      actualFull = Buffer.concat(bufs)
      return

    return

  return

process.once "exit", ->
  assert.deepEqual actualNone, expectedNone
  assert.deepEqual actualFull, expectedFull
  return

