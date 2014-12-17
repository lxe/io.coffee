bin = (args, silent, cb) ->
  if typeof cb isnt "function"
    cb = silent
    silent = false
  b = npm.bin
  PATH = (process.env.PATH or "").split(":")
  console.log b  unless silent
  process.nextTick cb.bind(this, null, b)
  npm.config.get("logstream").write "(not in PATH env variable)\n"  if npm.config.get("global") and PATH.indexOf(b) is -1
  return
module.exports = bin
npm = require("./npm.js")
bin.usage = "npm bin\nnpm bin -g\n(just prints the bin folder)"
