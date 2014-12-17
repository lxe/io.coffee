common = require("../common.js")
assert = require("assert")
zlib = require("zlib")
path = require("path")
fs = require("fs")
file = fs.readFileSync(path.resolve(common.fixturesDir, "person.jpg"))
chunkSize = 24 * 1024
opts =
  level: 9
  strategy: zlib.Z_DEFAULT_STRATEGY

deflater = zlib.createDeflate(opts)
chunk1 = file.slice(0, chunkSize)
chunk2 = file.slice(chunkSize)
blkhdr = new Buffer([
  0x00
  0x48
  0x82
  0xb7
  0x7d
])
expected = Buffer.concat([
  blkhdr
  chunk2
])
actual = undefined
deflater.write chunk1, ->
  deflater.params 0, zlib.Z_DEFAULT_STRATEGY, ->
      while deflater.read()
    deflater.end chunk2, ->
      bufs = []
      buf = undefined
      bufs.push buf  while buf = deflater.read()
      actual = Buffer.concat(bufs)
      return

    return

    while deflater.read()
  return

process.once "exit", ->
  assert.deepEqual actual, expected
  return

