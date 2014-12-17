addRemoteTarball = (u, pkgData, shasum, cb_) ->
  cb = (er, data) ->
    if data
      data._from = u
      data._shasum = data._shasum or shasum
      data._resolved = u
    cb_ er, data
    return
  
  # XXX Fetch direct to cache location, store tarballs under
  # ${cache}/registry.npmjs.org/pkg/-/pkg-1.2.3.tgz
  next = (er, resp, shasum) ->
    return cb(er)  if er
    addLocalTarball tmp, pkgData, shasum, cb
    return
  assert typeof u is "string", "must have module URL"
  assert typeof cb_ is "function", "must have callback"
  cb_ = inflight(u, cb_)
  return log.verbose("addRemoteTarball", u, "already in flight; waiting")  unless cb_
  log.verbose "addRemoteTarball", u, "not in flight; adding"
  tmp = cacheFile(npm.tmp, u)
  log.verbose "addRemoteTarball", [
    u
    shasum
  ]
  mkdir path.dirname(tmp), (er) ->
    return cb(er)  if er
    addRemoteTarball_ u, tmp, shasum, next
    return

  return
addRemoteTarball_ = (u, tmp, shasum, cb) ->
  
  # Tuned to spread 3 attempts over about a minute.
  # See formula at <https://github.com/tim-kos/node-retry>.
  operation = retry.operation(
    retries: npm.config.get("fetch-retries")
    factor: npm.config.get("fetch-retry-factor")
    minTimeout: npm.config.get("fetch-retry-mintimeout")
    maxTimeout: npm.config.get("fetch-retry-maxtimeout")
  )
  operation.attempt (currentAttempt) ->
    log.info "retry", "fetch attempt " + currentAttempt + " at " + (new Date()).toLocaleTimeString()
    fetchAndShaCheck u, tmp, shasum, (er, response, shasum) ->
      
      # Only retry on 408, 5xx or no `response`.
      sc = response and response.statusCode
      statusRetry = not sc or (sc is 408 or sc >= 500)
      if er and statusRetry and operation.retry(er)
        log.info "retry", "will retry, error on last attempt: " + er
        return
      cb er, response, shasum
      return

    return

  return
fetchAndShaCheck = (u, tmp, shasum, cb) ->
  registry.fetch u, null, (er, response) ->
    if er
      log.error "fetch failed", u
      return cb(er, response)
    tarball = createWriteStream(tmp,
      mode: npm.modes.file
    )
    tarball.on "error", (er) ->
      cb er
      tarball.destroy()
      return

    tarball.on "finish", ->
      unless shasum
        
        # Well, we weren't given a shasum, so at least sha what we have
        # in case we want to compare it to something else later
        return sha.get(tmp, (er, shasum) ->
          log.silly "fetchAndShaCheck", "shasum", shasum
          cb er, response, shasum
          return
        )
      
      # validate that the url we just downloaded matches the expected shasum.
      log.silly "fetchAndShaCheck", "shasum", shasum
      sha.check tmp, shasum, (er) ->
        
        # add original filename for better debuggability
        er.message = er.message + "\n" + "From:     " + u  if er and er.message
        cb er, response, shasum

      return

    response.pipe tarball
    return

  return
mkdir = require("mkdirp")
assert = require("assert")
log = require("npmlog")
path = require("path")
sha = require("sha")
retry = require("retry")
createWriteStream = require("fs-write-stream-atomic")
npm = require("../npm.js")
registry = npm.registry
inflight = require("inflight")
addLocalTarball = require("./add-local-tarball.js")
cacheFile = require("npm-cache-filename")
module.exports = addRemoteTarball
