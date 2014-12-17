# only need uniqueness
addLocalTarball = (p, pkgData, shasum, cb) ->
  assert typeof p is "string", "must have path"
  assert typeof cb is "function", "must have callback"
  pkgData = {}  unless pkgData
  
  # If we don't have a shasum yet, compute it.
  unless shasum
    return sha.get(p, (er, shasum) ->
      return cb(er)  if er
      log.silly "addLocalTarball", "shasum (computed)", shasum
      addLocalTarball p, pkgData, shasum, cb
      return
    )
  if pathIsInside(p, npm.cache)
    return cb(new Error("Not a valid cache tarball name: " + p))  if path.basename(p) isnt "package.tgz"
    log.verbose "addLocalTarball", "adding from inside cache", p
    return addPlacedTarball(p, pkgData, shasum, cb)
  addTmpTarball p, pkgData, shasum, (er, data) ->
    if data
      data._resolved = p
      data._shasum = data._shasum or shasum
    cb er, data

  return
addPlacedTarball = (p, pkgData, shasum, cb) ->
  assert pkgData, "should have package data by now"
  assert typeof cb is "function", "cb function required"
  getCacheStat (er, cs) ->
    return cb(er)  if er
    addPlacedTarball_ p, pkgData, cs.uid, cs.gid, shasum, cb

  return
addPlacedTarball_ = (p, pkgData, uid, gid, resolvedSum, cb) ->
  folder = path.join(cachedPackageRoot(pkgData), "package")
  
  # First, make sure we have the shasum, if we don't already.
  unless resolvedSum
    sha.get p, (er, shasum) ->
      return cb(er)  if er
      addPlacedTarball_ p, pkgData, uid, gid, shasum, cb
      return

    return
  mkdir folder, (er) ->
    return cb(er)  if er
    pj = path.join(folder, "package.json")
    json = JSON.stringify(pkgData, null, 2)
    writeFileAtomic pj, json, (er) ->
      cb er, pkgData
      return

    return

  return
addTmpTarball = (tgz, pkgData, shasum, cb) ->
  assert typeof cb is "function", "must have callback function"
  assert shasum, "must have shasum by now"
  cb = inflight("addTmpTarball:" + tgz, cb)
  return log.verbose("addTmpTarball", tgz, "already in flight; not adding")  unless cb
  log.verbose "addTmpTarball", tgz, "not in flight; adding"
  
  # we already have the package info, so just move into place
  if pkgData and pkgData.name and pkgData.version
    log.verbose "addTmpTarball", "already have metadata; skipping unpack for", pkgData.name + "@" + pkgData.version
    return addTmpTarball_(tgz, pkgData, shasum, cb)
  
  # This is a tarball we probably downloaded from the internet.  The shasum's
  # already been checked, but we haven't ever had a peek inside, so we unpack
  # it here just to make sure it is what it says it is.
  #
  # NOTE: we might not have any clue what we think it is, for example if the
  # user just did `npm install ./foo.tgz`
  
  # generate a unique filename
  randomBytes 6, (er, random) ->
    return cb(er)  if er
    target = path.join(npm.tmp, "unpack-" + random.toString("hex"))
    getCacheStat (er, cs) ->
      return cb(er)  if er
      log.verbose "addTmpTarball", "validating metadata from", tgz
      tar.unpack tgz, target, null, null, cs.uid, cs.gid, (er, data) ->
        return cb(er)  if er
        
        # check that this is what we expected.
        unless data.name
          return cb(new Error("No name provided"))
        else return cb(new Error("Invalid Package: expected " + pkgData.name + " but found " + data.name))  if pkgData.name and data.name isnt pkgData.name
        unless data.version
          return cb(new Error("No version provided"))
        else return cb(new Error("Invalid Package: expected " + pkgData.name + "@" + pkgData.version + " but found " + data.name + "@" + data.version))  if pkgData.version and data.version isnt pkgData.version
        addTmpTarball_ tgz, data, shasum, cb
        return

      return

    return

  return
addTmpTarball_ = (tgz, data, shasum, cb) ->
  
  # chown starting from the first dir created by mkdirp,
  # or the root dir, if none had to be created, so that
  # we know that we get all the children.
  done = ->
    data._shasum = data._shasum or shasum
    cb null, data
    return
  assert typeof cb is "function", "must have callback function"
  cb = once(cb)
  assert data.name, "should have package name by now"
  assert data.version, "should have package version by now"
  root = cachedPackageRoot(data)
  pkg = path.resolve(root, "package")
  target = path.resolve(root, "package.tgz")
  getCacheStat (er, cs) ->
    return cb(er)  if er
    mkdir pkg, (er, created) ->
      chown = ->
        chownr created or root, cs.uid, cs.gid, done
        return
      return cb(er)  if er
      read = fs.createReadStream(tgz)
      write = writeStream(target,
        mode: npm.modes.file
      )
      fin = (if cs.uid and cs.gid then chown else done)
      read.on("error", cb).pipe(write).on("error", cb).on "close", fin
      return

    return

  return
mkdir = require("mkdirp")
assert = require("assert")
fs = require("graceful-fs")
writeFileAtomic = require("write-file-atomic")
path = require("path")
sha = require("sha")
npm = require("../npm.js")
log = require("npmlog")
tar = require("../utils/tar.js")
pathIsInside = require("path-is-inside")
getCacheStat = require("./get-stat.js")
cachedPackageRoot = require("./cached-package-root.js")
chownr = require("chownr")
inflight = require("inflight")
once = require("once")
writeStream = require("fs-write-stream-atomic")
randomBytes = require("crypto").pseudoRandomBytes
module.exports = addLocalTarball
