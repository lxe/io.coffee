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
pkg = path.resolve(__dirname, "peer-deps-toplevel")
desiredResultsPath = path.resolve(pkg, "desired-ls-results.json")
test "installs the peer dependency directory structure", (t) ->
  mr common.port, (s) ->
    setup (err) ->
      t.ifError err, "setup ran successfully"
      npm.install ".", (err) ->
        t.ifError err, "packages were installed"
        npm.commands.ls [], true, (err, _, results) ->
          t.ifError err, "listed tree without problems"
          fs.readFile desiredResultsPath, (err, desired) ->
            t.ifError err, "read desired results"
            t.deepEqual results, JSON.parse(desired), "got expected output from ls"
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

