linkIfExists = (from, to, gently, cb) ->
  fs.stat from, (er) ->
    return cb()  if er
    link from, to, gently, cb
    return

  return
link = (from, to, gently, cb) ->
  if typeof cb isnt "function"
    cb = gently
    gently = null
  gently = false  if npm.config.get("force")
  to = path.resolve(to)
  target = from = path.resolve(from)
  if process.platform isnt "win32"
    
    # junctions on windows must be absolute
    target = path.relative(path.dirname(to), from)
    
    # if there is no folder in common, then it will be much
    # longer, and using a relative link is dumb.
    target = from  if target.length >= from.length
  chain [
    [
      fs
      "stat"
      from
    ]
    [
      rm
      to
      gently
    ]
    [
      mkdir
      path.dirname(to)
    ]
    [
      fs
      "symlink"
      target
      to
      "junction"
    ]
  ], cb
  return
module.exports = link
link.ifExists = linkIfExists
fs = require("graceful-fs")
chain = require("slide").chain
mkdir = require("mkdirp")
rm = require("./gently-rm.js")
path = require("path")
npm = require("../npm.js")
