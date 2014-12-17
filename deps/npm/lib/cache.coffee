# XXX lib/utils/tar.js and this file need to be rewritten.

# URL-to-cache folder mapping:
# : -> !
# @ -> _
# http://registry.npmjs.org/foo/version -> cache/http!/...
#

#
#fetching a URL:
#1. Check for URL in inflight URLs.  If present, add cb, and return.
#2. Acquire lock at {cache}/{sha(url)}.lock
#   retries = {cache-lock-retries, def=3}
#   stale = {cache-lock-stale, def=30000}
#   wait = {cache-lock-wait, def=100}
#3. if lock can't be acquired, then fail
#4. fetch url, clear lock, call cbs
#
#cache folders:
#1. urls: http!/server.com/path/to/thing
#2. c:\path\to\thing: file!/c!/path/to/thing
#3. /path/to/thing: file!/path/to/thing
#4. git@ private: git_github.com!npm/npm
#5. git://public: git!/github.com/npm/npm
#6. git+blah:// git-blah!/server.com/foo/bar
#
#adding a folder:
#1. tar into tmp/random/package.tgz
#2. untar into tmp/random/contents/package, stripping one dir piece
#3. tar tmp/random/contents/package to cache/n/v/package.tgz
#4. untar cache/n/v/package.tgz into cache/n/v/package
#5. rm tmp/random
#
#Adding a url:
#1. fetch to tmp/random/package.tgz
#2. goto folder(2)
#
#adding a name@version:
#1. registry.get(name/version)
#2. if response isn't 304, add url(dist.tarball)
#
#adding a name@range:
#1. registry.get(name)
#2. Find a version that satisfies
#3. add name@version
#
#adding a local tarball:
#1. untar to tmp/random/{blah}
#2. goto folder(2)
#
#adding a namespaced package:
#1. lookup registry for @namespace
#2. namespace_registry.get('name')
#3. add url(namespace/latest.tarball)
#

# cache and ls are easy, because the completion is
# what ls_ returns anyway.
# just get the partial words, minus the last path part

# Same semantics as install and publish.
cache = (args, cb) ->
  cmd = args.shift()
  switch cmd
    when "rm", "clear", "clean"
      clean args, cb
    when "list", "sl", "ls"
      ls args, cb
    when "add"
      add args, npm.prefix, cb
    else
      cb "Usage: " + cache.usage

# if the pkg and ver are in the cache, then
# just do a readJson and return.
# if they're not, then fetch them from the registry.
read = (name, ver, forceBypass, cb) ->
  c = (er, data) ->
    log.silly "cache", "addNamed cb", name + "@" + ver
    log.verbose "cache", "addNamed error for", name + "@" + ver, er  if er
    deprCheck data  if data
    cb er, data
  assert typeof name is "string", "must include name of module to install"
  assert typeof cb is "function", "must include callback"
  forceBypass = true  if forceBypass is `undefined` or forceBypass is null
  root = cachedPackageRoot(
    name: name
    version: ver
  )
  if forceBypass and npm.config.get("force")
    log.verbose "using force", "skipping cache"
    return addNamed(name, ver, null, c)
  readJson path.join(root, "package", "package.json"), (er, data) ->
    return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
    if data
      return cb(new Error("No name provided"))  unless data.name
      return cb(new Error("No version provided"))  unless data.version
    if er
      addNamed name, ver, null, c
    else
      c er, data
    return

  return
normalize = (args) ->
  normalized = ""
  if args.length > 0
    a = npa(args[0])
    normalized = a.name  if a.name
    if a.rawSpec
      normalized = [
        normalized
        a.rawSpec
      ].join("/")
    normalized = [normalized].concat(args.slice(1)).join("/")  if args.length > 1
  normalized = normalized.substr(0, normalized.length - 1)  if normalized.substr(-1) is "/"
  log.silly "ls", "normalized", normalized
  normalized

# npm cache ls [<path>]
ls = (args, cb) ->
  prefix = npm.config.get("cache")
  prefix = "~" + prefix.substr(process.env.HOME.length)  if prefix.indexOf(process.env.HOME) is 0
  ls_ normalize(args), npm.config.get("depth"), (er, files) ->
    console.log files.map((f) ->
      path.join prefix, f
    ).join("\n").trim()
    cb er, files
    return

  return

# Calls cb with list of cached pkgs matching show.
ls_ = (req, depth, cb) ->
  fileCompletion npm.cache, req, depth, cb

# npm cache clean [<path>]
clean = (args, cb) ->
  assert typeof cb is "function", "must include callback"
  args = []  unless args
  f = path.join(npm.cache, path.normalize(normalize(args)))
  if f is npm.cache
    fs.readdir npm.cache, (er, files) ->
      return cb()  if er
      asyncMap files.filter((f) ->
        npm.config.get("force") or f isnt "-"
      ).map((f) ->
        path.join npm.cache, f
      ), rm, cb
      return

  else
    rm path.join(npm.cache, path.normalize(normalize(args))), cb
  return

# npm cache add <tarball-url>
# npm cache add <pkg> <ver>
# npm cache add <tarball>
# npm cache add <folder>
add = (args, where, cb) ->
  
  # this is hot code.  almost everything passes through here.
  # the args can be any of:
  # ["url"]
  # ["pkg", "version"]
  # ["pkg@version"]
  # ["pkg", "url"]
  # This is tricky, because urls can contain @
  # Also, in some cases we get [name, null] rather
  # that just a single argument.
  usage = "Usage:\n" + "    npm cache add <tarball-url>\n" + "    npm cache add <pkg>@<ver>\n" + "    npm cache add <tarball>\n" + "    npm cache add <folder>\n"
  spec = undefined
  log.silly "cache add", "args", args
  args[1] = null  if args[1] is `undefined`
  
  # at this point the args length must ==2
  if args[1] isnt null
    spec = args[0] + "@" + args[1]
  else spec = args[0]  if args.length is 2
  log.verbose "cache add", "spec", spec
  return cb(usage)  unless spec
  npm.spinner.start()  if adding <= 0
  adding++
  cb = afterAdd(cb)
  realizePackageSpecifier spec, where, (err, p) ->
    return cb(err)  if err
    log.silly "cache add", "parsed spec", p
    switch p.type
      when "local", "directory"
        addLocal p, null, cb
      when "remote"
        addRemoteTarball p.spec,
          name: p.name
        , null, cb
      when "git"
        addRemoteGit p.spec, false, cb
      when "github"
        maybeGithub p.spec, cb
      else
        return addNamed(p.name, p.spec, null, cb)  if p.name
        cb new Error("couldn't figure out how to install " + spec)
    return

  return
unpack = (pkg, ver, unpackTarget, dMode, fMode, uid, gid, cb) ->
  if typeof cb isnt "function"
    cb = gid
    gid = null
  if typeof cb isnt "function"
    cb = uid
    uid = null
  if typeof cb isnt "function"
    cb = fMode
    fMode = null
  if typeof cb isnt "function"
    cb = dMode
    dMode = null
  read pkg, ver, false, (er) ->
    if er
      log.error "unpack", "Could not read data for %s", pkg + "@" + ver
      return cb(er)
    npm.commands.unbuild [unpackTarget], true, (er) ->
      return cb(er)  if er
      tar.unpack path.join(cachedPackageRoot(
        name: pkg
        version: ver
      ), "package.tgz"), unpackTarget, dMode, fMode, uid, gid, cb
      return

    return

  return
afterAdd = (cb) ->
  (er, data) ->
    adding--
    npm.spinner.stop()  if adding <= 0
    return cb(er, data)  if er or not data or not data.name or not data.version
    log.silly "cache", "afterAdd", data.name + "@" + data.version
    
    # Save the resolved, shasum, etc. into the data so that the next
    # time we load from this cached data, we have all the same info.
    pj = path.join(cachedPackageRoot(data), "package", "package.json")
    done = inflight(pj, cb)
    return log.verbose("afterAdd", pj, "already in flight; not writing")  unless done
    log.verbose "afterAdd", pj, "not in flight; writing"
    getStat (er, cs) ->
      return done(er)  if er
      writeFileAtomic pj, JSON.stringify(data),
        chown: cs
      , (er) ->
        log.verbose "afterAdd", pj, "written"  unless er
        done er, data

      return

    return
exports = module.exports = cache
cache.unpack = unpack
cache.clean = clean
cache.read = read
npm = require("./npm.js")
fs = require("graceful-fs")
writeFileAtomic = require("write-file-atomic")
assert = require("assert")
rm = require("./utils/gently-rm.js")
readJson = require("read-package-json")
log = require("npmlog")
path = require("path")
asyncMap = require("slide").asyncMap
tar = require("./utils/tar.js")
fileCompletion = require("./utils/completion/file-completion.js")
deprCheck = require("./utils/depr-check.js")
addNamed = require("./cache/add-named.js")
addLocal = require("./cache/add-local.js")
addRemoteTarball = require("./cache/add-remote-tarball.js")
addRemoteGit = require("./cache/add-remote-git.js")
maybeGithub = require("./cache/maybe-github.js")
inflight = require("inflight")
realizePackageSpecifier = require("realize-package-specifier")
npa = require("npm-package-arg")
getStat = require("./cache/get-stat.js")
cachedPackageRoot = require("./cache/cached-package-root.js")
cache.usage = "npm cache add <tarball file>" + "\nnpm cache add <folder>" + "\nnpm cache add <tarball url>" + "\nnpm cache add <git url>" + "\nnpm cache add <name>@<version>" + "\nnpm cache ls [<path>]" + "\nnpm cache clean [<pkg>[@<version>]]"
cache.completion = (opts, cb) ->
  argv = opts.conf.argv.remain
  if argv.length is 2
    return cb(null, [
      "add"
      "ls"
      "clean"
    ])
  switch argv[2]
    when "clean", "ls"
      p = path.dirname(opts.partialWords.slice(3).join("/"))
      p = ""  if p is "."
      ls_ p, 2, cb
    when "add"
      npm.commands.install.completion opts, cb

cache.add = (pkg, ver, where, scrub, cb) ->
  assert typeof pkg is "string", "must include name of package to install"
  assert typeof cb is "function", "must include callback"
  if scrub
    return clean([], (er) ->
      return cb(er)  if er
      add [
        pkg
        ver
      ], where, cb
      return
    )
  add [
    pkg
    ver
  ], where, cb

adding = 0
