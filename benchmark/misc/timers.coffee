main = (conf) ->
  n = +conf.thousands * 1e3
  if conf.type is "breadth"
    breadth n
  else
    depth n
  return
depth = (N) ->
  cb = ->
    n++
    if n is N
      bench.end N / 1e3
    else
      setTimeout cb
    return
  n = 0
  bench.start()
  setTimeout cb
  return
breadth = (N) ->
  cb = ->
    n++
    bench.end N / 1e3  if n is N
    return
  n = 0
  bench.start()
  i = 0

  while i < N
    setTimeout cb
    i++
  return
common = require("../common.js")
bench = common.createBenchmark(main,
  thousands: [500]
  type: [
    "depth"
    "breadth"
  ]
)
