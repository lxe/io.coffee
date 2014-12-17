writePackageJson = ->
  rimraf.sync pkg
  mkdirp.sync pkg
  mkdirp.sync pkg + "/cache"
  fs.writeFileSync pkg + "/package.json", JSON.stringify(
    author: "Rocko Artischocko"
    name: "noargs"
    version: "0.0.0"
    devDependencies:
      underscore: "1.3.1"
  ), "utf8"
  return
createChild = (args) ->
  env =
    npm_config_save: true
    npm_config_registry: common.registry
    npm_config_cache: pkg + "/cache"
    HOME: process.env.HOME
    Path: process.env.PATH
    PATH: process.env.PATH

  env.npm_config_cache = "%APPDATA%\\npm-cache"  if process.platform is "win32"
  spawn node, args,
    cwd: pkg
    env: env

common = require("../common-tap.js")
test = require("tap").test
npm = require.resolve("../../bin/npm-cli.js")
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
mr = require("npm-registry-mock")
spawn = require("child_process").spawn
node = process.execPath
pkg = path.resolve(process.env.npm_config_tmp or "/tmp", "noargs-install-config-save")
test "does not update the package.json with empty arguments", (t) ->
  writePackageJson()
  t.plan 1
  mr common.port, (s) ->
    child = createChild([
      npm
      "install"
    ])
    child.on "close", ->
      text = JSON.stringify(fs.readFileSync(pkg + "/package.json", "utf8"))
      t.ok text.indexOf("\"dependencies") is -1
      s.close()
      t.end()
      return

    return

  return

test "updates the package.json (adds dependencies) with an argument", (t) ->
  writePackageJson()
  t.plan 1
  mr common.port, (s) ->
    child = createChild([
      npm
      "install"
      "underscore"
    ])
    child.on "close", ->
      text = JSON.stringify(fs.readFileSync(pkg + "/package.json", "utf8"))
      t.ok text.indexOf("\"dependencies") isnt -1
      s.close()
      t.end()
      return

    return

  return

test "cleanup", (t) ->
  rimraf.sync pkg + "/cache"
  t.end()
  return

