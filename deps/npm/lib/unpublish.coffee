
# do a bit of filtering at this point, so that we don't need
# to fetch versions for more than one thing, but also don't
# accidentally a whole project.
unpublish = (args, cb) ->
  return cb(unpublish.usage)  if args.length > 1
  thing = (if args.length then npa(args[0]) else {})
  project = thing.name
  version = thing.rawSpec
  log.silly "unpublish", "args[0]", args[0]
  log.silly "unpublish", "thing", thing
  return cb("Refusing to delete entire project.\n" + "Run with --force to do this.\n" + unpublish.usage)  if not version and not npm.config.get("force")
  if not project or path.resolve(project) is npm.localPrefix
    
    # if there's a package.json in the current folder, then
    # read the package name and version out of that.
    cwdJson = path.join(npm.localPrefix, "package.json")
    return readJson(cwdJson, (er, data) ->
      return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
      return cb("Usage:\n" + unpublish.usage)  if er
      gotProject data.name, data.version, cb
      return
    )
  gotProject project, version, cb
gotProject = (project, version, cb_) ->
  cb = (er) ->
    return cb_(er)  if er
    console.log "- " + project + ((if version then "@" + version else ""))
    cb_()
    return
  
  # remove from the cache first
  npm.commands.cache [
    "clean"
    project
    version
  ], (er) ->
    if er
      log.error "unpublish", "Failed to clean cache"
      return cb(er)
    mapToRegistry project, npm.config, (er, uri) ->
      return cb(er)  if er
      registry.unpublish uri, version, cb
      return

    return

  return
module.exports = unpublish
log = require("npmlog")
npm = require("./npm.js")
registry = npm.registry
readJson = require("read-package-json")
path = require("path")
mapToRegistry = require("./utils/map-to-registry.js")
npa = require("npm-package-arg")
unpublish.usage = "npm unpublish <project>[@<version>]"
unpublish.completion = (opts, cb) ->
  return cb()  if opts.conf.argv.remain.length >= 3
  npm.commands.whoami [], true, (er, username) ->
    return cb()  if er
    un = encodeURIComponent(username)
    return cb()  unless un
    byUser = "-/by-user/" + un
    mapToRegistry byUser, npm.config, (er, uri) ->
      return cb(er)  if er
      registry.get uri, null, (er, pkgs) ->
        pkgs = pkgs[un]
        return cb()  if not pkgs or not pkgs.length
        pp = npa(opts.partialWord).name
        pkgs = pkgs.filter((p) ->
          p.indexOf(pp) is 0
        )
        return cb(null, pkgs)  if pkgs.length > 1
        mapToRegistry pkgs[0], npm.config, (er, uri) ->
          return cb(er)  if er
          registry.get uri, null, (er, d) ->
            return cb(er)  if er
            vers = Object.keys(d.versions)
            return cb(null, pkgs)  unless vers.length
            cb null, vers.map((v) ->
              pkgs[0] + "@" + v
            )

          return

        return

      return

    return

  return
