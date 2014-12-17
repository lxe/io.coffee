# When calling .end(buffer) right away, this triggers a "hot path"
# optimization in http.js, to avoid an extra write call.
#
# However, the overhead of copying a large buffer is higher than
# the overhead of an extra write() call, so the hot path was not
# always as hot as it could be.
#
# Verify that our assumptions are valid.
main = (conf) ->
  http = require("http")
  chunk = new Buffer(conf.size)
  chunk.fill "8"
  args = [
    "-d"
    "10s"
    "-t"
    8
    "-c"
    conf.c
  ]
  server = http.createServer((req, res) ->
    send = (left) ->
      return res.end()  if left is 0
      res.write chunk
      setTimeout (->
        send left - 1
        return
      ), 0
      return
    send conf.num
    return
  )
  server.listen common.PORT, ->
    bench.http "/", args, ->
      server.close()
      return

    return

  return
common = require("../common.js")
PORT = common.PORT
bench = common.createBenchmark(main,
  num: [
    1
    4
    8
    16
  ]
  size: [
    1
    64
    256
  ]
  c: [100]
)
