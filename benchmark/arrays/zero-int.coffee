main = (conf) ->
  type = conf.type
  clazz = global[type]
  n = +conf.n
  bench.start()
  arr = new clazz(n * 1e6)
  i = 0

  while i < 10
    j = 0
    k = arr.length

    while j < k
      arr[j] = 0
      ++j
    ++i
  bench.end n
  return
common = require("../common.js")
bench = common.createBenchmark(main,
  type: "Array Buffer Int8Array Uint8Array Int16Array Uint16Array Int32Array Uint32Array Float32Array Float64Array".split(" ")
  n: [25]
)
