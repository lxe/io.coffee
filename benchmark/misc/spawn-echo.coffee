main = (conf) ->
  len = +conf.thousands * 1000
  bench.start()
  go len, len
  return
go = (n, left) ->
  return bench.end(n)  if --left is 0
  child = spawn("echo", ["hello"])
  child.on "exit", (code) ->
    if code
      process.exit code
    else
      go n, left
    return

  return
common = require("../common.js")
bench = common.createBenchmark(main,
  thousands: [1]
)
spawn = require("child_process").spawn
