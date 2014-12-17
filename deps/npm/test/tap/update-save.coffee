# mock server reference
resetPackage = (extendWith) ->
  rimraf.sync CACHE_DIR
  rimraf.sync MODULES_DIR
  mkdirp.sync CACHE_DIR
  pkg = clone(DEFAULT_PKG)
  extend pkg, extendWith
  for key of extend
    pkg[key] = extend[key]
  fs.writeFileSync PKG, JSON.stringify(pkg, null, 2), "ascii"
  pkg
# restore package.json
clone = (a) ->
  extend {}, a
extend = (a, b) ->
  for key of b
    a[key] = b[key]
  a
common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
mkdirp = require("mkdirp")
rimraf = require("rimraf")
fs = require("fs")
path = require("path")
mr = require("npm-registry-mock")
PKG_DIR = path.resolve(__dirname, "update-save")
PKG = path.resolve(PKG_DIR, "package.json")
CACHE_DIR = path.resolve(PKG_DIR, "cache")
MODULES_DIR = path.resolve(PKG_DIR, "node_modules")
EXEC_OPTS =
  cwd: PKG_DIR
  stdio: "ignore"
  env:
    npm_config_registry: common.registry
    npm_config_loglevel: "verbose"

DEFAULT_PKG =
  name: "update-save-example"
  version: "1.2.3"
  dependencies:
    mkdirp: "~0.3.0"

  devDependencies:
    underscore: "~1.3.1"

s = undefined
test "setup", (t) ->
  resetPackage()
  mr common.port, (server) ->
    npm.load
      cache: CACHE_DIR
      registry: common.registry
    , (err) ->
      t.ifError err
      s = server
      t.end()
      return

    return

  return

test "update regular dependencies only", (t) ->
  resetPackage()
  common.npm [
    "update"
    "--save"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err
    t.notOk code, "npm update exited with code 0"
    pkgdata = JSON.parse(fs.readFileSync(PKG, "utf8"))
    t.deepEqual pkgdata.dependencies,
      mkdirp: "^0.3.5"
    , "only dependencies updated"
    t.deepEqual pkgdata.devDependencies, DEFAULT_PKG.devDependencies, "dev dependencies should be untouched"
    t.deepEqual pkgdata.optionalDependencies, DEFAULT_PKG.optionalDependencies, "optional dependencies should be untouched"
    t.end()
    return

  return

test "update devDependencies only", (t) ->
  resetPackage()
  common.npm [
    "update"
    "--save-dev"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err
    t.notOk code, "npm update exited with code 0"
    pkgdata = JSON.parse(fs.readFileSync(PKG, "utf8"))
    t.deepEqual pkgdata.dependencies, DEFAULT_PKG.dependencies, "dependencies should be untouched"
    t.deepEqual pkgdata.devDependencies,
      underscore: "^1.3.3"
    , "dev dependencies should be updated"
    t.deepEqual pkgdata.optionalDependencies, DEFAULT_PKG.optionalDependencies, "optional dependencies should be untouched"
    t.end()
    return

  return

test "update optionalDependencies only", (t) ->
  resetPackage optionalDependencies:
    underscore: "~1.3.1"

  common.npm [
    "update"
    "--save-optional"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err
    t.notOk code, "npm update exited with code 0"
    pkgdata = JSON.parse(fs.readFileSync(PKG, "utf8"))
    t.deepEqual pkgdata.dependencies, DEFAULT_PKG.dependencies, "dependencies should be untouched"
    t.deepEqual pkgdata.devDependencies, DEFAULT_PKG.devDependencies, "dev dependencies should be untouched"
    t.deepEqual pkgdata.optionalDependencies,
      underscore: "^1.3.3"
    , "optional dependencies should be updated"
    t.end()
    return

  return

test "optionalDependencies are merged into dependencies during --save", (t) ->
  pkg = resetPackage(optionalDependencies:
    underscore: "~1.3.1"
  )
  common.npm [
    "update"
    "--save"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err
    t.notOk code, "npm update exited with code 0"
    pkgdata = JSON.parse(fs.readFileSync(PKG, "utf8"))
    t.deepEqual pkgdata.dependencies,
      mkdirp: "^0.3.5"
    , "dependencies should not include optional dependencies"
    t.deepEqual pkgdata.devDependencies, pkg.devDependencies, "dev dependencies should be untouched"
    t.deepEqual pkgdata.optionalDependencies, pkg.optionalDependencies, "optional dependencies should be untouched"
    t.end()
    return

  return

test "semver prefix is replaced with configured save-prefix", (t) ->
  resetPackage()
  common.npm [
    "update"
    "--save"
    "--save-prefix"
    "~"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err
    t.notOk code, "npm update exited with code 0"
    pkgdata = JSON.parse(fs.readFileSync(PKG, "utf8"))
    t.deepEqual pkgdata.dependencies,
      mkdirp: "~0.3.5"
    , "dependencies should be updated"
    t.deepEqual pkgdata.devDependencies, DEFAULT_PKG.devDependencies, "dev dependencies should be untouched"
    t.deepEqual pkgdata.optionalDependencies, DEFAULT_PKG.optionalDependencies, "optional dependencies should be updated"
    t.end()
    return

  return

test "cleanup", (t) ->
  s.close()
  resetPackage()
  rimraf.sync CACHE_DIR
  rimraf.sync MODULES_DIR
  t.end()
  return

