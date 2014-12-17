
# args is a list of folders.
# remove any bins/etc, and then delete the folder.
unbuild = (args, silent, cb) ->
  if typeof silent is "function"
    cb = silent
    silent = false
  asyncMap args, unbuild_(silent), cb
  return
unbuild_ = (silent) ->
  (folder, cb_) ->
    cb = (er) ->
      cb_ er, path.relative(npm.root, folder)
      return
    folder = path.resolve(folder)
    delete build._didBuild[folder]

    log.verbose "unbuild", folder.substr(npm.prefix.length + 1)
    readJson path.resolve(folder, "package.json"), (er, pkg) ->
      
      # if no json, then just trash it, but no scripts or whatever.
      return gentlyRm(folder, false, cb)  if er
      readJson.cache.del folder
      chain [
        [
          lifecycle
          pkg
          "preuninstall"
          folder
          false
          true
        ]
        [
          lifecycle
          pkg
          "uninstall"
          folder
          false
          true
        ]
        not silent and (cb) ->
          console.log "unbuild " + pkg._id
          cb()
          return
        [
          rmStuff
          pkg
          folder
        ]
        [
          lifecycle
          pkg
          "postuninstall"
          folder
          false
          true
        ]
        [
          gentlyRm
          folder
          `undefined`
        ]
      ], cb
      return

    return
rmStuff = (pkg, folder, cb) ->
  
  # if it's global, and folder is in {prefix}/node_modules,
  # then bins are in {prefix}/bin
  # otherwise, then bins are in folder/../.bin
  parent = path.dirname(folder)
  gnm = npm.dir
  top = gnm is parent
  readJson.cache.del path.resolve(folder, "package.json")
  log.verbose "unbuild rmStuff", pkg._id, "from", gnm
  log.verbose "unbuild rmStuff", "in", parent  unless top
  asyncMap [
    rmBins
    rmMans
  ], ((fn, cb) ->
    fn pkg, folder, parent, top, cb
    return
  ), cb
  return
rmBins = (pkg, folder, parent, top, cb) ->
  return cb()  unless pkg.bin
  binRoot = (if top then npm.bin else path.resolve(parent, ".bin"))
  log.verbose [
    binRoot
    pkg.bin
  ], "binRoot"
  asyncMap Object.keys(pkg.bin), ((b, cb) ->
    if process.platform is "win32"
      chain [
        [
          gentlyRm
          path.resolve(binRoot, b) + ".cmd"
          `undefined`
        ]
        [
          gentlyRm
          path.resolve(binRoot, b)
          `undefined`
        ]
      ], cb
    else
      gentlyRm path.resolve(binRoot, b), not npm.config.get("force") and folder, cb
    return
  ), cb
  return
rmMans = (pkg, folder, parent, top, cb) ->
  return cb()  if not pkg.man or not top or process.platform is "win32" or not npm.config.get("global")
  manRoot = path.resolve(npm.config.get("prefix"), "share", "man")
  asyncMap pkg.man, ((man, cb) ->
    rmMan = (man) ->
      parseMan = man.match(/(.*)\.([0-9]+)(\.gz)?$/)
      stem = parseMan[1]
      sxn = parseMan[2]
      gz = parseMan[3] or ""
      bn = path.basename(stem)
      manDest = path.join(manRoot, "man" + sxn, ((if bn.indexOf(pkg.name) is 0 then bn else pkg.name + "-" + bn)) + "." + sxn + gz)
      gentlyRm manDest, not npm.config.get("force") and folder, cb
      return
    if Array.isArray(man)
      man.forEach rmMan
    else
      rmMan man
    return
  ), cb
  return
module.exports = unbuild
unbuild.usage = "npm unbuild <folder>\n(this is plumbing)"
readJson = require("read-package-json")
gentlyRm = require("./utils/gently-rm.js")
npm = require("./npm.js")
path = require("path")
lifecycle = require("./utils/lifecycle.js")
asyncMap = require("slide").asyncMap
chain = require("slide").chain
log = require("npmlog")
build = require("./build.js")
