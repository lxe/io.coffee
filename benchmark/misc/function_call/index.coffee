# show the difference between calling a short js function
# relative to a comparable C++ function.
# Reports millions of calls per second.
# Note that JS speed goes up, while cxx speed stays about the same.

# this fails when we try to open with a different version of node,
# which is quite common for benchmarks.  so in that case, just
# abort quietly.
js = ->
  c++
main = (conf) ->
  n = +conf.millions * 1e6
  fn = (if conf.type is "cxx" then cxx else js)
  bench.start()
  i = 0

  while i < n
    fn()
    i++
  bench.end +conf.millions
  return
assert = require("assert")
common = require("../../common.js")
try
  binding = require("./build/Release/binding")
catch er
  console.error "misc/function_call.js Binding failed to load"
  process.exit 0
cxx = binding.hello
c = 0
assert js() is cxx()
bench = common.createBenchmark(main,
  type: [
    "js"
    "cxx"
  ]
  millions: [
    1
    10
    50
  ]
)
