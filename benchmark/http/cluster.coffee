
# unicode confuses ab on os x.
main = (conf) ->
  process.env.PORT = PORT
  workers = 0
  w1 = cluster.fork()
  w2 = cluster.fork()
  cluster.on "listening", ->
    workers++
    return  if workers < 2
    setTimeout (->
      path = "/" + conf.type + "/" + conf.length
      args = [
        "-d"
        "10s"
        "-t"
        8
        "-c"
        conf.c
      ]
      bench.http path, args, ->
        w1.destroy()
        w2.destroy()
        return

      return
    ), 100
    return

  return
common = require("../common.js")
PORT = common.PORT
cluster = require("cluster")
if cluster.isMaster
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
    c: [
      50
      500
    ]
  )
else
  require "../http_simple.js"
