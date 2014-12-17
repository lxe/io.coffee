# prune extraneous packages.
prune = (args, cb) ->
  
  #check if is a valid package.json file
  next = ->
    opt =
      depth: npm.config.get("depth")
      dev: not npm.config.get("production") or npm.config.get("dev")

    readInstalled npm.prefix, opt, (er, data) ->
      return cb(er)  if er
      prune_ args, data, cb
      return

    return
  jsonFile = path.resolve(npm.dir, "..", "package.json")
  readJson jsonFile, log.warn, (er) ->
    return cb(er)  if er
    next()
    return

  return
prune_ = (args, data, cb) ->
  npm.commands.unbuild prunables(args, data, []), cb
  return
prunables = (args, data, seen) ->
  deps = data.dependencies or {}
  Object.keys(deps).map((d) ->
    return null  if typeof deps[d] isnt "object" or seen.indexOf(deps[d]) isnt -1
    seen.push deps[d]
    if deps[d].extraneous and (args.length is 0 or args.indexOf(d) isnt -1)
      extra = deps[d]
      delete deps[d]

      return extra.path
    prunables args, deps[d], seen
  ).filter((d) ->
    d isnt null
  ).reduce (FLAT = (l, r) ->
    l.concat (if Array.isArray(r) then r.reduce(FLAT, []) else r)
  ), []
module.exports = prune
prune.usage = "npm prune"
readInstalled = require("read-installed")
npm = require("./npm.js")
path = require("path")
readJson = require("read-package-json")
log = require("npmlog")
prune.completion = require("./utils/completion/installed-deep.js")
