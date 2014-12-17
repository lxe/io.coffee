common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
mkdirp = require("mkdirp")
rimraf = require("rimraf")
path = require("path")
mr = require("npm-registry-mock")
pkg = path.resolve(__dirname, "outdated-new-versions")
cache = path.resolve(pkg, "cache")
mkdirp.sync cache
test "dicovers new versions in outdated", (t) ->
  process.chdir pkg
  t.plan 2
  mr common.port, (s) ->
    npm.load
      cache: cache
      registry: common.registry
    , ->
      npm.outdated (er, d) ->
        i = 0

        while i < d.length
          t.equal "1.5.1", d[i][4]  if d[i][1] is "underscore"
          t.equal "2.27.0", d[i][4]  if d[i][1] is "request"
          i++
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

