whoami = (args, silent, cb) ->
  
  # FIXME: need tighter checking on this, but is a breaking change
  if typeof cb isnt "function"
    cb = silent
    silent = false
  registry = npm.config.get("registry")
  return cb(new Error("no default registry set"))  unless registry
  credentials = npm.config.getCredentialsByURI(registry)
  if credentials
    if credentials.username
      console.log credentials.username  unless silent
      return process.nextTick(cb.bind(this, null, credentials.username))
    else if credentials.token
      return npm.registry.whoami(registry, (er, username) ->
        return cb(er)  if er
        console.log username  unless silent
        cb null, username
        return
      )
  
  # At this point, if they have a credentials object, it doesn't
  # have a token or auth in it.  Probably just the default
  # registry.
  msg = "Not authed.  Run 'npm adduser'"
  console.log msg  unless silent
  process.nextTick cb.bind(this, null, msg)
  return
npm = require("./npm.js")
module.exports = whoami
whoami.usage = "npm whoami\n(just prints username according to given registry)"
