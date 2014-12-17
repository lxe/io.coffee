# link with no args: symlink the folder to the global location
# link with package arg: symlink the global to the local
link = (args, cb) ->
  if process.platform is "win32"
    semver = require("semver")
    unless semver.satisfies(process.version, ">=0.7.9")
      msg = "npm link not supported on windows prior to node 0.7.9"
      e = new Error(msg)
      e.code = "ENOTSUP"
      e.errno = require("constants").ENOTSUP
      return cb(e)
  return cb(new Error("link should never be --global.\n" + "Please re-run this command with --local"))  if npm.config.get("global")
  args = []  if args.length is 1 and args[0] is "."
  return linkInstall(args, cb)  if args.length
  linkPkg npm.prefix, cb
  return
linkInstall = (pkgs, cb) ->
  asyncMap pkgs, ((pkg, cb) ->
    n = (er, data) ->
      return cb(er, data)  if er
      
      # install returns [ [folder, pkgId], ... ]
      # but we definitely installed just one thing.
      d = data.filter((d) ->
        not d[3]
      )
      what = npa(d[0][0])
      pp = d[0][1]
      pkg = what.name
      target = path.resolve(npm.dir, pkg)
      next()
      return
    
    # if it's a folder, a random not-installed thing, or not a scoped package,
    # then link or install it first
    next = ->
      chain [
        [
          npm.commands
          "unbuild"
          [target]
        ]
        [(cb) ->
          log.verbose "link", "symlinking %s to %s", pp, target
          cb()
          return
        ]
        [
          symlink
          pp
          target
        ]
        
        # do run lifecycle scripts - full build here.
        rp and [
          build
          [target]
        ]
        [
          resultPrinter
          pkg
          pp
          target
          rp
        ]
      ], cb
      return
    t = path.resolve(npm.globalDir, "..")
    pp = path.resolve(npm.globalDir, pkg)
    rp = null
    target = path.resolve(npm.dir, pkg)
    if pkg[0] isnt "@" and (pkg.indexOf("/") isnt -1 or pkg.indexOf("\\") isnt -1)
      return fs.lstat(path.resolve(pkg), (er, st) ->
        if er or not st.isDirectory()
          npm.commands.install t, pkg, n
        else
          rp = path.resolve(pkg)
          linkPkg rp, n
        return
      )
    fs.lstat pp, (er, st) ->
      if er
        rp = pp
        npm.commands.install t, pkg, n
      else unless st.isSymbolicLink()
        rp = pp
        next()
      else
        fs.realpath pp, (er, real) ->
          if er
            log.warn "invalid symbolic link", pkg
          else
            rp = real
          next()
          return

      return

    return
  ), cb
  return
linkPkg = (folder, cb_) ->
  me = folder or npm.prefix
  readJson = require("read-package-json")
  log.verbose "linkPkg", folder
  readJson path.resolve(me, "package.json"), (er, d) ->
    cb = (er) ->
      cb_ er, [[
        d and d._id
        target
        null
        null
      ]]
    return cb(er)  if er
    unless d.name
      er = new Error("Package must have a name field to be linked")
      return cb(er)
    target = path.resolve(npm.globalDir, d.name)
    rm target, (er) ->
      return cb(er)  if er
      symlink me, target, (er) ->
        return cb(er)  if er
        log.verbose "link", "build target", target
        
        # also install missing dependencies.
        npm.commands.install me, [], (er) ->
          return cb(er)  if er
          
          # build the global stuff.  Don't run *any* scripts, because
          # install command already will have done that.
          build [target], true, build._noLC, true, (er) ->
            return cb(er)  if er
            resultPrinter path.basename(me), me, target, cb
            return

          return

        return

      return

    return

  return
resultPrinter = (pkg, src, dest, rp, cb) ->
  if typeof cb isnt "function"
    cb = rp
    rp = null
  where = dest
  rp = (rp or "").trim()
  src = (src or "").trim()
  
  # XXX If --json is set, then look up the data from the package.json
  return parseableOutput(dest, rp or src, cb)  if npm.config.get("parseable")
  rp = null  if rp is src
  console.log where + " -> " + src + ((if rp then " -> " + rp else ""))
  cb()
  return
parseableOutput = (dest, rp, cb) ->
  
  # XXX this should match ls --parseable and install --parseable
  # look up the data from package.json, format it the same way.
  #
  # link is always effectively "long", since it doesn't help much to
  # *just* print the target folder.
  # However, we don't actually ever read the version number, so
  # the second field is always blank.
  console.log dest + "::" + rp
  cb()
  return
npm = require("./npm.js")
symlink = require("./utils/link.js")
fs = require("graceful-fs")
log = require("npmlog")
asyncMap = require("slide").asyncMap
chain = require("slide").chain
path = require("path")
rm = require("./utils/gently-rm.js")
build = require("./build.js")
npa = require("npm-package-arg")
module.exports = link
link.usage = "npm link (in package dir)" + "\nnpm link <pkg> (link global into local)"
link.completion = (opts, cb) ->
  dir = npm.globalDir
  fs.readdir dir, (er, files) ->
    cb er, files.filter((f) ->
      not f.match(/^[\._-]/)
    )
    return

  return
