cleanup = ->
  rimraf.sync pkg + "/node_modules"
  rimraf.sync pkg + "/cache"
  return
common = require("../common-tap")
test = require("tap").test
rimraf = require("rimraf")
npm = require("../../")
mr = require("npm-registry-mock")
pkg = __dirname + "/outdated-depth"
test "outdated depth integer", (t) ->
  
  # todo: update with test-package-with-one-dep once the new
  # npm-registry-mock is published
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
      cache: pkg + "/cache"
      loglevel: "silent"
      registry: common.registry
      depth: 5
    , ->
      npm.install "request@0.9.0", (er) ->
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

