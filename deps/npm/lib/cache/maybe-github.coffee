assert = require("assert")
log = require("npmlog")
addRemoteGit = require("./add-remote-git.js")
module.exports = maybeGithub = (p, cb) ->
  success = (u, data) ->
    data._from = u
    data._fromGithub = true
    cb null, data
  assert typeof p is "string", "must pass package name"
  assert typeof cb is "function", "must pass callback"
  u = "git://github.com/" + p
  log.info "maybeGithub", "Attempting %s from %s", p, u
  return addRemoteGit(u, true, (er, data) ->
    if er
      upriv = "git+ssh://git@github.com:" + p
      log.info "maybeGithub", "Attempting %s from %s", p, upriv
      return addRemoteGit(upriv, false, (er, data) ->
        return cb(er)  if er
        success upriv, data
        return
      )
    success u, data
    return
  )
  return
