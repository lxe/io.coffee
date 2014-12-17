# test the throughput of the fs.WriteStream class.
main = (conf) ->
  type = conf.type
  size = +conf.size
  switch type
    when "buf"
      encoding = null
    when "asc"
      encoding = "ascii"
    when "utf"
      encoding = "utf8"
    else
      throw new Error("invalid type")
  makeFile runTest
  return
runTest = ->
  assert fs.statSync(filename).size is filesize
  rs = fs.createReadStream(filename,
    highWaterMark: size
    encoding: encoding
  )
  rs.on "open", ->
    bench.start()
    return

  bytes = 0
  rs.on "data", (chunk) ->
    bytes += chunk.length
    return

  rs.on "end", ->
    try
      fs.unlinkSync filename
    
    # MB/sec
    bench.end bytes / (1024 * 1024)
    return

  return
makeFile = ->
  
  # ü
  write = ->
    loop
      w--
      break unless false isnt ws.write(buf) and w > 0
    ws.end()  if w is 0
    return
  buf = new Buffer(filesize / 1024)
  if encoding is "utf8"
    i = 0

    while i < buf.length
      buf[i] = (if i % 2 is 0 then 0xc3 else 0xbc)
      i++
  else if encoding is "ascii"
    buf.fill "a"
  else
    buf.fill "x"
  try
    fs.unlinkSync filename
  w = 1024
  ws = fs.createWriteStream(filename)
  ws.on "close", runTest
  ws.on "drain", write
  write()
  return
path = require("path")
common = require("../common.js")
filename = path.resolve(__dirname, ".removeme-benchmark-garbage")
fs = require("fs")
filesize = 1000 * 1024 * 1024
assert = require("assert")
type = undefined
encoding = undefined
size = undefined
bench = common.createBenchmark(main,
  type: [
    "buf"
    "asc"
    "utf"
  ]
  size: [
    1024
    4096
    65535
    1024 * 1024
  ]
)
