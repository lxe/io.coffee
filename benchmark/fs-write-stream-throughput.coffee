
# If there are no args, then this is the root.  Run all the benchmarks!
parent = ->
  run = ->
    args = queue.shift()
    return  unless args
    child = spawn(node, args,
      stdio: "inherit"
    )
    child.on "close", (code, signal) ->
      throw new Error("Benchmark failed: " + args.slice(1))  if code
      run()
      return

    return
  types = [
    "string"
    "buffer"
  ]
  durs = [
    1
    5
  ]
  sizes = [
    1
    10
    100
    2048
    10240
  ]
  queue = []
  types.forEach (t) ->
    durs.forEach (d) ->
      sizes.forEach (s) ->
        queue.push [
          __filename
          d
          s
          t
        ]
        return

      return

    return

  spawn = require("child_process").spawn
  node = process.execPath
  run()
  return
runTest = (dur, size, type) ->
  done = ->
    time = end[0] + end[1] / 1e9
    written = fs.statSync("write_stream_throughput").size / 1024
    rate = (written / time).toFixed(2)
    console.log "fs_write_stream_dur_%d_size_%d_type_%s: %d", dur, size, type, rate
    try
      fs.unlinkSync "write_stream_throughput"
    return
  
  # streams2 fs.WriteStreams will let you send a lot of writes into the
  # buffer before returning false, so capture the *actual* end time when
  # all the bytes have been written to the disk, indicated by 'finish'
  write = ->
    
    # don't try to write after we end, even if a 'drain' event comes.
    # v0.8 streams are so sloppy!
    return  if ending
    start = start or process.hrtime()
      while false isnt f.write(chunk)
    end = process.hrtime(start)
    if end[0] >= dur
      ending = true
      f.end()
    return
  type = "buffer"  if type isnt "string"
  switch type
    when "string"
      chunk = new Array(size + 1).join("a")
    when "buffer"
      chunk = new Buffer(size)
      chunk.fill "a"
  writes = 0
  fs = require("fs")
  try
    fs.unlinkSync "write_stream_throughput"
  start = undefined
  end = undefined
  f = require("fs").createWriteStream("write_stream_throughput")
  f.on "drain", write
  f.on "open", write
  f.on "close", done
  f.on "finish", ->
    end = process.hrtime(start)
    return

  ending = false
  return
unless process.argv[2]
  parent()
else
  runTest +process.argv[2], +process.argv[3], process.argv[4]
