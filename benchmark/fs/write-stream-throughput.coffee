# test the throughput of the fs.WriteStream class.
main = (conf) ->
  write = ->
    
    # don't try to write after we end, even if a 'drain' event comes.
    # v0.8 streams are so sloppy!
    return  if ending
    unless started
      started = true
      bench.start()
      while false isnt f.write(chunk, encoding)
    return
  done = ->
    f.emit "finish"  unless ended
    return
  dur = +conf.dur
  type = conf.type
  size = +conf.size
  encoding = undefined
  chunk = undefined
  switch type
    when "buf"
      chunk = new Buffer(size)
      chunk.fill "b"
    when "asc"
      chunk = new Array(size + 1).join("a")
      encoding = "ascii"
    when "utf"
      chunk = new Array(Math.ceil(size / 2) + 1).join("ü")
      encoding = "utf8"
    else
      throw new Error("invalid type")
  try
    fs.unlinkSync filename
  started = false
  ending = false
  ended = false
  setTimeout (->
    ending = true
    f.end()
    return
  ), dur * 1000
  f = fs.createWriteStream(filename)
  f.on "drain", write
  f.on "open", write
  f.on "close", done
  f.on "finish", ->
    ended = true
    written = fs.statSync(filename).size / 1024
    try
      fs.unlinkSync filename
    bench.end written / 1024
    return

  return
path = require("path")
common = require("../common.js")
filename = path.resolve(__dirname, ".removeme-benchmark-garbage")
fs = require("fs")
bench = common.createBenchmark(main,
  dur: [5]
  type: [
    "buf"
    "asc"
    "utf"
  ]
  size: [
    2
    1024
    65535
    1024 * 1024
  ]
)
