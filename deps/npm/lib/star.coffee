star = (args, cb) ->
  return cb(star.usage)  unless args.length
  s = (if npm.config.get("unicode") then "★ " else "(*)")
  u = (if npm.config.get("unicode") then "☆ " else "( )")
  using = not (npm.command.match(/^un/))
  s = u  unless using
  asyncMap args, ((pkg, cb) ->
    mapToRegistry pkg, npm.config, (er, uri) ->
      return cb(er)  if er
      registry.star uri, using, (er, data, raw, req) ->
        unless er
          console.log s + " " + pkg
          log.verbose "star", data
        cb er, data, raw, req
        return

      return

    return
  ), cb
  return
module.exports = star
npm = require("./npm.js")
registry = npm.registry
log = require("npmlog")
asyncMap = require("slide").asyncMap
mapToRegistry = require("./utils/map-to-registry.js")
star.usage = "npm star <package> [pkg, pkg, ...]\n" + "npm unstar <package> [pkg, pkg, ...]"
star.completion = (opts, cb) ->
  mapToRegistry "-/short", npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri,
      timeout: 60000
    , (er, list) ->
      cb null, list or []

    return

  return
