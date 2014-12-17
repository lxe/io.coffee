lockFileName = (base, name) ->
  c = name.replace(/[^a-zA-Z0-9]+/g, "-").replace(/^-+|-+$/g, "")
  p = resolve(base, name)
  h = crypto.createHash("sha1").update(p).digest("hex")
  l = resolve(npm.cache, "_locks")
  resolve l, c.substr(0, 24) + "-" + h.substr(0, 16) + ".lock"
lock = (base, name, cb) ->
  getStat (er) ->
    lockDir = resolve(npm.cache, "_locks")
    mkdirp lockDir, ->
      return cb(er)  if er
      opts =
        stale: npm.config.get("cache-lock-stale")
        retries: npm.config.get("cache-lock-retries")
        wait: npm.config.get("cache-lock-wait")

      lf = lockFileName(base, name)
      lockfile.lock lf, opts, (er) ->
        log.warn "locking", lf, "failed", er  if er
        unless er
          log.verbose "lock", "using", lf, "for", resolve(base, name)
          installLocks[lf] = true
        cb er
        return

      return

    return

  return
unlock = (base, name, cb) ->
  lf = lockFileName(base, name)
  locked = installLocks[lf]
  if locked is false
    process.nextTick cb
  else if locked is true
    lockfile.unlock lf, (er) ->
      if er
        log.warn "unlocking", lf, "failed", er
      else
        installLocks[lf] = false
        log.verbose "unlock", "done using", lf, "for", resolve(base, name)
      cb er
      return

  else
    throw new Error("Attempt to unlock " + resolve(base, name) + ", which hasn't been locked")
  return
crypto = require("crypto")
resolve = require("path").resolve
lockfile = require("lockfile")
log = require("npmlog")
mkdirp = require("mkdirp")
npm = require("../npm.js")
getStat = require("../cache/get-stat.js")
installLocks = {}
module.exports =
  lock: lock
  unlock: unlock
