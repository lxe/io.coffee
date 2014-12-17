setup = (cb) ->
  cleanup()
  process.chdir pkg
  opts =
    cache: path.resolve(pkg, "cache")
    registry: common.registry

  npm.load opts, cb
  return
cleanup = ->
  process.chdir osenv.tmpdir()
  rimraf.sync path.resolve(pkg, "node_modules")
  rimraf.sync path.resolve(pkg, "cache")
  return
npm = npm = require("../../")
test = require("tap").test
path = require("path")
fs = require("fs")
osenv = require("osenv")
rimraf = require("rimraf")
mr = require("npm-registry-mock")
common = require("../common-tap.js")
pkg = path.resolve(__dirname, "dev-dep-duplicate")
desiredResultsPath = path.resolve(pkg, "desired-ls-results.json")
test "prefers version from dependencies over devDependencies", (t) ->
  t.plan 1
  mr common.port, (s) ->
    setup (err) ->
      return t.fail(err)  if err
      npm.install ".", (err) ->
        return t.fail(err)  if err
        npm.commands.ls [], true, (err, _, results) ->
          return t.fail(err)  if err
          fs.readFile desiredResultsPath, (err, desired) ->
            return t.fail(err)  if err
            t.deepEqual results, JSON.parse(desired)
            s.close()
            t.end()
            return

          return

        return

      return

    return

  return

test "cleanup", (t) ->
  cleanup()
  t.end()
  return

