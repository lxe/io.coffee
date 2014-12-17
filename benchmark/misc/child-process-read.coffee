main = (conf) ->
  bench.start()
  dur = +conf.dur
  len = +conf.len
  msg = "\"" + Array(len).join(".") + "\""
  options = stdio: [
    "ignore"
    "ipc"
    "ignore"
  ]
  child = spawn("yes", [msg], options)
  bytes = 0
  child.on "message", (msg) ->
    bytes += msg.length
    return

  setTimeout (->
    child.kill()
    gbits = (bytes * 8) / (1024 * 1024 * 1024)
    bench.end gbits
    return
  ), dur * 1000
  return
common = require("../common.js")
bench = common.createBenchmark(main,
  len: [
    64
    256
    1024
    4096
    32768
  ]
  dur: [5]
)
spawn = require("child_process").spawn
