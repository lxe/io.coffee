cleanup = ->
  process.chdir osenv.tmpdir()
  rimraf.sync pkg
  return
test = require("tap").test
path = require("path")
fs = require("graceful-fs")
crypto = require("crypto")
rimraf = require("rimraf")
osenv = require("osenv")
mkdirp = require("mkdirp")
npm = require("../../")
locker = require("../../lib/utils/locker.js")
lock = locker.lock
unlock = locker.unlock
pkg = path.join(__dirname, "/locker")
cache = path.join(pkg, "/cache")
tmp = path.join(pkg, "/tmp")
nm = path.join(pkg, "/node_modules")
test "setup", (t) ->
  cleanup()
  mkdirp.sync cache
  mkdirp.sync tmp
  t.end()
  return

test "locking file puts lock in correct place", (t) ->
  npm.load
    cache: cache
    tmpdir: tmp
  , (er) ->
    t.ifError er, "npm bootstrapped OK"
    n = "correct"
    c = n.replace(/[^a-zA-Z0-9]+/g, "-").replace(/^-+|-+$/g, "")
    p = path.resolve(nm, n)
    h = crypto.createHash("sha1").update(p).digest("hex")
    l = c.substr(0, 24) + "-" + h.substr(0, 16) + ".lock"
    v = path.join(cache, "_locks", l)
    lock nm, n, (er) ->
      t.ifError er, "locked path"
      fs.exists v, (found) ->
        t.ok found, "lock found OK"
        unlock nm, n, (er) ->
          t.ifError er, "unlocked path"
          fs.exists v, (found) ->
            t.notOk found, "lock deleted OK"
            t.end()
            return

          return

        return

      return

    return

  return

test "unlocking out of order errors out", (t) ->
  npm.load
    cache: cache
    tmpdir: tmp
  , (er) ->
    t.ifError er, "npm bootstrapped OK"
    n = "busted"
    c = n.replace(/[^a-zA-Z0-9]+/g, "-").replace(/^-+|-+$/g, "")
    p = path.resolve(nm, n)
    h = crypto.createHash("sha1").update(p).digest("hex")
    l = c.substr(0, 24) + "-" + h.substr(0, 16) + ".lock"
    v = path.join(cache, "_locks", l)
    fs.exists v, (found) ->
      t.notOk found, "no lock to unlock"
      t.throws (->
        unlock nm, n, ->
          t.fail "shouldn't get here"
          t.end()
          return

        return
      ), "blew up as expected"
      t.end()
      return

    return

  return

test "cleanup", (t) ->
  cleanup()
  t.end()
  return

