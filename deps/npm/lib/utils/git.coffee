
# handle some git configuration for windows
prefixGitArgs = ->
  (if process.platform is "win32" then [
    "-c"
    "core.longpaths=true"
  ] else [])
execGit = (args, options, cb) ->
  log.info "git", args
  exec git, prefixGitArgs().concat(args or []), options, cb
spawnGit = (args, options, cb) ->
  log.info "git", args
  spawn git, prefixGitArgs().concat(args or []), options
chainableExec = ->
  args = Array::slice.call(arguments)
  [execGit].concat args
whichGit = (cb) ->
  which git, cb
whichAndExec = (args, options, cb) ->
  assert.equal typeof cb, "function", "no callback provided"
  
  # check for git
  whichGit (err) ->
    if err
      err.code = "ENOGIT"
      return cb(err)
    execGit args, options, cb
    return

  return
exports.spawn = spawnGit
exports.chainableExec = chainableExec
exports.whichAndExec = whichAndExec
exec = require("child_process").execFile
spawn = require("child_process").spawn
npm = require("../npm.js")
which = require("which")
git = npm.config.get("git")
assert = require("assert")
log = require("npmlog")
