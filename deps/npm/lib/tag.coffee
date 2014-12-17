# turns out tagging isn't very complicated
# all the smarts are in the couch.
tag = (args, cb) ->
  thing = npa(args.shift() or "")
  project = thing.name
  version = thing.rawSpec
  t = args.shift() or npm.config.get("tag")
  t = t.trim()
  return cb("Usage:\n" + tag.usage)  if not project or not version or not t
  if semver.validRange(t)
    er = new Error("Tag name must not be a valid SemVer range: " + t)
    return cb(er)
  mapToRegistry project, npm.config, (er, uri) ->
    return cb(er)  if er
    registry.tag uri, version, t, cb
    return

  return
module.exports = tag
tag.usage = "npm tag <project>@<version> [<tag>]"
tag.completion = require("./unpublish.js").completion
npm = require("./npm.js")
registry = npm.registry
mapToRegistry = require("./utils/map-to-registry.js")
npa = require("npm-package-arg")
semver = require("semver")
