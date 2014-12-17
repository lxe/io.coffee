prefix = (args, silent, cb) ->
  if typeof cb isnt "function"
    cb = silent
    silent = false
  console.log npm.prefix  unless silent
  process.nextTick cb.bind(this, null, npm.prefix)
  return
module.exports = prefix
npm = require("./npm.js")
prefix.usage = "npm prefix\nnpm prefix -g\n(just prints the prefix folder)"
