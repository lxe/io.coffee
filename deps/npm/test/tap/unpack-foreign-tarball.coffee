verify = (t, files, err, code) ->
  if code
    t.fail "exited with failure: " + code
    return t.end()
  actual = fs.readdirSync(pkg).sort()
  expect = files.concat([
    ".npmignore"
    "package.json"
  ]).sort()
  t.same actual, expect
  t.end()
  return
setup = ->
  clean()
  mkdirp.sync nm
  mkdirp.sync cache
  mkdirp.sync tmp
  return
clean = ->
  rimraf.sync root
  rimraf.sync cache
  rimraf.sync tmp
  return
test = require("tap").test
rimraf = require("rimraf")
mkdirp = require("mkdirp")
common = require("../common-tap.js")
path = require("path")
fs = require("fs")
dir = path.resolve(__dirname, "unpack-foreign-tarball")
root = path.resolve(dir, "root")
nm = path.resolve(root, "node_modules")
cache = path.resolve(dir, "cache")
tmp = path.resolve(dir, "tmp")
pkg = path.resolve(nm, "npm-test-gitignore")
env =
  npm_config_cache: cache
  npm_config_tmp: tmp

conf =
  env: env
  cwd: root
  stdio: [
    "pipe"
    "pipe"
    2
  ]

test "npmignore only", (t) ->
  setup()
  file = path.resolve(dir, "npmignore.tgz")
  common.npm [
    "install"
    file
  ], conf, verify.bind(null, t, ["foo"])
  return

test "gitignore only", (t) ->
  setup()
  file = path.resolve(dir, "gitignore.tgz")
  common.npm [
    "install"
    file
  ], conf, verify.bind(null, t, ["foo"])
  return

test "gitignore and npmignore", (t) ->
  setup()
  file = path.resolve(dir, "gitignore-and-npmignore.tgz")
  common.npm [
    "install"
    file
  ], conf, verify.bind(null, t, [
    "foo"
    "bar"
  ])
  return

test "gitignore and npmignore, not gzipped", (t) ->
  setup()
  file = path.resolve(dir, "gitignore-and-npmignore.tar")
  common.npm [
    "install"
    file
  ], conf, verify.bind(null, t, [
    "foo"
    "bar"
  ])
  return

test "clean", (t) ->
  clean()
  t.end()
  return

