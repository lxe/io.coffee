setup = (cb) ->
  cleanup()
  process.chdir path.resolve(pkg, "minimist")
  fs.mkdirSync path.resolve(pkg, "minimist/node_modules")
  mr common.port, (s) ->
    server = s
    npm.load
      loglevel: "silent"
      registry: common.registry
      cache: path.resolve(pkg, "cache")
    , cb
    return

  return
cleanup = ->
  process.chdir osenv.tmpdir()
  rimraf.sync path.resolve(pkg, "minimist/node_modules")
  rimraf.sync path.resolve(pkg, "cache")
  return
test = require("tap").test
fs = require("fs")
path = require("path")
existsSync = fs.existsSync or path.existsSync
npm = require("../../")
rimraf = require("rimraf")
osenv = require("osenv")
mr = require("npm-registry-mock")
common = require("../common-tap.js")
server = undefined
pkg = path.resolve(__dirname, "circular-dep")
test "installing a package that depends on the current package", (t) ->
  t.plan 1
  setup ->
    npm.install "optimist", (err) ->
      return t.fail(err)  if err
      npm.dedupe (err) ->
        return t.fail(err)  if err
        t.ok existsSync(path.resolve(pkg, "minimist", "node_modules", "optimist", "node_modules", "minimist")), "circular dependency uncircled"
        cleanup()
        server.close()
        return

      return

    return

  return

