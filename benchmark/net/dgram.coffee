# test UDP send/recv throughput

# `num` is the number of send requests to queue up each time.
# Keep it reasonably high (>10) otherwise you're benchmarking the speed of
# event loop cycles more than anything else.
main = (conf) ->
  dur = +conf.dur
  len = +conf.len
  num = +conf.num
  type = conf.type
  chunk = new Buffer(len)
  server()
  return
server = ->
  onsend = ->
    if sent++ % num is 0
      i = 0

      while i < num
        socket.send chunk, 0, chunk.length, PORT, "127.0.0.1", onsend
        i++
    return
  sent = 0
  received = 0
  socket = dgram.createSocket("udp4")
  socket.on "listening", ->
    bench.start()
    onsend()
    setTimeout (->
      bytes = ((if type is "send" then sent else received)) * chunk.length
      gbits = (bytes * 8) / (1024 * 1024 * 1024)
      bench.end gbits
      return
    ), dur * 1000
    return

  socket.on "message", (buf, rinfo) ->
    received++
    return

  socket.bind PORT
  return
common = require("../common.js")
PORT = common.PORT
bench = common.createBenchmark(main,
  len: [
    1
    64
    256
    1024
  ]
  num: [100]
  type: [
    "send"
    "recv"
  ]
  dur: [5]
)
dur = undefined
len = undefined
num = undefined
type = undefined
chunk = undefined
encoding = undefined
dgram = require("dgram")
