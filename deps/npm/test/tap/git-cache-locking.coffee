test = require("tap").test
common = require("../common-tap")
path = require("path")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = path.resolve(__dirname, "git-cache-locking")
tmp = path.join(pkg, "tmp")
cache = path.join(pkg, "cache")
test "setup", (t) ->
  rimraf.sync pkg
  mkdirp.sync path.resolve(pkg, "node_modules")
  t.end()
  return

test "git-cache-locking: install a git dependency", (t) ->
  
  # disable git integration tests on Travis.
  return t.end()  if process.env.TRAVIS
  
  # package c depends on a.git#master and b.git#master
  # package b depends on a.git#master
  common.npm [
    "install"
    "git://github.com/nigelzor/npm-4503-c.git"
  ],
    cwd: pkg
    env:
      npm_config_cache: cache
      npm_config_tmp: tmp
      npm_config_prefix: pkg
      npm_config_global: "false"
      HOME: process.env.HOME
      Path: process.env.PATH
      PATH: process.env.PATH
  , (err, code) ->
    t.ifErr err, "npm install finished without error"
    t.equal 0, code, "npm install should succeed"
    t.end()
    return

  return

test "cleanup", (t) ->
  rimraf.sync pkg
  t.end()
  return

