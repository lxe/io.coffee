
# remove a package.
uninstall = (args, cb) ->
  
  # this is super easy
  # get the list of args that correspond to package names in either
  # the global npm.dir,
  # then call unbuild on all those folders to pull out their bins
  # and mans and whatnot, and then delete the folder.
  nm = npm.dir
  args = []  if args.length is 1 and args[0] is "."
  return uninstall_(args, nm, cb)  if args.length
  
  # remove this package from the global space, if it's installed there
  return cb(uninstall.usage)  if npm.config.get("global")
  readJson path.resolve(npm.prefix, "package.json"), (er, pkg) ->
    return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
    return cb(uninstall.usage)  if er
    uninstall_ [pkg.name], npm.dir, cb
    return

  return
uninstall_ = (args, nm, cb) ->
  
  # if we've been asked to --save or --save-dev or --save-optional,
  # then also remove it from the associated dependencies hash.
  s = npm.config.get("save")
  d = npm.config.get("save-dev")
  o = npm.config.get("save-optional")
  cb = saver(args, nm, cb)  if s or d or o
  asyncMap args, ((arg, cb) ->
    
    # uninstall .. should not delete /usr/local/lib/node_modules/..
    p = path.join(path.resolve(nm), path.join("/", arg))
    if path.resolve(p) is nm
      log.warn "uninstall", "invalid argument: %j", arg
      return cb(null, [])
    fs.lstat p, (er) ->
      if er
        log.warn "uninstall", "not installed in %s: %j", nm, arg
        return cb(null, [])
      cb null, p
      return

    return
  ), (er, folders) ->
    return cb(er)  if er
    asyncMap folders, npm.commands.unbuild, cb
    return

  return
saver = (args, nm, cb_) ->
  cb = (er, data) ->
    s = npm.config.get("save")
    d = npm.config.get("save-dev")
    o = npm.config.get("save-optional")
    return cb_(er, data)  if er or not (s or d or o)
    pj = path.resolve(nm, "..", "package.json")
    
    # don't use readJson here, because we don't want all the defaults
    # filled in, for mans and other bs.
    fs.readFile pj, "utf8", (er, json) ->
      pkg = undefined
      try
        pkg = JSON.parse(json)
      return cb_(null, data)  unless pkg
      bundle = undefined
      if npm.config.get("save-bundle")
        bundle = pkg.bundleDependencies or pkg.bundledDependencies
        bundle = `undefined`  unless Array.isArray(bundle)
      changed = false
      args.forEach (a) ->
        [
          [
            s
            "dependencies"
          ]
          [
            o
            "optionalDependencies"
          ]
          [
            d
            "devDependencies"
          ]
        ].forEach (f) ->
          flag = f[0]
          field = f[1]
          return changed = true  if not flag or not pkg[field] or not pkg[field].hasOwnProperty(a)
          if bundle
            i = bundle.indexOf(a)
            bundle.splice i, 1  if i isnt -1
          delete pkg[field][a]

          return

        return

      return cb_(null, data)  unless changed
      if bundle
        delete pkg.bundledDependencies

        if bundle.length
          pkg.bundleDependencies = bundle
        else
          delete pkg.bundleDependencies
      writeFileAtomic pj, JSON.stringify(pkg, null, 2) + "\n", (er) ->
        cb_ er, data

      return

    return
  return cb
  return
module.exports = uninstall
uninstall.usage = "npm uninstall <name>[@<version> [<name>[@<version>] ...]" + "\nnpm rm <name>[@<version> [<name>[@<version>] ...]"
uninstall.completion = require("./utils/completion/installed-shallow.js")
fs = require("graceful-fs")
writeFileAtomic = require("write-file-atomic")
log = require("npmlog")
readJson = require("read-package-json")
path = require("path")
npm = require("./npm.js")
asyncMap = require("slide").asyncMap
