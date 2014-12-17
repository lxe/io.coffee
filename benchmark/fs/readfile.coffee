# Call fs.readFile over and over again really fast.
# Then see how many times it got called.
# Yes, this is a silly benchmark.  Most benchmarks are silly.
main = (conf) ->
  read = ->
    fs.readFile filename, afterRead
    return
  afterRead = (er, data) ->
    throw er  if er
    throw new Error("wrong number of bytes returned")  if data.length isnt len
    reads++
    read()
    return
  len = +conf.len
  try
    fs.unlinkSync filename
  data = new Buffer(len)
  data.fill "x"
  fs.writeFileSync filename, data
  data = null
  reads = 0
  bench.start()
  setTimeout (->
    bench.end reads
    try
      fs.unlinkSync filename
    return
  ), +conf.dur * 1000
  cur = +conf.concurrent
  read()  while cur--
  return
path = require("path")
common = require("../common.js")
filename = path.resolve(__dirname, ".removeme-benchmark-garbage")
fs = require("fs")
bench = common.createBenchmark(main,
  dur: [5]
  len: [
    1024
    16 * 1024 * 1024
  ]
  concurrent: [
    1
    10
  ]
)
