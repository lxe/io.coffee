#
#for each pkg in prefix that isn't a git repo
#  look for a new version of pkg that satisfies dep
#  if so, install it.
#  if not, then update it
#

# load these, just so that we know that they'll be available, in case
# npm itself is getting overwritten.
update = (args, cb) ->
  npm.commands.outdated args, true, (er, outdated) ->
    log.info "outdated", "updating", outdated
    return cb(er)  if er
    asyncMap outdated, ((ww, cb) ->
      
      # [[ dir, dep, has, want, req ]]
      where = ww[0]
      dep = ww[1]
      want = ww[3]
      what = dep + "@" + want
      req = ww[5]
      url = require("url")
      
      # use the initial installation method (repo, tar, git) for updating
      what = req  if url.parse(req).protocol
      npm.commands.install where, what, cb
      return
    ), cb
    return

  return
module.exports = update
update.usage = "npm update [pkg]"
npm = require("./npm.js")
asyncMap = require("slide").asyncMap
log = require("npmlog")
install = require("./install.js")
build = require("./build.js")
update.completion = npm.commands.outdated.completion
