# only remove the thing if it's a symlink into a specific folder.
# This is a very common use-case of npm's, but not so common elsewhere.
gentlyRm = (path, gently, cb) ->
  unless cb
    cb = gently
    gently = null
  
  # never rm the root, prefix, or bin dirs.
  # just a safety precaution.
  prefixes = [
    npm.dir
    npm.root
    npm.bin
    npm.prefix
    npm.globalDir
    npm.globalRoot
    npm.globalBin
    npm.globalPrefix
  ]
  resolved = resolve(path)
  if prefixes.indexOf(resolved) isnt -1
    log.verbose "gentlyRm", resolved, "is part of npm and can't be removed"
    return cb(new Error("May not delete: " + resolved))
  options = log: log.silly.bind(log, "gentlyRm")
  options.purge = true  if npm.config.get("force") or not gently
  unless gently
    log.verbose "gentlyRm", "vacuuming", resolved
    return vacuum(resolved, options, cb)
  parent = resolve(gently)
  log.verbose "gentlyRm", "verifying that", parent, "is managed by npm"
  some prefixes, isManaged(parent), (er, matched) ->
    return cb(er)  if er
    unless matched
      log.verbose "gentlyRm", parent, "is not managed by npm"
      return clobberFail(resolved, parent, cb)
    log.silly "gentlyRm", parent, "is managed by npm"
    if isInside(resolved, parent)
      log.silly "gentlyRm", resolved, "is under", parent
      log.verbose "gentlyRm", "vacuuming", resolved, "up to", parent
      options.base = parent
      return vacuum(resolved, options, cb)
    log.silly "gentlyRm", resolved, "is not under", parent
    log.silly "gentlyRm", "checking to see if", resolved, "is a link"
    lstat resolved, (er, stat) ->
      if er
        return cb(null)  if er.code is "ENOENT"
        return cb(er)
      unless stat.isSymbolicLink()
        log.verbose "gentlyRm", resolved, "is outside", parent, "and not a link"
        return clobberFail(resolved, parent, cb)
      log.silly "gentlyRm", resolved, "is a link"
      readlink resolved, (er, link) ->
        if er
          return cb(null)  if er.code is "ENOENT"
          return cb(er)
        source = resolve(dirname(resolved), link)
        if isInside(source, parent)
          log.silly "gentlyRm", source, "inside", parent
          log.verbose "gentlyRm", "vacuuming", resolved
          return vacuum(resolved, options, cb)
        log.silly "gentlyRm", "checking to see if", source, "is managed by npm"
        some prefixes, isManaged(source), (er, matched) ->
          return cb(er)  if er
          if matched
            log.silly "gentlyRm", source, "is under", matched
            log.verbose "gentlyRm", "removing", resolved
            rimraf resolved, cb
          log.verbose "gentlyRm", source, "is not managed by npm"
          clobberFail path, parent, cb

        return

      return

    return

  return
isManaged = (target) ->
  predicate = (path, cb) ->
    unless path
      log.verbose "isManaged", "no path"
      return cb(null, false)
    path = resolve(path)
    
    # if the path has already been memoized, return immediately
    resolved = resolvedPaths[path]
    if resolved
      inside = isInside(target, resolved)
      log.silly "isManaged", target, (if inside then "is" else "is not"), "inside", resolved
      return cb(null, inside and path)
    
    # otherwise, check the path
    lstat path, (er, stat) ->
      if er
        return cb(null, false)  if er.code is "ENOENT"
        return cb(er)
      
      # if it's not a link, cache & test the path itself
      return cacheAndTest(path, path, target, cb)  unless stat.isSymbolicLink()
      
      # otherwise, cache & test the link's source
      readlink path, (er, source) ->
        if er
          return cb(null, false)  if er.code is "ENOENT"
          return cb(er)
        cacheAndTest resolve(path, source), path, target, cb
        return

      return

    return
  cacheAndTest = (resolved, source, target, cb) ->
    resolvedPaths[source] = resolved
    inside = isInside(target, resolved)
    log.silly "cacheAndTest", target, (if inside then "is" else "is not"), "inside", resolved
    cb null, inside and source
    return
  return predicate
  return
clobberFail = (p, g, cb) ->
  er = new Error("Refusing to delete: " + p + " not in " + g)
  er.code = "EEXIST"
  er.path = p
  cb er
module.exports = gentlyRm
npm = require("../npm.js")
log = require("npmlog")
resolve = require("path").resolve
dirname = require("path").dirname
lstat = require("graceful-fs").lstat
readlink = require("graceful-fs").readlink
isInside = require("path-is-inside")
vacuum = require("fs-vacuum")
rimraf = require("rimraf")
some = require("async-some")
resolvedPaths = {}
