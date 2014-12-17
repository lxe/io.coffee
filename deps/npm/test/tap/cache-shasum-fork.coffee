test = require("tap").test
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
mr = require("npm-registry-mock")
common = require("../common-tap.js")
cache = path.resolve(__dirname, "cache-shasum-fork", "CACHE")
cwd = path.resolve(__dirname, "cache-shasum-fork", "CWD")
server = undefined

# Test for https://github.com/npm/npm/issues/3265
test "mock reg", (t) ->
  rimraf.sync cache
  mkdirp.sync cache
  rimraf.sync cwd
  mkdirp.sync path.join(cwd, "node_modules")
  mr common.port, (s) ->
    server = s
    t.pass "ok"
    t.end()
    return

  return

test "npm cache - install from fork", (t) ->
  
  # Install from a tarball that thinks it is underscore@1.5.1
  # (but is actually a fork)
  forkPath = path.resolve(__dirname, "cache-shasum-fork", "underscore-1.5.1.tgz")
  common.npm [
    "install"
    forkPath
  ],
    cwd: cwd
    env:
      npm_config_cache: cache
      npm_config_registry: common.registry
      npm_config_loglevel: "silent"
  , (err, code, stdout, stderr) ->
    t.ifErr err, "install finished without error"
    t.notOk stderr, "Should not get data on stderr: " + stderr
    t.equal code, 0, "install finished successfully"
    t.equal stdout, "underscore@1.5.1 node_modules/underscore\n"
    index = fs.readFileSync(path.join(cwd, "node_modules", "underscore", "index.js"), "utf8")
    t.equal index, "console.log(\"This is the fork\");\n\n"
    t.end()
    return

  return

test "npm cache - install from origin", (t) ->
  
  # Now install the real 1.5.1.
  rimraf.sync path.join(cwd, "node_modules")
  mkdirp.sync path.join(cwd, "node_modules")
  common.npm [
    "install"
    "underscore"
  ],
    cwd: cwd
    env:
      npm_config_cache: cache
      npm_config_registry: common.registry
      npm_config_loglevel: "silent"
  , (err, code, stdout, stderr) ->
    t.ifErr err, "install finished without error"
    t.equal code, 0, "install finished successfully"
    t.notOk stderr, "Should not get data on stderr: " + stderr
    t.equal stdout, "underscore@1.5.1 node_modules/underscore\n"
    index = fs.readFileSync(path.join(cwd, "node_modules", "underscore", "index.js"), "utf8")
    t.equal index, "module.exports = require('./underscore');\n"
    t.end()
    return

  return

test "cleanup", (t) ->
  server.close()
  rimraf.sync cache
  rimraf.sync cwd
  t.end()
  return

