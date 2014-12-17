# try to find the most reasonable prefix to use
findPrefix = (p, cb_) ->
  cb = (er, p) ->
    process.nextTick ->
      cb_ er, p
      return

    return
  p = path.resolve(p)
  
  # if there's no node_modules folder, then
  # walk up until we hopefully find one.
  # if none anywhere, then use cwd.
  walkedUp = false
  while path.basename(p) is "node_modules"
    p = path.dirname(p)
    walkedUp = true
  return cb(null, p)  if walkedUp
  findPrefix_ p, p, cb
  return
findPrefix_ = (p, original, cb) ->
  return cb(null, original)  if p is "/" or (process.platform is "win32" and p.match(/^[a-zA-Z]:(\\|\/)?$/))
  fs.readdir p, (er, files) ->
    
    # an error right away is a bad sign.
    # unless the prefix was simply a non
    # existent directory.
    if er and p is original
      return cb(null, original)  if er.code is "ENOENT"
      return cb(er)
    
    # walked up too high or something.
    return cb(null, original)  if er
    return cb(null, p)  if files.indexOf("node_modules") isnt -1 or files.indexOf("package.json") isnt -1
    d = path.dirname(p)
    return cb(null, original)  if d is p
    findPrefix_ d, original, cb

  return
module.exports = findPrefix
fs = require("fs")
path = require("path")
