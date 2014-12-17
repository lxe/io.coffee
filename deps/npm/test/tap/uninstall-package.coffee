setup = (cb) ->
  cleanup()
  process.chdir pkg
  npm.load
    cache: pkg + "/cache"
    registry: common.registry
  , ->
    cb()
    return

  return
cleanup = ->
  rimraf.sync pkg + "/node_modules"
  rimraf.sync pkg + "/cache"
  return
test = require("tap").test
npm = require("../../")
rimraf = require("rimraf")
mr = require("npm-registry-mock")
common = require("../common-tap.js")
path = require("path")
pkg = path.join(__dirname, "uninstall-package")
test "returns a list of removed items", (t) ->
  t.plan 1
  mr common.port, (s) ->
    setup ->
      npm.install ".", (err) ->
        return t.fail(err)  if err
        npm.uninstall "underscore", "request", "lala", (err, d) ->
          return t.fail(err)  if err
          t.same d.sort(), [
            "underscore"
            "request"
          ].sort()
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

