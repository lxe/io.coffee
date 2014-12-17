cleanup = ->
  rimraf.sync cache
  rimraf.sync tmp
  rimraf.sync modules
  return
test = require("tap").test
common = require("../common-tap")
path = require("path")
pkg = path.resolve(__dirname, "scripts-whitespace-windows")
tmp = path.resolve(pkg, "tmp")
cache = path.resolve(pkg, "cache")
modules = path.resolve(pkg, "node_modules")
dep = path.resolve(pkg, "dep")
mkdirp = require("mkdirp")
rimraf = require("rimraf")
test "setup", (t) ->
  cleanup()
  mkdirp.sync cache
  mkdirp.sync tmp
  common.npm [
    "i"
    dep
  ],
    cwd: pkg
    env:
      npm_config_cache: cache
      npm_config_tmp: tmp
      npm_config_prefix: pkg
      npm_config_global: "false"
  , (err, code, stdout, stderr) ->
    t.ifErr err, "npm i " + dep + " finished without error"
    t.equal code, 0, "npm i " + dep + " exited ok"
    t.notOk stderr, "no output stderr"
    t.end()
    return

  return

test "test", (t) ->
  common.npm [
    "run"
    "foo"
  ],
    cwd: pkg
  , (err, code, stdout, stderr) ->
    t.ifErr err, "npm run finished without error"
    t.equal code, 0, "npm run exited ok"
    t.notOk stderr, "no output stderr: ", stderr
    stdout = stdout.trim()
    t.ok /npm-test-fine/.test(stdout)
    t.end()
    return

  return

test "cleanup", (t) ->
  cleanup()
  t.end()
  return

