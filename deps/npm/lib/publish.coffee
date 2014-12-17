
# publish can complete to a folder with a package.json
# or a tarball, or a tarball url.
# for now, not yet implemented.
publish = (args, isRetry, cb) ->
  if typeof cb isnt "function"
    cb = isRetry
    isRetry = false
  args = ["."]  if args.length is 0
  return cb(publish.usage)  if args.length isnt 1
  log.verbose "publish", args
  arg = args[0]
  
  # if it's a local folder, then run the prepublish there, first.
  readJson path.resolve(arg, "package.json"), (er, data) ->
    return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
    if data
      return cb(new Error("No name provided"))  unless data.name
      return cb(new Error("No version provided"))  unless data.version
    
    # Error is OK. Could be publishing a URL or tarball, however, that means
    # that we will not have automatically run the prepublish script, since
    # that gets run when adding a folder to the cache.
    if er
      cacheAddPublish arg, false, isRetry, cb
    else
      cacheAddPublish arg, true, isRetry, cb
    return

  return

# didPre in this case means that we already ran the prepublish script,
# and that the "dir" is an actual directory, and not something silly
# like a tarball or name@version thing.
# That means that we can run publish/postpublish in the dir, rather than
# in the cache dir.
cacheAddPublish = (dir, didPre, isRetry, cb) ->
  npm.commands.cache.add dir, null, null, false, (er, data) ->
    return cb(er)  if er
    log.silly "publish", data
    cachedir = path.resolve(cachedPackageRoot(data), "package")
    chain [
      not didPre and [
        lifecycle
        data
        "prepublish"
        cachedir
      ]
      [
        publish_
        dir
        data
        isRetry
        cachedir
      ]
      [
        lifecycle
        data
        "publish"
        (if didPre then dir else cachedir)
      ]
      [
        lifecycle
        data
        "postpublish"
        (if didPre then dir else cachedir)
      ]
    ], cb
    return

  return
publish_ = (arg, data, isRetry, cachedir, cb) ->
  return cb(new Error("no package.json file found"))  unless data
  registry = npm.registry
  config = npm.config
  
  # check for publishConfig hash
  if data.publishConfig
    config = new Conf(npm.config)
    config.save = npm.config.save.bind(npm.config)
    
    # don't modify the actual publishConfig object, in case we have
    # to set a login token or some other data.
    config.unshift Object.keys(data.publishConfig).reduce((s, k) ->
      s[k] = data.publishConfig[k]
      s
    , {})
    registry = new RegClient(config)
  data._npmVersion = npm.version
  data._nodeVersion = process.versions.node
  delete data.modules

  return cb(new Error("This package has been marked as private\n" + "Remove the 'private' field from the package.json to publish it."))  if data.private
  mapToRegistry data.name, config, (er, registryURI) ->
    return cb(er)  if er
    tarball = cachedir + ".tgz"
    
    # we just want the base registry URL in this case
    registryBase = url.resolve(registryURI, ".")
    log.verbose "publish", "registryBase", registryBase
    c = config.getCredentialsByURI(registryBase)
    data._npmUser =
      name: c.username
      email: c.email

    registry.publish registryBase, data, tarball, (er) ->
      if er and er.code is "EPUBLISHCONFLICT" and npm.config.get("force") and not isRetry
        log.warn "publish", "Forced publish over " + data._id
        return npm.commands.unpublish([data._id], (er) ->
          
          # ignore errors.  Use the force.  Reach out with your feelings.
          # but if it fails again, then report the first error.
          publish [arg], er or true, cb
          return
        )
      
      # report the unpublish error if this was a retry and unpublish failed
      return cb(isRetry)  if er and isRetry and isRetry isnt true
      return cb(er)  if er
      console.log "+ " + data._id
      cb()
      return

    return

  return
module.exports = publish
url = require("url")
npm = require("./npm.js")
log = require("npmlog")
path = require("path")
readJson = require("read-package-json")
lifecycle = require("./utils/lifecycle.js")
chain = require("slide").chain
Conf = require("./config/core.js").Conf
RegClient = require("npm-registry-client")
mapToRegistry = require("./utils/map-to-registry.js")
cachedPackageRoot = require("./cache/cached-package-root.js")
publish.usage = "npm publish <tarball>" + "\nnpm publish <folder>" + "\n\nPublishes '.' if no argument supplied"
publish.completion = (opts, cb) ->
  cb()
