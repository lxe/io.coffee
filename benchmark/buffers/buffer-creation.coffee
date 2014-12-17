main = (conf) ->
  len = +conf.len
  n = +conf.n
  clazz = (if conf.type is "fast" then Buffer else SlowBuffer)
  bench.start()
  i = 0

  while i < n * 1024
    b = new clazz(len)
    i++
  bench.end n
  return
SlowBuffer = require("buffer").SlowBuffer
common = require("../common.js")
bench = common.createBenchmark(main,
  type: [
    "fast"
    "slow"
  ]
  len: [
    10
    1024
  ]
  n: [1024]
)
