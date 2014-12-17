cleanup = ->
  rimraf.sync nodeModules
  rimraf.sync cache
  return
common = require("../common-tap")
path = require("path")
test = require("tap").test
rimraf = require("rimraf")
npm = require("../../")
mr = require("npm-registry-mock")
pkg = path.resolve(__dirname, "outdated-depth")
cache = path.resolve(pkg, "cache")
nodeModules = path.resolve(pkg, "node_modules")
test "outdated depth zero", (t) ->
  expected = [
    pkg
    "underscore"
    "1.3.1"
    "1.3.1"
    "1.5.1"
    "1.3.1"
  ]
  process.chdir pkg
  mr common.port, (s) ->
    npm.load
      cache: cache
      loglevel: "silent"
      registry: common.registry
      depth: 0
    , ->
      npm.install ".", (er) ->
        throw new Error(er)  if er
        npm.outdated (err, d) ->
          throw new Error(err)  if err
          t.deepEqual d[0], expected
          s.close()
          t.end()
          return

        return

      return

    return

  return

test "cleanup", (t) ->
  cleanup()
  t.end()
  return

