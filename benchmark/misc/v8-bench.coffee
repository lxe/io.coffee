# compare with "google-chrome deps/v8/benchmarks/run.html"
fs = require("fs")
path = require("path")
vm = require("vm")
dir = path.join(__dirname, "..", "..", "deps", "v8", "benchmarks")
global.print = (s) ->
  return  if s is "----"
  console.log "misc/v8_bench.js %s", s
  return

global.load = (x) ->
  source = fs.readFileSync(path.join(dir, x), "utf8")
  vm.runInThisContext source, x
  return

load "run.js"
