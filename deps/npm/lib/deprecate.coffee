
# first, get a list of remote packages this user owns.
# once we have a user account, then don't complete anything.

# get the list of packages by user
deprecate = (args, cb) ->
  
  # fetch the data and make sure it exists.
  next = (er, uri) ->
    return cb(er)  if er
    npm.registry.deprecate uri, p.spec, msg, cb
    return
  pkg = args[0]
  msg = args[1]
  return cb("Usage: " + deprecate.usage)  if msg is `undefined`
  p = npa(pkg)
  mapToRegistry p.name, npm.config, next
  return
npm = require("./npm.js")
mapToRegistry = require("./utils/map-to-registry.js")
npa = require("npm-package-arg")
module.exports = deprecate
deprecate.usage = "npm deprecate <pkg>[@<version>] <message>"
deprecate.completion = (opts, cb) ->
  return cb()  if opts.conf.argv.remain.length > 2
  path = "/-/by-user/"
  mapToRegistry path, npm.config, (er, uri) ->
    return cb(er)  if er
    c = npm.config.getCredentialsByURI(uri)
    return cb()  unless c and c.username
    npm.registry.get uri + c.username,
      timeout: 60000
    , (er, list) ->
      return cb()  if er
      console.error list
      cb null, list[c.username]

    return

  return
