
# If this is the main module, then run the benchmarks
runBenchmarks = ->
  test = tests.shift()
  return  unless test
  return process.nextTick(runBenchmarks)  if test.match(/^[\._]/)
  console.error type + "/" + test
  test = path.resolve(dir, test)
  a = (process.execArgv or []).concat(test)
  child = spawn(process.execPath, a,
    stdio: "inherit"
  )
  child.on "close", (code) ->
    if code
      process.exit code
    else
      console.log ""
      runBenchmarks()
    return

  return
Benchmark = (fn, options) ->
  @fn = fn
  @options = options
  @config = parseOpts(options)
  @_name = require.main.filename.split(/benchmark[\/\\]/).pop()
  @_start = [
    0
    0
  ]
  @_started = false
  self = this
  process.nextTick ->
    self._run()
    return

  return

# benchmark an http server.

# one more more options weren't set.
# run with all combinations

# match each item in the set with each item in the list
parseOpts = (options) ->
  
  # verify that there's an option provided for each of the options
  # if they're not *all* specified, then we return null.
  keys = Object.keys(options)
  num = keys.length
  conf = {}
  i = 2

  while i < process.argv.length
    m = process.argv[i].match(/^(.+)=(.+)$/)
    if not m or not m[1] or not m[2] or not options[m[1]]
      return null
    else
      conf[m[1]] = (if isFinite(m[2]) then +m[2] else m[2])
      num--
    i++
  
  # still go ahead and set whatever WAS set, if it was.
  if num isnt 0
    Object.keys(conf).forEach (k) ->
      options[k] = [conf[k]]
      return

  (if num is 0 then conf else null)
assert = require("assert")
path = require("path")
silent = +process.env.NODE_BENCH_SILENT
exports.PORT = process.env.PORT or 12346
if module is require.main
  type = process.argv[2]
  unless type
    console.error "usage:\n ./node benchmark/common.js <type>"
    process.exit 1
  fs = require("fs")
  dir = path.join(__dirname, type)
  tests = fs.readdirSync(dir)
  spawn = require("child_process").spawn
  runBenchmarks()
exports.createBenchmark = (fn, options) ->
  new Benchmark(fn, options)

Benchmark::http = (p, args, cb) ->
  self = this
  wrk = path.resolve(__dirname, "..", "tools", "wrk", "wrk")
  regexp = /Requests\/sec:[ \t]+([0-9\.]+)/
  spawn = require("child_process").spawn
  url = "http://127.0.0.1:" + exports.PORT + p
  args = args.concat(url)
  out = ""
  child = spawn(wrk, args)
  child.stdout.setEncoding "utf8"
  child.stdout.on "data", (chunk) ->
    out += chunk
    return

  child.on "close", (code) ->
    cb code  if cb
    if code
      console.error "wrk failed with " + code
      process.exit code
    m = out.match(regexp)
    qps = m and +m[1]
    unless qps
      console.error "%j", out
      console.error "wrk produced strange output"
      process.exit 1
    self.report +qps
    return

  return

Benchmark::_run = ->
  run = ->
    argv = queue[i++]
    return  unless argv
    child = spawn(node, argv,
      stdio: "inherit"
    )
    child.on "close", (code, signal) ->
      if code
        console.error "child process exited with code " + code
      else
        run()
      return

    return
  return @fn(@config)  if @config
  main = require.main.filename
  settings = []
  queueLen = 1
  options = @options
  queue = Object.keys(options).reduce((set, key) ->
    vals = options[key]
    assert Array.isArray(vals)
    newSet = new Array(set.length * vals.length)
    j = 0
    set.forEach (s) ->
      vals.forEach (val) ->
        newSet[j++] = s.concat(key + "=" + val)
        return

      return

    newSet
  , [[main]])
  spawn = require("child_process").spawn
  node = process.execPath
  i = 0
  run()
  return

Benchmark::start = ->
  throw new Error("Called start more than once in a single benchmark")  if @_started
  @_started = true
  @_start = process.hrtime()
  return

Benchmark::end = (operations) ->
  elapsed = process.hrtime(@_start)
  throw new Error("called end without start")  unless @_started
  throw new Error("called end() without specifying operation count")  if typeof operations isnt "number"
  time = elapsed[0] + elapsed[1] / 1e9
  rate = operations / time
  @report rate
  return

Benchmark::report = (value) ->
  heading = @getHeading()
  console.log "%s: %s", heading, value.toPrecision(5)  unless silent
  process.exit 0
  return

Benchmark::getHeading = ->
  conf = @config
  @_name + " " + Object.keys(conf).map((key) ->
    key + "=" + conf[key]
  ).join(" ")
