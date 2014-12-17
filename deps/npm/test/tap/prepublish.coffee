# verify that prepublish runs on pack and publish
cleanup = ->
  rimraf.sync pkg
  return
common = require("../common-tap")
test = require("tap").test
fs = require("graceful-fs")
join = require("path").join
mkdirp = require("mkdirp")
rimraf = require("rimraf")
pkg = join(__dirname, "prepublish_package")
tmp = join(pkg, "tmp")
cache = join(pkg, "cache")
test "setup", (t) ->
  then = ->
    n++
    (er) ->
      throw er  if er
      next()  if --n is 0
      return
  next = ->
    fs.writeFile join(pkg, "package.json"), JSON.stringify(
      name: "npm-test-prepublish"
      version: "1.2.5"
      scripts:
        prepublish: "echo ok"
    ), "ascii", (er) ->
      throw er  if er
      t.pass "setup done"
      t.end()
      return

    return
  n = 0
  cleanup()
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
    t.equal code, 0, "pack finished successfully"
    t.ifErr err, "pack finished successfully"
    t.notOk stderr, "got stderr data:" + JSON.stringify("" + stderr)
    c = stdout.trim()
    regex = new RegExp("" + "> npm-test-prepublish@1.2.5 prepublish [^\\r\\n]+\\r?\\n" + "> echo ok\\r?\\n" + "\\r?\\n" + "ok\\r?\\n" + "npm-test-prepublish-1.2.5.tgz", "ig")
    t.ok c.match(regex)
    t.end()
    return

  return

test "cleanup", (t) ->
  cleanup()
  t.pass "cleaned up"
  t.end()
  return

