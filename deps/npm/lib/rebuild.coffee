rebuild = (args, cb) ->
  opt =
    depth: npm.config.get("depth")
    dev: true

  readInstalled npm.prefix, opt, (er, data) ->
    log.info "readInstalled", typeof data
    return cb(er)  if er
    set = filter(data, args)
    folders = Object.keys(set).filter((f) ->
      f isnt npm.prefix
    )
    return cb()  unless folders.length
    log.silly "rebuild set", folders
    cleanBuild folders, set, cb
    return

  return
cleanBuild = (folders, set, cb) ->
  npm.commands.build folders, (er) ->
    return cb(er)  if er
    console.log folders.map((f) ->
      set[f] + " " + f
    ).join("\n")
    cb()
    return

  return
filter = (data, args, set, seen) ->
  set = {}  unless set
  seen = {}  unless seen
  return set  if set.hasOwnProperty(data.path)
  return set  if seen.hasOwnProperty(data.path)
  seen[data.path] = true
  pass = undefined
  unless args.length # rebuild everything
    pass = true
  else if data.name and data._id
    i = 0
    l = args.length

    while i < l
      arg = args[i]
      nv = npa(arg)
      n = nv.name
      v = nv.rawSpec
      continue  if n isnt data.name
      continue  unless semver.satisfies(data.version, v, true)
      pass = true
      break
      i++
  if pass and data._id
    log.verbose "rebuild", "path, id", [
      data.path
      data._id
    ]
    set[data.path] = data._id
  
  # need to also dive through kids, always.
  # since this isn't an install these won't get auto-built unless
  # they're not dependencies.
  Object.keys(data.dependencies or {}).forEach (d) ->
    
    # return
    dep = data.dependencies[d]
    filter dep, args, set, seen  if typeof dep is "string"

  set
module.exports = rebuild
readInstalled = require("read-installed")
semver = require("semver")
log = require("npmlog")
npm = require("./npm.js")
npa = require("npm-package-arg")
rebuild.usage = "npm rebuild [<name>[@<version>] [name[@<version>] ...]]"
rebuild.completion = require("./utils/completion/installed-deep.js")
