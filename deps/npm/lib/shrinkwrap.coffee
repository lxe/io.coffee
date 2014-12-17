# emit JSON describing versions of all packages currently installed (for later
# use with shrinkwrap install)
shrinkwrap = (args, silent, cb) ->
  if typeof cb isnt "function"
    cb = silent
    silent = false
  log.warn "shrinkwrap", "doesn't take positional args"  if args.length
  npm.commands.ls [], true, (er, _, pkginfo) ->
    return cb(er)  if er
    shrinkwrap_ pkginfo, silent, npm.config.get("dev"), cb
    return

  return
shrinkwrap_ = (pkginfo, silent, dev, cb) ->
  return cb(new Error("Problems were encountered\n" + "Please correct and try again.\n" + pkginfo.problems.join("\n")))  if pkginfo.problems
  unless dev
    
    # remove dev deps unless the user does --dev
    readJson path.resolve(npm.prefix, "package.json"), (er, data) ->
      return cb(er)  if er
      if data.devDependencies
        Object.keys(data.devDependencies).forEach (dep) ->
          
          # do not exclude the dev dependency if it's also listed as a dependency
          return  if data.dependencies and data.dependencies[dep]
          log.warn "shrinkwrap", "Excluding devDependency: %s", dep
          delete pkginfo.dependencies[dep]

          return

      save pkginfo, silent, cb
      return

  else
    save pkginfo, silent, cb
  return
save = (pkginfo, silent, cb) ->
  
  # copy the keys over in a well defined order
  # because javascript objects serialize arbitrarily
  pkginfo.dependencies = sortedObject(pkginfo.dependencies or {})
  swdata = undefined
  try
    swdata = JSON.stringify(pkginfo, null, 2) + "\n"
  catch er
    log.error "shrinkwrap", "Error converting package info to json"
    return cb(er)
  file = path.resolve(npm.prefix, "npm-shrinkwrap.json")
  writeFileAtomic file, swdata, (er) ->
    return cb(er)  if er
    return cb(null, pkginfo)  if silent
    console.log "wrote npm-shrinkwrap.json"
    cb null, pkginfo
    return

  return
module.exports = exports = shrinkwrap
npm = require("./npm.js")
log = require("npmlog")
fs = require("fs")
writeFileAtomic = require("write-file-atomic")
path = require("path")
readJson = require("read-package-json")
sortedObject = require("sorted-object")
shrinkwrap.usage = "npm shrinkwrap"
