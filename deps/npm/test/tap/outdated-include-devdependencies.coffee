common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
mkdirp = require("mkdirp")
rimraf = require("rimraf")
mr = require("npm-registry-mock")
path = require("path")

# config
pkg = path.resolve(__dirname, "outdated-include-devdependencies")
cache = path.resolve(pkg, "cache")
mkdirp.sync cache
test "includes devDependencies in outdated", (t) ->
  process.chdir pkg
  mr common.port, (s) ->
    npm.load
      cache: cache
      registry: common.registry
    , ->
      npm.outdated (er, d) ->
        t.equal "1.5.1", d[0][3]
        s.close()
        t.end()
        return

      return

    return

  return

test "cleanup", (t) ->
  rimraf.sync cache
  t.end()
  return

