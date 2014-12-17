setup = ->
  mkdirp.sync pkg
  mkdirp.sync cache
  mkdirp.sync gitDir
  fs.writeFileSync path.resolve(pkg, "package.json"), JSON.stringify(
    author: "Terin Stock"
    name: "version-no-git-test"
    version: "0.0.0"
    description: "Test for npm version if git binary doesn't exist"
  ), "utf8"
  process.chdir pkg
  return
common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
osenv = require("osenv")
path = require("path")
fs = require("fs")
mkdirp = require("mkdirp")
rimraf = require("rimraf")
requireInject = require("require-inject")
pkg = path.resolve(__dirname, "version-no-git")
cache = path.resolve(pkg, "cache")
gitDir = path.resolve(pkg, ".git")
test "npm version <semver> in a git repo without the git binary", (t) ->
  setup()
  npm.load
    cache: cache
    registry: common.registry
  , ->
    version = requireInject("../../lib/version",
      which: (cmd, cb) ->
        process.nextTick ->
          cb new Error("ENOGIT!")
          return

        return
    )
    version ["patch"], (err) ->
      return t.fail("Error performing version patch")  if err
      p = path.resolve(pkg, "package")
      testPkg = require(p)
      t.equal "0.0.1", testPkg.version, "\"" + testPkg.version + "\" === \"0.0.1\""
      t.end()
      return

    return

  return

test "cleanup", (t) ->
  process.chdir osenv.tmpdir()
  rimraf.sync pkg
  t.end()
  return

