
# see if there's already a package specified.

# either specified a script locally, in which case, done,
# or a package, in which case, complete against its scripts

# ok, try to find out which package it was, then

# complete against the installed-shallow, and the pwd's scripts.
# but only packages that have scripts
runScript = (args, cb) ->
  return list(cb)  unless args.length
  pkgdir = npm.localPrefix
  cmd = args.shift()
  readJson path.resolve(pkgdir, "package.json"), (er, d) ->
    return cb(er)  if er
    run d, pkgdir, cmd, args, cb
    return

  return
list = (cb) ->
  json = path.join(npm.localPrefix, "package.json")
  readJson json, (er, d) ->
    return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
    d = {}  if er
    scripts = Object.keys(d.scripts or {})
    return cb(null, scripts)  if log.level is "silent"
    if npm.config.get("json")
      console.log JSON.stringify(d.scripts or {}, null, 2)
      return cb(null, scripts)
    s = ":"
    prefix = ""
    unless npm.config.get("parseable")
      s = "\n    "
      prefix = "  "
      console.log "Available scripts in the %s package:", d.name
    scripts.forEach (script) ->
      console.log prefix + script + s + d.scripts[script]
      return

    cb null, scripts

run = (pkg, wd, cmd, args, cb) ->
  pkg.scripts = {}  unless pkg.scripts
  cmds = undefined
  if cmd is "restart"
    cmds = [
      "prestop"
      "stop"
      "poststop"
      "restart"
      "prestart"
      "start"
      "poststart"
    ]
  else
    cmds = [cmd]
  cmds = ["pre" + cmd].concat(cmds).concat("post" + cmd)  unless cmd.match(/^(pre|post)/)
  log.verbose "run-script", cmds
  chain cmds.map((c) ->
    
    # pass cli arguments after -- to script.
    pkg.scripts[c] = pkg.scripts[c] + joinArgs(args)  if pkg.scripts[c] and c is cmd
    
    # when running scripts explicitly, assume that they're trusted.
    [
      lifecycle
      pkg
      c
      wd
      true
    ]
  ), cb
  return

# join arguments after '--' and pass them to script,
# handle special characters such as ', ", ' '.
joinArgs = (args) ->
  joinedArgs = ""
  args.forEach (arg) ->
    arg = "\"" + arg.replace(/"/g, "\\\"") + "\""  if arg.match(/[ '"]/)
    joinedArgs += " " + arg
    return

  joinedArgs
module.exports = runScript
lifecycle = require("./utils/lifecycle.js")
npm = require("./npm.js")
path = require("path")
readJson = require("read-package-json")
log = require("npmlog")
chain = require("slide").chain
runScript.usage = "npm run-script <command> [-- <args>]"
runScript.completion = (opts, cb) ->
  next = ->
    cb null, scripts.concat(installed)  if not installed or not scripts
  argv = opts.conf.argv.remain
  installedShallow = require("./utils/completion/installed-shallow.js")
  return cb()  if argv.length >= 4
  if argv.length is 3
    json = path.join(npm.localPrefix, "package.json")
    return readJson(json, (er, d) ->
      return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
      d = {}  if er
      scripts = Object.keys(d.scripts or {})
      console.error "local scripts", scripts
      return cb()  if scripts.indexOf(argv[2]) isnt -1
      pref = (if npm.config.get("global") then npm.config.get("prefix") else npm.localPrefix)
      pkgDir = path.resolve(pref, "node_modules", argv[2], "package.json")
      readJson pkgDir, (er, d) ->
        return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
        d = {}  if er
        scripts = Object.keys(d.scripts or {})
        cb null, scripts

      return
    )
  installed = undefined
  scripts = undefined
  installedShallow opts, ((d) ->
    d.scripts
  ), (er, inst) ->
    installed = inst
    next()
    return

  if npm.config.get("global")
    scripts = []
    next()
  else
    readJson path.join(npm.localPrefix, "package.json"), (er, d) ->
      return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
      d = d or {}
      scripts = Object.keys(d.scripts or {})
      next()
      return

  return
