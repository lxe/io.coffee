# Measure the time it takes for the HTTP client to send a request body.
# two spaces added to line up each row
main = (conf) ->
  pummel = ->
    req = http.request(options, (res) ->
      nreqs++
      pummel() # Line up next request.
      res.resume()
      return
    )
    if conf.method is "write"
      req.write chunk, encoding
      req.end()
    else
      req.end chunk, encoding
    return
  done = ->
    bench.end nreqs
    return
  dur = +conf.dur
  len = +conf.bytes
  encoding = undefined
  chunk = undefined
  switch conf.type
    when "buf"
      chunk = new Buffer(len)
      chunk.fill "x"
    when "utf"
      encoding = "utf8"
      chunk = new Array(len / 2 + 1).join("ü")
    when "asc"
      chunk = new Array(len + 1).join("a")
  nreqs = 0
  options =
    headers:
      Connection: "keep-alive"
      "Transfer-Encoding": "chunked"

    agent: new http.Agent(maxSockets: 1)
    host: "127.0.0.1"
    port: common.PORT
    path: "/"
    method: "POST"

  server = http.createServer((req, res) ->
    res.end()
    return
  )
  server.listen options.port, options.host, ->
    setTimeout done, dur * 1000
    bench.start()
    pummel()
    return

  return
common = require("../common.js")
http = require("http")
bench = common.createBenchmark(main,
  dur: [5]
  type: [
    "asc"
    "utf"
    "buf"
  ]
  bytes: [
    32
    256
    1024
  ]
  method: [
    "write"
    "end  "
  ]
)
