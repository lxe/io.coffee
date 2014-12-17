common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
mkdirp = require("mkdirp")
rimraf = require("rimraf")
path = require("path")

# config
pkg = path.resolve(__dirname, "outdated-git")
cache = path.resolve(pkg, "cache")
mkdirp.sync cache
test "dicovers new versions in outdated", (t) ->
  process.chdir pkg
  t.plan 5
  npm.load
    cache: cache
    registry: common.registry
  , ->
    npm.commands.outdated [], (er, d) ->
      t.equal "git", d[0][3]
      t.equal "git", d[0][4]
      t.equal "git://github.com/robertkowalski/foo-private.git", d[0][5]
      t.equal "git://user:pass@github.com/robertkowalski/foo-private.git", d[1][5]
      t.equal "git+https://github.com/robertkowalski/foo", d[2][5]
      return

    return

  return

test "cleanup", (t) ->
  rimraf.sync cache
  t.end()
  return

