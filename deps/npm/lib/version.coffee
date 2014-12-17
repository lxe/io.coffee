# npm version <newver>
version = (args, silent, cb_) ->
  if typeof cb_ isnt "function"
    cb_ = silent
    silent = false
  return cb_(version.usage)  if args.length > 1
  fs.readFile path.join(npm.localPrefix, "package.json"), (er, data) ->
    unless args.length
      v = {}
      Object.keys(process.versions).forEach (k) ->
        v[k] = process.versions[k]
        return

      v.npm = npm.version
      try
        data = JSON.parse(data.toString())
      catch er
        data = null
      v[data.name] = data.version  if data and data.name and data.version
      v = JSON.stringify(v, null, 2)  if npm.config.get("json")
      console.log v
      return cb_()
    if er
      log.error "version", "No package.json found"
      return cb_(er)
    try
      data = JSON.parse(data)
    catch er
      log.error "version", "Bad package.json data"
      return cb_(er)
    newVer = semver.valid(args[0])
    newVer = semver.inc(data.version, args[0])  unless newVer
    return cb_(version.usage)  unless newVer
    return cb_(new Error("Version not changed"))  if data.version is newVer
    data.version = newVer
    fs.stat path.join(npm.localPrefix, ".git"), (er, s) ->
      cb = (er) ->
        console.log "v" + newVer  if not er and not silent
        cb_ er
        return
      tags = npm.config.get("git-tag-version")
      doGit = not er and s.isDirectory() and tags
      unless doGit
        write data, cb
      else
        checkGit data, cb
      return

    return

  return
checkGit = (data, cb) ->
  args = [
    "status"
    "--porcelain"
  ]
  options = env: process.env
  
  # check for git
  git.whichAndExec args, options, (er, stdout) ->
    if er and er.code is "ENOGIT"
      log.warn "version", "This is a Git checkout, but the git command was not found.", "npm could not create a Git tag for this release!"
      return write(data, cb)
    lines = stdout.trim().split("\n").filter((line) ->
      line.trim() and not line.match(/^\?\? /)
    ).map((line) ->
      line.trim()
    )
    return cb(new Error("Git working directory not clean.\n" + lines.join("\n")))  if lines.length
    write data, (er) ->
      return cb(er)  if er
      message = npm.config.get("message").replace(/%s/g, data.version)
      sign = npm.config.get("sign-git-tag")
      flag = (if sign then "-sm" else "-am")
      chain [
        git.chainableExec([
          "add"
          "package.json"
        ],
          env: process.env
        )
        git.chainableExec([
          "commit"
          "-m"
          message
        ],
          env: process.env
        )
        sign and (cb) ->
          npm.spinner.stop()
          cb()
          return
        git.chainableExec([
          "tag"
          "v" + data.version
          flag
          message
        ],
          env: process.env
        )
      ], cb
      return

    return

  return
write = (data, cb) ->
  writeFileAtomic path.join(npm.localPrefix, "package.json"), new Buffer(JSON.stringify(data, null, 2) + "\n"), cb
  return
module.exports = version
exec = require("child_process").execFile
semver = require("semver")
path = require("path")
fs = require("graceful-fs")
writeFileAtomic = require("write-file-atomic")
chain = require("slide").chain
log = require("npmlog")
which = require("which")
npm = require("./npm.js")
git = require("./utils/git.js")
version.usage = "npm version [<newversion> | major | minor | patch | prerelease | preminor | premajor ]\n" + "\n(run in package dir)\n" + "'npm -v' or 'npm --version' to print npm version " + "(" + npm.version + ")\n" + "'npm view <pkg> version' to view a package's " + "published version\n" + "'npm ls' to inspect current package/dependency versions"
