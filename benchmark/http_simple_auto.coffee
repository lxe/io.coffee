#
# Usage:
#   node benchmark/http_simple_auto.js <args> <target>
#
# Where:
#   <args>   Arguments to pass to `ab`.
#   <target> Target to benchmark, e.g. `bytes/1024` or `buffer/8192`.
#

# example: http://localhost:port/bytes/512/4
# sends a 512 byte body in 4 chunks of 128 bytes

# send body in chunks
dump_mm_stats = ->
  # give GC time to settle
  print_stats = ->
    console.log "\nBEFORE / AFTER GC"
    [
      "rss"
      "heapTotal"
      "heapUsed"
    ].forEach (key) ->
      a = before[key] / (1024 * 1024)
      b = after[key] / (1024 * 1024)
      console.log "%sM / %sM %s", a.toFixed(2), b.toFixed(2), key
      return

    return
  return  unless typeof gc is "function"
  before = process.memoryUsage()
  i = 0

  while i < 10
    gc()
    ++i
  after = process.memoryUsage()
  setTimeout print_stats, 250
  return
path = require("path")
http = require("http")
spawn = require("child_process").spawn
port = parseInt(process.env.PORT or 8000)
fixed = ""
i = 0

while i < 20 * 1024
  fixed += "C"
  i++
stored = {}
storedBuffer = {}
server = http.createServer((req, res) ->
  commands = req.url.split("/")
  command = commands[1]
  body = ""
  arg = commands[2]
  n_chunks = parseInt(commands[3], 10)
  status = 200
  if command is "bytes"
    n = parseInt(arg, 10)
    throw "bytes called with n <= 0"  if n <= 0
    if stored[n] is `undefined`
      stored[n] = ""
      i = 0

      while i < n
        stored[n] += "C"
        i++
    body = stored[n]
  else if command is "buffer"
    n = parseInt(arg, 10)
    throw new Error("bytes called with n <= 0")  if n <= 0
    if storedBuffer[n] is `undefined`
      storedBuffer[n] = new Buffer(n)
      i = 0

      while i < n
        storedBuffer[n][i] = "C".charCodeAt(0)
        i++
    body = storedBuffer[n]
  else if command is "quit"
    res.connection.server.close()
    body = "quitting"
  else if command is "fixed"
    body = fixed
  else if command is "echo"
    res.writeHead 200,
      "Content-Type": "text/plain"
      "Transfer-Encoding": "chunked"

    req.pipe res
    return
  else
    status = 404
    body = "not found\n"
  if n_chunks > 0
    res.writeHead status,
      "Content-Type": "text/plain"
      "Transfer-Encoding": "chunked"

    len = body.length
    step = Math.floor(len / n_chunks) or 1
    i = 0
    n = (n_chunks - 1)

    while i < n
      res.write body.slice(i * step, i * step + step)
      ++i
    res.end body.slice((n_chunks - 1) * step)
  else
    content_length = body.length.toString()
    res.writeHead status,
      "Content-Type": "text/plain"
      "Content-Length": content_length

    res.end body
  return
)
server.listen port, ->
  url = "http://127.0.0.1:" + port + "/"
  n = process.argv.length - 1
  process.argv[n] = url + process.argv[n]
  cp = spawn("ab", process.argv.slice(2))
  cp.stdout.pipe process.stdout
  cp.stderr.pipe process.stderr
  cp.on "exit", ->
    server.close()
    process.nextTick dump_mm_stats
    return

  return

