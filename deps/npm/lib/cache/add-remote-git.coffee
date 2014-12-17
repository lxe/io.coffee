
# 1. cacheDir = path.join(cache,'_git-remotes',sha1(u))
# 2. checkGitDir(cacheDir) ? 4. : 3. (rm cacheDir if necessary)
# 3. git clone --mirror u cacheDir
# 4. cd cacheDir && git fetch -a origin
# 5. git archive /tmp/random.tgz
# 6. addLocalTarball(/tmp/random.tgz) <gitref> --format=tar --prefix=package/
# silent flag is used if this should error quietly

# git is so tricky!
# if the path is like ssh://foo:22/some/path then it works, but
# it needs the ssh://
# If the path is like ssh://foo:some/path then it works, but
# only if you remove the ssh://

# ssh paths that are scp-style urls don't need the ssh://

# figure out what we should check out.

# we don't need global templates when cloning.  use this empty dir to specify as template dir
checkGitDir = (p, u, co, origUrl, silent, cb) ->
  fs.stat p, (er, s) ->
    return cloneGitRemote(p, u, co, origUrl, silent, cb)  if er
    unless s.isDirectory()
      return rm(p, (er) ->
        return cb(er)  if er
        cloneGitRemote p, u, co, origUrl, silent, cb
        return
      )
    args = [
      "config"
      "--get"
      "remote.origin.url"
    ]
    env = gitEnv()
    
    # check for git
    git.whichAndExec args,
      cwd: p
      env: env
    , (er, stdout, stderr) ->
      stdoutTrimmed = (stdout + "\n" + stderr).trim()
      if er or u isnt stdout.trim()
        log.warn "`git config --get remote.origin.url` returned " + "wrong result (" + u + ")", stdoutTrimmed
        return rm(p, (er) ->
          return cb(er)  if er
          cloneGitRemote p, u, co, origUrl, silent, cb
          return
        )
      log.verbose "git remote.origin.url", stdoutTrimmed
      archiveGitRemote p, u, co, origUrl, cb
      return

    return

  return
cloneGitRemote = (p, u, co, origUrl, silent, cb) ->
  mkdir p, (er) ->
    return cb(er)  if er
    args = [
      "clone"
      "--template=" + path.join(npm.config.get("cache"), "_git_remotes", "_templates")
      "--mirror"
      u
      p
    ]
    env = gitEnv()
    
    # check for git
    git.whichAndExec args,
      cwd: p
      env: env
    , (er, stdout, stderr) ->
      stdout = (stdout + "\n" + stderr).trim()
      if er
        if silent
          log.verbose "git clone " + u, stdout
        else
          log.error "git clone " + u, stdout
        return cb(er)
      log.verbose "git clone " + u, stdout
      archiveGitRemote p, u, co, origUrl, cb
      return

    return

  return
archiveGitRemote = (p, u, co, origUrl, cb) ->
  resolveHead = ->
    git.whichAndExec resolve,
      cwd: p
      env: env
    , (er, stdout, stderr) ->
      stdout = (stdout + "\n" + stderr).trim()
      if er
        log.error "Failed resolving git HEAD (" + u + ")", stderr
        return cb(er)
      log.verbose "git rev-list -n1 " + co, stdout
      parsed = url.parse(origUrl)
      parsed.hash = stdout
      resolved = url.format(parsed)
      resolved = "git+" + resolved  if parsed.protocol isnt "git:"
      
      # https://github.com/npm/npm/issues/3224
      # node incorrectly sticks a / at the start of the path
      # We know that the host won't change, so split and detect this
      spo = origUrl.split(parsed.host)
      spr = resolved.split(parsed.host)
      spr[1] = spr[1].slice(1)  if spo[1].charAt(0) is ":" and spr[1].charAt(0) is "/"
      resolved = spr.join(parsed.host)
      log.verbose "resolved git url", resolved
      next()
      return

    return
  next = ->
    mkdir path.dirname(tmp), (er) ->
      return cb(er)  if er
      gzip = zlib.createGzip(level: 9)
      args = [
        "archive"
        co
        "--format=tar"
        "--prefix=package/"
      ]
      out = writeStream(tmp)
      env = gitEnv()
      cb = once(cb)
      cp = git.spawn(args,
        env: env
        cwd: p
      )
      cp.on "error", cb
      cp.stderr.on "data", (chunk) ->
        log.silly chunk.toString(), "git archive"
        return

      cp.stdout.pipe(gzip).pipe(out).on "close", ->
        addLocalTarball tmp, null, null, (er, data) ->
          data._resolved = resolved  if data
          cb er, data
          return

        return

      return

    return
  archive = [
    "fetch"
    "-a"
    "origin"
  ]
  resolve = [
    "rev-list"
    "-n1"
    co
  ]
  env = gitEnv()
  resolved = null
  tmp = undefined
  git.whichAndExec archive,
    cwd: p
    env: env
  , (er, stdout, stderr) ->
    stdout = (stdout + "\n" + stderr).trim()
    if er
      log.error "git fetch -a origin (" + u + ")", stdout
      return cb(er)
    log.verbose "git fetch -a origin (" + u + ")", stdout
    tmp = path.join(npm.tmp, Date.now() + "-" + Math.random(), "tmp.tgz")
    if process.platform is "win32"
      log.silly "verifyOwnership", "skipping for windows"
      resolveHead()
    else
      getCacheStat (er, cs) ->
        if er
          log.error "Could not get cache stat"
          return cb(er)
        chownr p, cs.uid, cs.gid, (er) ->
          if er
            log.error "Failed to change folder ownership under npm cache for %s", p
            return cb(er)
          resolveHead()
          return

        return

    return

  return
gitEnv = ->
  
  # git responds to env vars in some weird ways in post-receive hooks
  # so don't carry those along.
  return gitEnv_  if gitEnv_
  gitEnv_ = {}
  for k of process.env
    continue  if not ~[
      "GIT_PROXY_COMMAND"
      "GIT_SSH"
      "GIT_SSL_NO_VERIFY"
      "GIT_SSL_CAINFO"
    ].indexOf(k) and k.match(/^GIT/)
    gitEnv_[k] = process.env[k]
  gitEnv_

# similar to chmodr except it add permissions rather than overwriting them
# adapted from https://github.com/isaacs/chmodr/blob/master/chmodr.js
addModeRecursive = (p, mode, cb) ->
  fs.readdir p, (er, children) ->
    
    # Any error other than ENOTDIR means it's not readable, or doesn't exist.
    # Give up.
    then = (er) ->
      return `undefined`  if errState
      return cb(errState = er)  if er
      addMode p, dirMode(mode), cb  if --len is 0
    return cb(er)  if er and er.code isnt "ENOTDIR"
    return addMode(p, mode, cb)  if er or not children.length
    len = children.length
    errState = null
    children.forEach (child) ->
      addModeRecursive path.resolve(p, child), mode, then_
      return

    return

  return
addMode = (p, mode, cb) ->
  fs.stat p, (er, stats) ->
    return cb(er)  if er
    mode = stats.mode | mode
    fs.chmod p, mode, cb
    return

  return

# taken from https://github.com/isaacs/chmodr/blob/master/chmodr.js
dirMode = (mode) ->
  mode |= parseInt("0100", 8)  if mode & parseInt("0400", 8)
  mode |= parseInt("010", 8)  if mode & parseInt("040", 8)
  mode |= parseInt("01", 8)  if mode & parseInt("04", 8)
  mode
mkdir = require("mkdirp")
assert = require("assert")
git = require("../utils/git.js")
once = require("once")
fs = require("graceful-fs")
log = require("npmlog")
path = require("path")
url = require("url")
chownr = require("chownr")
zlib = require("zlib")
crypto = require("crypto")
npm = require("../npm.js")
rm = require("../utils/gently-rm.js")
inflight = require("inflight")
getCacheStat = require("./get-stat.js")
addLocalTarball = require("./add-local-tarball.js")
writeStream = require("fs-write-stream-atomic")
module.exports = addRemoteGit = (u, silent, cb) ->
  assert typeof u is "string", "must have git URL"
  assert typeof cb is "function", "must have callback"
  log.verbose "addRemoteGit", "u=%j silent=%j", u, silent
  parsed = url.parse(u, true)
  log.silly "addRemoteGit", "parsed", parsed
  origUrl = u
  u = u.replace(/^git\+/, "").replace(/#.*$/, "")
  u = u.replace(/^ssh:\/\//, "")  if parsed.pathname.match(/^\/?:/)
  cb = inflight(u, cb)
  return log.verbose("addRemoteGit", u, "already in flight; waiting")  unless cb
  log.verbose "addRemoteGit", u, "not in flight; cloning"
  co = parsed.hash and parsed.hash.substr(1) or "master"
  v = crypto.createHash("sha1").update(u).digest("hex").slice(0, 8)
  v = u.replace(/[^a-zA-Z0-9]+/g, "-") + "-" + v
  log.verbose "addRemoteGit", [
    u
    co
  ]
  p = path.join(npm.config.get("cache"), "_git-remotes", v)
  mkdir path.join(npm.config.get("cache"), "_git-remotes", "_templates"), (er) ->
    return cb(er)  if er
    checkGitDir p, u, co, origUrl, silent, (er, data) ->
      return cb(er, data)  if er
      addModeRecursive p, npm.modes.file, (er) ->
        cb er, data

      return

    return

  return

gitEnv_ = undefined
