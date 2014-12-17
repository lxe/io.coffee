cleanup = ->
  process.chdir osenv.tmpdir()
  rimraf.sync pkg + "/cache"
  rimraf.sync pkg + "/tmp"
  rimraf.sync pkg + "/node_modules"
  return
common = require("../common-tap")
test = require("tap").test
path = require("path")
rimraf = require("rimraf")
osenv = require("osenv")
mkdirp = require("mkdirp")
pkg = path.resolve(__dirname, "ls-depth")
mr = require("npm-registry-mock")
opts = cwd: pkg
test "setup", (t) ->
  cleanup()
  mkdirp.sync pkg + "/cache"
  mkdirp.sync pkg + "/tmp"
  mr common.port, (s) ->
    cmd = [
      "install"
      "--registry=" + common.registry
    ]
    common.npm cmd, opts, (er, c) ->
      throw er  if er
      t.equal c, 0
      s.close()
      t.end()
      return

    return

  return

test "npm ls --depth=0", (t) ->
  common.npm [
    "ls"
    "--depth=0"
  ], opts, (er, c, out) ->
    throw er  if er
    t.equal c, 0
    t.has out, /test-package-with-one-dep@0\.0\.0/, "output contains test-package-with-one-dep@0.0.0"
    t.doesNotHave out, /test-package@0\.0\.0/, "output not contains test-package@0.0.0"
    t.end()
    return

  return

test "npm ls --depth=1", (t) ->
  common.npm [
    "ls"
    "--depth=1"
  ], opts, (er, c, out) ->
    throw er  if er
    t.equal c, 0
    t.has out, /test-package-with-one-dep@0\.0\.0/, "output contains test-package-with-one-dep@0.0.0"
    t.has out, /test-package@0\.0\.0/, "output contains test-package@0.0.0"
    t.end()
    return

  return

test "npm ls --depth=Infinity", (t) ->
  
  # travis has a preconfigured depth=0, in general we can not depend
  # on the default value in all environments, so explictly set it here
  common.npm [
    "ls"
    "--depth=Infinity"
  ], opts, (er, c, out) ->
    throw er  if er
    t.equal c, 0
    t.has out, /test-package-with-one-dep@0\.0\.0/, "output contains test-package-with-one-dep@0.0.0"
    t.has out, /test-package@0\.0\.0/, "output contains test-package@0.0.0"
    t.end()
    return

  return

test "cleanup", (t) ->
  cleanup()
  t.end()
  return

