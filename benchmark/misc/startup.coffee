startNode = (conf) ->
  start = ->
    node = spawn(process.execPath or process.argv[0], [emptyJsFile])
    node.on "exit", (exitCode) ->
      throw new Error("Error during node startup")  if exitCode isnt 0
      starts++
      if go
        start()
      else
        bench.end starts
      return

    return
  dur = +conf.dur
  go = true
  starts = 0
  open = 0
  setTimeout (->
    go = false
    return
  ), dur * 1000
  bench.start()
  start()
  return
common = require("../common.js")
spawn = require("child_process").spawn
path = require("path")
emptyJsFile = path.resolve(__dirname, "../../test/fixtures/semicolon.js")
starts = 100
i = 0
start = undefined
bench = common.createBenchmark(startNode,
  dur: [1]
)
