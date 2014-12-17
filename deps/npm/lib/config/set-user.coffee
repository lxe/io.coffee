setUser = (cb) ->
  defaultConf = @root
  assert defaultConf isnt Object::
  
  # If global, leave it as-is.
  # If not global, then set the user to the owner of the prefix folder.
  # Just set the default, so it can be overridden.
  return cb()  if @get("global")
  if process.env.SUDO_UID
    defaultConf.user = +(process.env.SUDO_UID)
    return cb()
  prefix = path.resolve(@get("prefix"))
  mkdirp prefix, (er) ->
    return cb(er)  if er
    fs.stat prefix, (er, st) ->
      defaultConf.user = st and st.uid
      cb er

    return

  return
module.exports = setUser
assert = require("assert")
path = require("path")
fs = require("fs")
mkdirp = require("mkdirp")
