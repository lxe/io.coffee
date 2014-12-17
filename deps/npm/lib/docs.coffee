url = (json) ->
  (if json.homepage then json.homepage else "https://npmjs.org/package/" + json.name)
docs = (args, cb) ->
  args = args or []
  pending = args.length
  return getDoc(".", cb)  unless pending
  args.forEach (proj) ->
    getDoc proj, (err) ->
      return cb(err)  if err
      --pending or cb()
      return

    return

  return
getDoc = (project, cb) ->
  next = (er, json) ->
    github = "https://github.com/" + project + "#readme"
    if er
      return cb(er)  if project.split("/").length isnt 2
      return opener(github,
        command: npm.config.get("browser")
      , cb)
    opener url(json),
      command: npm.config.get("browser")
    , cb
  project = project or "."
  package_ = path.resolve(npm.localPrefix, "package.json")
  if project is "." or project is "./"
    json = undefined
    try
      json = require(package_)
      throw new Error("package.json does not have a valid \"name\" property")  unless json.name
      project = json.name
    catch e
      log.error e.message
      return cb(docs.usage)
    return opener(url(json),
      command: npm.config.get("browser")
    , cb)
  mapToRegistry project, npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri + "/latest",
      timeout: 3600
    , next
    return

  return
module.exports = docs
docs.usage = "npm docs <pkgname>"
docs.usage += "\n"
docs.usage += "npm docs ."
docs.completion = (opts, cb) ->
  mapToRegistry "/-/short", npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri,
      timeout: 60000
    , (er, list) ->
      cb null, list or []

    return

  return

npm = require("./npm.js")
registry = npm.registry
opener = require("opener")
path = require("path")
log = require("npmlog")
mapToRegistry = require("./utils/map-to-registry.js")
