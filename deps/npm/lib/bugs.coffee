bugs = (args, cb) ->
  n = args.length and npa(args[0]).name or "."
  fs.stat n, (er, s) ->
    if er and er.code is "ENOENT"
      return callRegistry(n, cb)
    else return cb(er)  if er
    return callRegistry(n, cb)  unless s.isDirectory()
    readJson path.resolve(n, "package.json"), (er, d) ->
      return cb(er)  if er
      getUrlAndOpen d, cb
      return

    return

  return
getUrlAndOpen = (d, cb) ->
  bugs = d.bugs
  repo = d.repository or d.repositories
  url = undefined
  if bugs
    url = (if (typeof url is "string") then bugs else bugs.url)
  else if repo
    repo = repo.shift()  if Array.isArray(repo)
    repo = repo.url  if repo.hasOwnProperty("url")
    log.verbose "repository", repo
    url = bugs.replace(/^git(@|:\/\/)/, "https://").replace(/^https?:\/\/github.com:/, "https://github.com/").replace(/\.git$/, "") + "/issues"  if bugs and bugs.match(/^(https?:\/\/|git(:\/\/|@))github.com/)
  url = "https://npmjs.org/package/" + d.name  unless url
  opener url,
    command: npm.config.get("browser")
  , cb
  return
callRegistry = (n, cb) ->
  mapToRegistry n, npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri + "/latest",
      timeout: 3600
    , (er, d) ->
      return cb(er)  if er
      getUrlAndOpen d, cb
      return

    return

  return
module.exports = bugs
bugs.usage = "npm bugs <pkgname>"
npm = require("./npm.js")
registry = npm.registry
log = require("npmlog")
opener = require("opener")
path = require("path")
readJson = require("read-package-json")
npa = require("npm-package-arg")
fs = require("fs")
mapToRegistry = require("./utils/map-to-registry.js")
bugs.completion = (opts, cb) ->
  return cb()  if opts.conf.argv.remain.length > 2
  mapToRegistry "-/short", npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri,
      timeout: 60000
    , (er, list) ->
      cb null, list or []

    return

  return
