# Fixes Issue #1770
setup = ->
  mkdirp.sync pkg
  mkdirp.sync cache
  fs.writeFileSync path.resolve(pkg, "package.json"), JSON.stringify(
    author: "Evan Lucas"
    name: "outdated-notarget"
    version: "0.0.0"
    description: "Test for outdated-target"
    dependencies:
      underscore: "~199.7.1"
  ), "utf8"
  process.chdir pkg
  return
common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
osenv = require("osenv")
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = path.resolve(__dirname, "outdated-notarget")
cache = path.resolve(pkg, "cache")
mr = require("npm-registry-mock")
test "outdated-target: if no viable version is found, show error", (t) ->
  t.plan 1
  setup()
  mr
    port: common.port
  , (s) ->
    npm.load
      cache: cache
      registry: common.registry
    , ->
      npm.commands.update (er) ->
        t.equal er.code, "ETARGET"
        s.close()
        t.end()
        return

      return

    return

  return

test "cleanup", (t) ->
  process.chdir osenv.tmpdir()
  rimraf.sync pkg
  t.end()
  return

