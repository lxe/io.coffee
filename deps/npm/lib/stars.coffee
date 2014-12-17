stars = (args, cb) ->
  showstars = (er, data) ->
    return cb(er)  if er
    if data.rows.length is 0
      log.warn "stars", "user has not starred any packages."
    else
      data.rows.forEach (a) ->
        console.log a.value
        return

    cb()
    return
  npm.commands.whoami [], true, (er, username) ->
    name = (if args.length is 1 then args[0] else username)
    mapToRegistry "", npm.config, (er, uri) ->
      return cb(er)  if er
      registry.stars uri, name, showstars
      return

    return

  return
module.exports = stars
stars.usage = "npm stars [username]"
npm = require("./npm.js")
registry = npm.registry
log = require("npmlog")
mapToRegistry = require("./utils/map-to-registry.js")
