setup = (opts, cb) ->
  cleanup()
  process.chdir pkg
  allOpts =
    cache: path.resolve(pkg, "cache")
    registry: common.registry

  for key of opts
    allOpts[key] = opts[key]
  npm.load allOpts, cb
  return
cleanup = ->
  process.chdir osenv.tmpdir()
  rimraf.sync path.resolve(pkg, "node_modules")
  rimraf.sync path.resolve(pkg, "cache")
  rimraf.sync path.resolve(pkg, "npm-shrinkwrap.json")
  return
npm = npm = require("../../")
test = require("tap").test
path = require("path")
fs = require("fs")
osenv = require("osenv")
rimraf = require("rimraf")
mr = require("npm-registry-mock")
common = require("../common-tap.js")
pkg = path.resolve(__dirname, "shrinkwrap-dev-dependency")
desiredResultsPath = path.resolve(pkg, "desired-shrinkwrap-results.json")
test "shrinkwrap doesn't strip out the dependency", (t) ->
  t.plan 1
  mr common.port, (s) ->
    setup
      production: true
    , (err) ->
      return t.fail(err)  if err
      npm.install ".", (err) ->
        return t.fail(err)  if err
        npm.commands.shrinkwrap [], true, (err, results) ->
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

