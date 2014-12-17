# When calling .end(buffer) right away, this triggers a "hot path"
# optimization in http.js, to avoid an extra write call.
#
# However, the overhead of copying a large buffer is higher than
# the overhead of an extra write() call, so the hot path was not
# always as hot as it could be.
#
# Verify that our assumptions are valid.
# two spaces added to line up each row
main = (conf) ->
  write = (res) ->
    res.write chunk
    res.end()
    return
  end = (res) ->
    res.end chunk
    return
  http = require("http")
  chunk = undefined
  len = conf.kb * 1024
  switch conf.type
    when "buf"
      chunk = new Buffer(len)
      chunk.fill "x"
    when "utf"
      encoding = "utf8"
      chunk = new Array(len / 2 + 1).join("ü")
    when "asc"
      chunk = new Array(len + 1).join("a")
  method = (if conf.method is "write" then write else end)
  args = [
    "-d"
    "10s"
    "-t"
    8
    "-c"
    conf.c
  ]
  server = http.createServer((req, res) ->
    method res
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
  type: [
    "asc"
    "utf"
    "buf"
  ]
  kb: [
    64
    128
    256
    1024
  ]
  c: [100]
  method: [
    "write"
    "end  "
  ]
)
