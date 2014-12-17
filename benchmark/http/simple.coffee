
# unicode confuses ab on os x.
# chunks=0 means 'no chunked encoding'.
main = (conf) ->
  process.env.PORT = PORT
  spawn = require("child_process").spawn
  server = require("../http_simple.js")
  setTimeout (->
    path = "/" + conf.type + "/" + conf.length + "/" + conf.chunks
    args = [
      "-d"
      "10s"
      "-t"
      8
      "-c"
      conf.c
    ]
    bench.http path, args, ->
      server.close()
      return

    return
  ), 2000
  return
common = require("../common.js")
PORT = common.PORT
bench = common.createBenchmark(main,
  type: [
    "bytes"
    "buffer"
  ]
  length: [
    4
    1024
    102400
  ]
  chunks: [
    0
    1
    4
  ]
  c: [
    50
    500
  ]
)
