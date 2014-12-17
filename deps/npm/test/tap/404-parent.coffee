setup = ->
  mkdirp.sync pkg
  mkdirp.sync path.resolve(pkg, "cache")
  fs.writeFileSync path.resolve(pkg, "package.json"), JSON.stringify(
    author: "Evan Lucas"
    name: "404-parent-test"
    version: "0.0.0"
    description: "Test for 404-parent"
    dependencies:
      "test-npm-404-parent-test": "*"
  ), "utf8"
  process.chdir pkg
  return
performInstall = (cb) ->
  mr common.port, (s) -> # create mock registry.
    npm.load
      registry: common.registry
    , ->
      npm.commands.install pkg, [], (err) ->
        cb err
        s.close() # shutdown mock npm server.
        return

      return

    return

  return
common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
osenv = require("osenv")
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = path.resolve(__dirname, "404-parent")
mr = require("npm-registry-mock")
test "404-parent: if parent exists, specify parent in error message", (t) ->
  setup()
  rimraf.sync path.resolve(pkg, "node_modules")
  performInstall (err) ->
    t.ok err instanceof Error, "error was returned"
    t.ok err.parent is "404-parent-test", "error's parent set"
    t.end()
    return

  return

test "cleanup", (t) ->
  process.chdir osenv.tmpdir()
  rimraf.sync pkg
  t.end()
  return

