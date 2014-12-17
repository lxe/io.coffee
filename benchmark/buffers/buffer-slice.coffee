main = (conf) ->
  n = +conf.n
  b = (if conf.type is "fast" then buf else slowBuf)
  bench.start()
  i = 0

  while i < n * 1024
    b.slice 10, 256
    i++
  bench.end n
  return
common = require("../common.js")
SlowBuffer = require("buffer").SlowBuffer
bench = common.createBenchmark(main,
  type: [
    "fast"
    "slow"
  ]
  n: [1024]
)
buf = new Buffer(1024)
slowBuf = new SlowBuffer(1024)
