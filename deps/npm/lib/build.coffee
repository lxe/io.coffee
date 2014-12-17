# npm build command

# everything about the installation after the creation of
# the .npm/{name}/{version}/package folder.
# linking the modules into the npm.root,
# resolving dependencies, etc.

# This runs AFTER install or link are completed.
build = (args, global, didPre, didRB, cb) ->
  if typeof cb isnt "function"
    cb = didRB
    didRB = false
  if typeof cb isnt "function"
    cb = didPre
    didPre = false
  if typeof cb isnt "function"
    cb = global
    global = npm.config.get("global")
  
  # it'd be nice to asyncMap these, but actually, doing them
  # in parallel generally munges up the output from node-waf
  builder = build_(global, didPre, didRB)
  chain args.map((arg) ->
    (cb) ->
      builder arg, cb
      return
  ), cb
  return
build_ = (global, didPre, didRB) ->
  (folder, cb) ->
    folder = path.resolve(folder)
    log.error "build", "already built", folder  if build._didBuild[folder]
    build._didBuild[folder] = true
    log.info "build", folder
    readJson path.resolve(folder, "package.json"), (er, pkg) ->
      return cb(er)  if er
      chain [
        not didPre and [
          lifecycle
          pkg
          "preinstall"
          folder
        ]
        [
          linkStuff
          pkg
          folder
          global
          didRB
        ]
        [
          writeBuiltinConf
          pkg
          folder
        ]
        didPre isnt build._noLC and [
          lifecycle
          pkg
          "install"
          folder
        ]
        didPre isnt build._noLC and [
          lifecycle
          pkg
          "postinstall"
          folder
        ]
        didPre isnt build._noLC and npm.config.get("npat") and [
          lifecycle
          pkg
          "test"
          folder
        ]
      ], cb
      return

    return
writeBuiltinConf = (pkg, folder, cb) ->
  
  # the builtin config is "sticky". Any time npm installs
  # itself globally, it puts its builtin config file there
  parent = path.dirname(folder)
  dir = npm.globalDir
  return cb()  if pkg.name isnt "npm" or not npm.config.get("global") or not npm.config.usingBuiltin or dir isnt parent
  data = ini.stringify(npm.config.sources.builtin.data)
  writeFile path.resolve(folder, "npmrc"), data, cb
  return
linkStuff = (pkg, folder, global, didRB, cb) ->
  
  # allow to opt out of linking binaries.
  return cb()  if npm.config.get("bin-links") is false
  
  # if it's global, and folder is in {prefix}/node_modules,
  # then bins are in {prefix}/bin
  # otherwise, then bins are in folder/../.bin
  parent = (if pkg.name[0] is "@" then path.dirname(path.dirname(folder)) else path.dirname(folder))
  gnm = global and npm.globalDir
  gtop = parent is gnm
  log.verbose "linkStuff", [
    global
    gnm
    gtop
    parent
  ]
  log.info "linkStuff", pkg._id
  shouldWarn pkg, folder, global, ->
    asyncMap [
      linkBins
      linkMans
      not didRB and rebuildBundles
    ], ((fn, cb) ->
      return cb()  unless fn
      log.verbose fn.name, pkg._id
      fn pkg, folder, parent, gtop, cb
      return
    ), cb
    return

  return
shouldWarn = (pkg, folder, global, cb) ->
  parent = path.dirname(folder)
  top = parent is npm.dir
  cwd = npm.localPrefix
  readJson path.resolve(cwd, "package.json"), (er, topPkg) ->
    return cb(er)  if er
    linkedPkg = path.basename(cwd)
    currentPkg = path.basename(folder)
    
    # current searched package is the linked package on first call
    if linkedPkg isnt currentPkg
      return cb()  unless topPkg.dependencies
      
      # don't generate a warning if it's listed in dependencies
      log.warn "prefer global", pkg._id + " should be installed with -g"  if top and pkg.preferGlobal and not global  if Object.keys(topPkg.dependencies).indexOf(currentPkg) is -1
    cb()
    return

  return
rebuildBundles = (pkg, folder, parent, gtop, cb) ->
  return cb()  unless npm.config.get("rebuild-bundle")
  deps = Object.keys(pkg.dependencies or {}).concat(Object.keys(pkg.devDependencies or {}))
  bundles = pkg.bundleDependencies or pkg.bundledDependencies or []
  fs.readdir path.resolve(folder, "node_modules"), (er, files) ->
    
    # error means no bundles
    return cb()  if er
    log.verbose "rebuildBundles", files
    
    # don't asyncMap these, because otherwise build script output
    # gets interleaved and is impossible to read
    
    # rebuild if:
    # not a .folder, like .bin or .hooks
    
    # not some old 0.x style bundle
    
    # either not a dep, or explicitly bundled
    chain files.filter((file) ->
      not file.match(/^[\._-]/) and file.indexOf("@") is -1 and (deps.indexOf(file) is -1 or bundles.indexOf(file) isnt -1)
    ).map((file) ->
      file = path.resolve(folder, "node_modules", file)
      (cb) ->
        return cb()  if build._didBuild[file]
        log.verbose "rebuild bundle", file
        
        # if file is not a package dir, then don't do it.
        fs.lstat path.resolve(file, "package.json"), (er) ->
          return cb()  if er
          build_(false) file, cb
          return

        return
    ), cb
    return

  return
linkBins = (pkg, folder, parent, gtop, cb) ->
  return cb()  if not pkg.bin or not gtop and path.basename(parent) isnt "node_modules"
  binRoot = (if gtop then npm.globalBin else path.resolve(parent, ".bin"))
  log.verbose "link bins", [
    pkg.bin
    binRoot
    gtop
  ]
  asyncMap Object.keys(pkg.bin), ((b, cb) ->
    linkBin path.resolve(folder, pkg.bin[b]), path.resolve(binRoot, b), gtop and folder, (er) ->
      return cb(er)  if er
      
      # bins should always be executable.
      # XXX skip chmod on windows?
      src = path.resolve(folder, pkg.bin[b])
      fs.chmod src, npm.modes.exec, (er) ->
        return cb()  if er and er.code is "ENOENT" and npm.config.get("ignore-scripts")
        return cb(er)  if er or not gtop
        dest = path.resolve(binRoot, b)
        out = (if npm.config.get("parseable") then dest + "::" + src + ":BINFILE" else dest + " -> " + src)
        console.log out
        cb()
        return

      return

    return
  ), cb
  return
linkBin = (from, to, gently, cb) ->
  if process.platform isnt "win32"
    linkIfExists from, to, gently, cb
  else
    cmdShimIfExists from, to, cb
linkMans = (pkg, folder, parent, gtop, cb) ->
  return cb()  if not pkg.man or not gtop or process.platform is "win32"
  manRoot = path.resolve(npm.config.get("prefix"), "share", "man")
  
  # make sure that the mans are unique.
  # otherwise, if there are dupes, it'll fail with EEXIST
  set = pkg.man.reduce((acc, man) ->
    acc[path.basename(man)] = man
    acc
  , {})
  pkg.man = pkg.man.filter((man) ->
    set[path.basename(man)] is man
  )
  asyncMap pkg.man, ((man, cb) ->
    return cb()  if typeof man isnt "string"
    parseMan = man.match(/(.*\.([0-9]+)(\.gz)?)$/)
    stem = parseMan[1]
    sxn = parseMan[2]
    bn = path.basename(stem)
    manDest = path.join(manRoot, "man" + sxn, bn)
    linkIfExists man, manDest, gtop and folder, cb
    return
  ), cb
  return
npm = require("./npm.js")
log = require("npmlog")
chain = require("slide").chain
fs = require("graceful-fs")
path = require("path")
lifecycle = require("./utils/lifecycle.js")
readJson = require("read-package-json")
link = require("./utils/link.js")
linkIfExists = link.ifExists
cmdShim = require("cmd-shim")
cmdShimIfExists = cmdShim.ifExists
asyncMap = require("slide").asyncMap
ini = require("ini")
writeFile = require("write-file-atomic")
module.exports = build
build.usage = "npm build <folder>\n(this is plumbing)"
build._didBuild = {}
build._noLC = {}
