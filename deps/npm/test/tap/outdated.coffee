
# config
cleanup = ->
  rimraf.sync nodeModules
  rimraf.sync cache
  return
common = require("../common-tap.js")
test = require("tap").test
rimraf = require("rimraf")
npm = require("../../")
path = require("path")
mr = require("npm-registry-mock")
pkg = path.resolve(__dirname, "outdated")
cache = path.resolve(pkg, "cache")
nodeModules = path.resolve(pkg, "node_modules")
test "it should not throw", (t) ->
  cleanup()
  process.chdir pkg
  originalLog = console.log
  output = []
  expOut = [
    path.resolve(__dirname, "outdated/node_modules/underscore")
    path.resolve(__dirname, "outdated/node_modules/underscore") + ":underscore@1.3.1" + ":underscore@1.3.1" + ":underscore@1.5.1"
  ]
  expData = [[
    path.resolve(__dirname, "outdated")
    "underscore"
    "1.3.1"
    "1.3.1"
    "1.5.1"
    "1.3.1"
  ]]
  console.log = ->
    output.push.apply output, arguments
    return

  mr common.port, (s) ->
    npm.load
      cache: "cache"
      loglevel: "silent"
      parseable: true
      registry: common.registry
    , ->
      npm.install ".", (err) ->
        t.ifError err, "install success"
        npm.outdated (er, d) ->
          t.ifError er, "outdated success"
          console.log = originalLog
          t.same output, expOut
          t.same d, expData
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

