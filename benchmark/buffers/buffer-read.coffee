main = (conf) ->
  noAssert = conf.noAssert is "true"
  len = +conf.millions * 1e6
  clazz = (if conf.buf is "fast" then Buffer else require("buffer").SlowBuffer)
  buff = new clazz(8)
  fn = "read" + conf.type
  buff.writeDoubleLE 0, 0, noAssert
  testFunction = new Function("buff", [
    "for (var i = 0; i !== " + len + "; i++) {"
    "  buff." + fn + "(0, " + JSON.stringify(noAssert) + ");"
    "}"
  ].join("\n"))
  bench.start()
  testFunction buff
  bench.end len / 1e6
  return
common = require("../common.js")
bench = common.createBenchmark(main,
  noAssert: [
    false
    true
  ]
  buffer: [
    "fast"
    "slow"
  ]
  type: [
    "UInt8"
    "UInt16LE"
    "UInt16BE"
    "UInt32LE"
    "UInt32BE"
    "Int8"
    "Int16LE"
    "Int16BE"
    "Int32LE"
    "Int32BE"
    "FloatLE"
    "FloatBE"
    "DoubleLE"
    "DoubleBE"
  ]
  millions: [1]
)
