root = (args, silent, cb) ->
  if typeof cb isnt "function"
    cb = silent
    silent = false
  console.log npm.dir  unless silent
  process.nextTick cb.bind(this, null, npm.dir)
  return
module.exports = root
npm = require("./npm.js")
root.usage = "npm root\nnpm root -g\n(just prints the root folder)"
