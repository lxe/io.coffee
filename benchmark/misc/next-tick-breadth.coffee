main = (conf) ->
  cb = ->
    n++
    bench.end n / 1e6  if n is N
    return
  N = +conf.millions * 1e6
  n = 0
  bench.start()
  i = 0

  while i < N
    process.nextTick cb
    i++
  return
common = require("../common.js")
bench = common.createBenchmark(main,
  millions: [2]
)
