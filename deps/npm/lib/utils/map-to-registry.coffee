mapToRegistry = (name, config, cb) ->
  uri = undefined
  scopedRegistry = undefined
  
  # the name itself takes precedence
  data = npa(name)
  if data.scope
    
    # the name is definitely scoped, so escape now
    name = name.replace("/", "%2f")
    log.silly "mapToRegistry", "scope", data.scope
    scopedRegistry = config.get(data.scope + ":registry")
    if scopedRegistry
      log.silly "mapToRegistry", "scopedRegistry (scoped package)", scopedRegistry
      uri = url.resolve(scopedRegistry, name)
    else
      log.verbose "mapToRegistry", "no registry URL found for scope", data.scope
  
  # ...then --scope=@scope or --scope=scope
  scope = config.get("scope")
  if not uri and scope
    
    # I'm an enabler, sorry
    scope = "@" + scope  if scope.charAt(0) isnt "@"
    scopedRegistry = config.get(scope + ":registry")
    if scopedRegistry
      log.silly "mapToRegistry", "scopedRegistry (scope in config)", scopedRegistry
      uri = url.resolve(scopedRegistry, name)
    else
      log.verbose "mapToRegistry", "no registry URL found for scope", scope
  
  # ...and finally use the default registry
  uri = url.resolve(config.get("registry"), name)  unless uri
  log.verbose "mapToRegistry", "name", name
  log.verbose "mapToRegistry", "uri", uri
  cb null, uri
  return
url = require("url")
log = require("npmlog")
npa = require("npm-package-arg")
module.exports = mapToRegistry
