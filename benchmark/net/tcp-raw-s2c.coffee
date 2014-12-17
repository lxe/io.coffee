# In this benchmark, we connect a client to the server, and write
# as many bytes as we can in the specified time (default = 10s)

# if there are dur=N and len=N args, then
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
    write = ->
      writeReq =
        async: false
        oncomplete: afterWrite

      err = undefined
      switch type
        when "buf"
          err = clientHandle.writeBuffer(writeReq, chunk)
        when "utf"
          err = clientHandle.writeUtf8String(writeReq, chunk)
        when "asc"
          err = clientHandle.writeAsciiString(writeReq, chunk)
      if err
        fail err, "write"
      else unless writeReq.async
        process.nextTick ->
          afterWrite null, clientHandle, writeReq
          return

      return
    afterWrite = (err, handle, req) ->
      fail err, "write"  if err
      write()  while clientHandle.writeQueueSize is 0
      return
    fail err, "connect"  if err
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
    clientHandle.readStart()
    write()  while clientHandle.writeQueueSize is 0
    return

  client()
  return
client = ->
  clientHandle = new TCP()
  connectReq = {}
  err = clientHandle.connect(connectReq, "127.0.0.1", PORT)
  fail err, "connect"  if err
  connectReq.oncomplete = ->
    bytes = 0
    clientHandle.onread = (nread, buffer) ->
      
      # we're not expecting to ever get an EOF from the client.
      # just lots of data forever.
      fail nread, "read"  if nread < 0
      
      # don't slice the buffer.  the point of this is to isolate, not
      # simulate real traffic.
      bytes += buffer.length
      return

    clientHandle.readStart()
    
    # the meat of the benchmark is right here:
    bench.start()
    setTimeout (->
      
      # report in Gb/sec
      bench.end (bytes * 8) / (1024 * 1024 * 1024)
      return
    ), dur * 1000
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
