cleanup = ->
  rimraf.sync cache
  rimraf.sync nodeModules
  return
test = require("tap").test
common = require("../common-tap")
fs = require("fs")
rimraf = require("rimraf")
mr = require("npm-registry-mock")
env = process.env
path = require("path")
pkg = path.resolve(__dirname, "prune")
cache = path.resolve(pkg, "cache")
nodeModules = path.resolve(pkg, "node_modules")
EXEC_OPTS =
  cwd: pkg
  env: env

EXEC_OPTS.env.npm_config_depth = "Infinity"
server = undefined
test "reg mock", (t) ->
  mr common.port, (s) ->
    server = s
    t.pass "registry mock started"
    t.end()
    return

  return

test "setup", (t) ->
  cleanup()
  t.pass "setup"
  t.end()
  return

test "npm install", (t) ->
  common.npm [
    "install"
    "--cache"
    cache
    "--registry"
    common.registry
    "--loglevel"
    "silent"
    "--production"
    "false"
  ], EXEC_OPTS, (err, code, stdout, stderr) ->
    t.ifErr err, "install finished successfully"
    t.notOk code, "exit ok"
    t.notOk stderr, "Should not get data on stderr: " + stderr
    t.end()
    return

  return

test "npm install test-package", (t) ->
  common.npm [
    "install"
    "test-package"
    "--cache"
    cache
    "--registry"
    common.registry
    "--loglevel"
    "silent"
    "--production"
    "false"
  ], EXEC_OPTS, (err, code, stdout, stderr) ->
    t.ifErr err, "install finished successfully"
    t.notOk code, "exit ok"
    t.notOk stderr, "Should not get data on stderr: " + stderr
    t.end()
    return

  return

test "verify installs", (t) ->
  dirs = fs.readdirSync(pkg + "/node_modules").sort()
  t.same dirs, [
    "test-package"
    "mkdirp"
    "underscore"
  ].sort()
  t.end()
  return

test "npm prune", (t) ->
  common.npm [
    "prune"
    "--loglevel"
    "silent"
    "--production"
    "false"
  ], EXEC_OPTS, (err, code, stdout, stderr) ->
    t.ifErr err, "prune finished successfully"
    t.notOk code, "exit ok"
    t.notOk stderr, "Should not get data on stderr: " + stderr
    t.end()
    return

  return

test "verify installs", (t) ->
  dirs = fs.readdirSync(pkg + "/node_modules").sort()
  t.same dirs, [
    "mkdirp"
    "underscore"
  ]
  t.end()
  return

test "npm prune", (t) ->
  common.npm [
    "prune"
    "--loglevel"
    "silent"
    "--production"
  ], EXEC_OPTS, (err, code, stderr) ->
    t.ifErr err, "prune finished successfully"
    t.notOk code, "exit ok"
    t.equal stderr, "unbuild mkdirp@0.3.5\n"
    t.end()
    return

  return

test "verify installs", (t) ->
  dirs = fs.readdirSync(pkg + "/node_modules").sort()
  t.same dirs, ["underscore"]
  t.end()
  return

test "cleanup", (t) ->
  server.close()
  cleanup()
  t.pass "cleaned up"
  t.end()
  return

