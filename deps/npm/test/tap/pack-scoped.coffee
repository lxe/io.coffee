# verify that prepublish runs on pack and publish
test = require("tap").test
common = require("../common-tap")
fs = require("graceful-fs")
join = require("path").join
mkdirp = require("mkdirp")
rimraf = require("rimraf")
pkg = join(__dirname, "scoped_package")
manifest = join(pkg, "package.json")
tmp = join(pkg, "tmp")
cache = join(pkg, "cache")
data =
  name: "@scope/generic-package"
  version: "90000.100001.5"

test "setup", (t) ->
  then = ->
    n++
    (er) ->
      t.ifError er
      next()  if --n is 0
      return
  next = ->
    fs.writeFile manifest, JSON.stringify(data), "ascii", done
    return
  done = (er) ->
    t.ifError er
    t.pass "setup done"
    t.end()
    return
  n = 0
  rimraf.sync pkg
  mkdirp pkg, then_()
  mkdirp cache, then_()
  mkdirp tmp, then_()
  return

test "test", (t) ->
  env =
    npm_config_cache: cache
    npm_config_tmp: tmp
    npm_config_prefix: pkg
    npm_config_global: "false"

  for i of process.env
    env[i] = process.env[i]  unless /^npm_config_/.test(i)
  common.npm [
    "pack"
    "--loglevel"
    "warn"
  ],
    cwd: pkg
    env: env
  , (err, code, stdout, stderr) ->
    t.ifErr err, "npm pack finished without error"
    t.equal code, 0, "npm pack exited ok"
    t.notOk stderr, "got stderr data: " + JSON.stringify("" + stderr)
    stdout = stdout.trim()
    regex = new RegExp("scope-generic-package-90000.100001.5.tgz", "ig")
    t.ok stdout.match(regex), "found package"
    t.end()
    return

  return

test "cleanup", (t) ->
  rimraf.sync pkg
  t.pass "cleaned up"
  t.end()
  return

