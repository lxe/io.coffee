# In this benchmark, we connect a client to the server, and write
# as many bytes as we can in the specified time (default = 10s)

# if there are --dur=N and --len=N args, then
# run the function with those settings.
# if not, then queue up a bunch of child processes.
main = (conf) ->
  dur = +conf.dur
  len = +conf.len
  type = conf.type
  server()
  return
fail = (err, syscall) ->
  throw util._errnoException(err, syscall)return
server = ->
  serverHandle = new TCP()
  err = serverHandle.bind("127.0.0.1", PORT)
  fail err, "bind"  if err
  err = serverHandle.listen(511)
  fail err, "listen"  if err
  serverHandle.onconnection = (err, clientHandle) ->
    fail err, "connect"  if err
    clientHandle.onread = (nread, buffer) ->
      
      # we're not expecting to ever get an EOF from the client.
      # just lots of data forever.
      fail nread, "read"  if nread < 0
      writeReq = async: false
      err = clientHandle.writeBuffer(writeReq, buffer)
      fail err, "write"  if err
      writeReq.oncomplete = (status, handle, req) ->
        fail err, "write"  if status
        return

      return

    clientHandle.readStart()
    return

  client()
  return
client = ->
  
  # multiply by 2 since we're sending it first one way
  # then then back again.
  write = ->
    writeReq = oncomplete: afterWrite
    err = undefined
    switch type
      when "buf"
        err = clientHandle.writeBuffer(writeReq, chunk)
      when "utf"
        err = clientHandle.writeUtf8String(writeReq, chunk)
      when "asc"
        err = clientHandle.writeAsciiString(writeReq, chunk)
    fail err, "write"  if err
    return
  afterWrite = (err, handle, req) ->
    fail err, "write"  if err
    write()  while clientHandle.writeQueueSize is 0
    return
  chunk = undefined
  switch type
    when "buf"
      chunk = new Buffer(len)
      chunk.fill "x"
    when "utf"
      chunk = new Array(len / 2 + 1).join("ü")
    when "asc"
      chunk = new Array(len + 1).join("x")
    else
      throw new Error("invalid type: " + type)
  clientHandle = new TCP()
  connectReq = {}
  err = clientHandle.connect(connectReq, "127.0.0.1", PORT)
  bytes = 0
  fail err, "connect"  if err
  clientHandle.readStart()
  clientHandle.onread = (nread, buffer) ->
    fail nread, "read"  if nread < 0
    bytes += buffer.length
    return

  connectReq.oncomplete = (err) ->
    fail err, "connect"  if err
    bench.start()
    setTimeout (->
      bench.end 2 * (bytes * 8) / (1024 * 1024 * 1024)
      return
    ), dur * 1000
    write()  while clientHandle.writeQueueSize is 0
    return

  return
common = require("../common.js")
util = require("util")
bench = common.createBenchmark(main,
  len: [
    102400
    1024 * 1024 * 16
  ]
  type: [
    "utf"
    "asc"
    "buf"
  ]
  dur: [5]
)
TCP = process.binding("tcp_wrap").TCP
PORT = common.PORT
dur = undefined
len = undefined
type = undefined
