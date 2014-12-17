# test the speed of .pipe() with sockets
main = (conf) ->
  dur = +conf.dur
  len = +conf.len
  type = conf.type
  switch type
    when "buf"
      chunk = new Buffer(len)
      chunk.fill "x"
    when "utf"
      encoding = "utf8"
      chunk = new Array(len / 2 + 1).join("ü")
    when "asc"
      encoding = "ascii"
      chunk = new Array(len + 1).join("x")
    else
      throw new Error("invalid type: " + type)
  server()
  return
Writer = ->
  @received = 0
  @writable = true
  return

# doesn't matter, never emits anything.
Reader = ->
  @flow = @flow.bind(this)
  @readable = true
  return
server = ->
  reader = new Reader()
  writer = new Writer()
  
  # the actual benchmark.
  server = net.createServer((socket) ->
    reader.pipe socket
    return
  )
  server.listen PORT, ->
    socket = net.connect(PORT)
    socket.on "connect", ->
      bench.start()
      socket.pipe writer
      setTimeout (->
        bytes = writer.received
        gbits = (bytes * 8) / (1024 * 1024 * 1024)
        bench.end gbits
        return
      ), dur * 1000
      return

    return

  return
common = require("../common.js")
PORT = common.PORT
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
dur = undefined
len = undefined
type = undefined
chunk = undefined
encoding = undefined
net = require("net")
Writer::write = (chunk, encoding, cb) ->
  @received += chunk.length
  if typeof encoding is "function"
    encoding()
  else cb()  if typeof cb is "function"
  true

Writer::on = ->

Writer::once = ->

Writer::emit = ->

Reader::pipe = (dest) ->
  @dest = dest
  @flow()
  dest

Reader::flow = ->
  dest = @dest
  res = dest.write(chunk, encoding)
  unless res
    dest.once "drain", @flow
  else
    process.nextTick @flow
  return
