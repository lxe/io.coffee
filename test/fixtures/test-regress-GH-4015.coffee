load = ->
  fs.statSync "."
  load()
  return
fs = require("fs")
load()
