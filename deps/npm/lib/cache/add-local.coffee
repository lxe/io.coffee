addLocal = (p, pkgData, cb_) ->
  cb = (er, data) ->
    if er
      log.error "addLocal", "Could not install %s", p.spec
      return cb_(er)
    data._from = path.relative(npm.prefix, p.spec) or "."  if data and not data._fromGithub
    cb_ er, data
  assert typeof p is "object", "must have spec info"
  assert typeof cb is "function", "must have callback"
  pkgData = pkgData or {}
  if p.type is "directory"
    addLocalDirectory p.spec, pkgData, null, cb
  else
    addLocalTarball p.spec, pkgData, null, cb
  return

# At this point, if shasum is set, it's something that we've already
# read and checked.  Just stashing it in the data at this point.
addLocalDirectory = (p, pkgData, shasum, cb) ->
  assert pkgData, "must pass package data"
  assert typeof cb is "function", "must have callback"
  
  # if it's a folder, then read the package.json,
  # tar it to the proper place, and add the cache tar
  return cb(new Error("Adding a cache directory to the cache will make the world implode."))  if pathIsInside(p, npm.cache)
  readJson path.join(p, "package.json"), false, (er, data) ->
    
    # pack to {cache}/name/ver/package.tgz
    next = (er) ->
      return cb(er)  if er
      
      # if we have the shasum already, just add it
      if shasum
        addLocalTarball tgz, data, shasum, cb
      else
        sha.get tgz, (er, shasum) ->
          return cb(er)  if er
          data._shasum = shasum
          addLocalTarball tgz, data, shasum, cb

      return
    return cb(er)  if er
    unless data.name
      return cb(new Error("No name provided in package.json"))
    else return cb(new Error("Invalid package: expected " + pkgData.name + " but found " + data.name))  if pkgData.name and pkgData.name isnt data.name
    unless data.version
      return cb(new Error("No version provided in package.json"))
    else return cb(new Error("Invalid package: expected " + pkgData.name + "@" + pkgData.version + " but found " + data.name + "@" + data.version))  if pkgData.version and pkgData.version isnt data.version
    deprCheck data
    root = cachedPackageRoot(data)
    tgz = path.resolve(root, "package.tgz")
    pj = path.resolve(root, "package/package.json")
    getCacheStat (er, cs) ->
      mkdir path.dirname(pj), (er, made) ->
        return cb(er)  if er
        fancy = not pathIsInside(p, npm.tmp)
        tar.pack tgz, p, data, fancy, (er) ->
          if er
            log.error "addLocalDirectory", "Could not pack %j to %j", p, tgz
            return cb(er)
          next()  if not cs or isNaN(cs.uid) or isNaN(cs.gid)
          chownr made or tgz, cs.uid, cs.gid, next
          return

        return

      return

    return

  return
assert = require("assert")
path = require("path")
mkdir = require("mkdirp")
chownr = require("chownr")
pathIsInside = require("path-is-inside")
readJson = require("read-package-json")
log = require("npmlog")
npm = require("../npm.js")
tar = require("../utils/tar.js")
deprCheck = require("../utils/depr-check.js")
getCacheStat = require("./get-stat.js")
cachedPackageRoot = require("./cached-package-root.js")
addLocalTarball = require("./add-local-tarball.js")
sha = require("sha")
module.exports = addLocal
