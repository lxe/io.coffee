
# to maintain the cache dir's permissions consistently.
makeCacheDir = (cb) ->
  afterMkdir = (er, made) ->
    return cb(er, cacheStat)  if er or not cacheStat or isNaN(cacheStat.uid) or isNaN(cacheStat.gid)
    return cb(er, cacheStat)  unless made
    
    # ensure that the ownership is correct.
    chownr made, cacheStat.uid, cacheStat.gid, (er) ->
      cb er, cacheStat

    return
  cb = inflight("makeCacheDir", cb)
  return log.verbose("getCacheStat", "cache creation already in flight; waiting")  unless cb
  log.verbose "getCacheStat", "cache creation not in flight; initializing"
  unless process.getuid
    return mkdir(npm.cache, (er) ->
      cb er, {}
    )
  uid = +process.getuid()
  gid = +process.getgid()
  if uid is 0
    uid = +process.env.SUDO_UID  if process.env.SUDO_UID
    gid = +process.env.SUDO_GID  if process.env.SUDO_GID
  if uid isnt 0 or not process.env.HOME
    cacheStat =
      uid: uid
      gid: gid

    return mkdir(npm.cache, afterMkdir)
  fs.stat process.env.HOME, (er, st) ->
    if er
      log.error "makeCacheDir", "homeless?"
      return cb(er)
    cacheStat = st
    log.silly "makeCacheDir", "cache dir uid, gid", [
      st.uid
      st.gid
    ]
    mkdir npm.cache, afterMkdir

  return
mkdir = require("mkdirp")
fs = require("graceful-fs")
log = require("npmlog")
chownr = require("chownr")
npm = require("../npm.js")
inflight = require("inflight")
cacheStat = null
module.exports = getCacheStat = (cb) ->
  return cb(null, cacheStat)  if cacheStat
  fs.stat npm.cache, (er, st) ->
    return makeCacheDir(cb)  if er
    unless st.isDirectory()
      log.error "getCacheStat", "invalid cache dir %j", npm.cache
      return cb(er)
    cb null, cacheStat = st

  return
