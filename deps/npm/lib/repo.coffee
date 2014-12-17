repo = (args, cb) ->
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
  r = d.repository
  return cb(new Error("no repository"))  unless r
  
  # XXX remove this when npm@v1.3.10 from node 0.10 is deprecated
  # from https://github.com/npm/npm-www/issues/418
  r.url = githubUserRepo(r.url)  if githubUserRepo(r.url)
  url = (if (r.url and ~r.url.indexOf("github")) then github(r.url) else nonGithubUrl(r.url))
  return cb(new Error("no repository: could not get url"))  unless url
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
nonGithubUrl = (url) ->
  try
    idx = url.indexOf("@")
    url = url.slice(idx + 1).replace(/:([^\d]+)/, "/$1")  if idx isnt -1
    url = url_.parse(url)
    protocol = (if url.protocol is "https:" then "https:" else "http:")
    return protocol + "//" + (url.host or "") + url.path.replace(/\.git$/, "")
  return
module.exports = repo
repo.usage = "npm repo <pkgname>"
repo.completion = (opts, cb) ->
  return cb()  if opts.conf.argv.remain.length > 2
  mapToRegistry "/-/short", npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri,
      timeout: 60000
    , (er, list) ->
      cb null, list or []

    return

  return

npm = require("./npm.js")
registry = npm.registry
opener = require("opener")
github = require("github-url-from-git")
githubUserRepo = require("github-url-from-username-repo")
path = require("path")
readJson = require("read-package-json")
fs = require("fs")
url_ = require("url")
mapToRegistry = require("./utils/map-to-registry.js")
npa = require("npm-package-arg")
