main = (conf) ->
  args = undefined
  ret = undefined
  n = +conf.n
  arguments = gargs.slice(0, conf.arguments)
  bench.start()
  bdomain.enter()
  i = 0

  while i < n
    if arguments.length >= 2
      args = Array::slice.call(arguments, 1)
      ret = fn.apply(this, args)
    else
      ret = fn.call(this)
    i++
  bdomain.exit()
  bench.end n
  return
fn = (a, b, c) ->
  a = 1  unless a
  b = 2  unless b
  c = 3  unless c
  a + b + c
common = require("../common.js")
domain = require("domain")
bench = common.createBenchmark(main,
  arguments: [
    0
    1
    2
    3
  ]
  n: [10]
)
bdomain = domain.create()
gargs = [
  1
  2
  3
]
