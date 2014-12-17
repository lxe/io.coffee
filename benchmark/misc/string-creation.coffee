main = (conf) ->
  n = +conf.millions * 1e6
  bench.start()
  s = undefined
  i = 0

  while i < n
    s = "01234567890"
    s[1] = "a"
    i++
  bench.end n / 1e6
  return
common = require("../common.js")
bench = common.createBenchmark(main,
  millions: [100]
)
