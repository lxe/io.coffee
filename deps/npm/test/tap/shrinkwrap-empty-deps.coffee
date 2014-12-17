setup = (cb) ->
  cleanup()
  process.chdir pkg
  npm.load
    cache: cache
    registry: common.registry
  , ->
    cb()
    return

  return
cleanup = ->
  process.chdir osenv.tmpdir()
  rimraf.sync path.resolve(pkg, "npm-shrinkwrap.json")
  return
test = require("tap").test
npm = require("../../")
mr = require("npm-registry-mock")
common = require("../common-tap.js")
path = require("path")
fs = require("fs")
osenv = require("osenv")
rimraf = require("rimraf")
pkg = path.resolve(__dirname, "shrinkwrap-empty-deps")
cache = path.resolve(pkg, "cache")
test "returns a list of removed items", (t) ->
  desiredResultsPath = path.resolve(pkg, "npm-shrinkwrap.json")
  cleanup()
  mr common.port, (s) ->
    setup ->
      npm.shrinkwrap [], (err) ->
        return t.fail(err)  if err
        fs.readFile desiredResultsPath, (err, desired) ->
          return t.fail(err)  if err
          t.deepEqual
            name: "npm-test-shrinkwrap-empty-deps"
            version: "0.0.0"
            dependencies: {}
          , JSON.parse(desired)
          cleanup()
          s.close()
          t.end()
          return

        return

      return

    return

  return

