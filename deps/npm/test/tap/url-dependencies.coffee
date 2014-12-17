tarballWasFetched = (output) ->
  output.indexOf("http fetch GET " + common.registry + "/underscore/-/underscore-1.3.1.tgz") > -1
performInstall = (t, cb) ->
  mr
    port: common.port
    mocks: mockRoutes
  , (s) ->
    opts =
      cwd: pkg
      env:
        npm_config_registry: common.registry
        npm_config_cache_lock_stale: 1000
        npm_config_cache_lock_wait: 1000
        npm_config_loglevel: "http"
        HOME: process.env.HOME
        Path: process.env.PATH
        PATH: process.env.PATH

    common.npm ["install"], opts, (err, code, stdout, stderr) ->
      t.ifError err, "install success"
      t.notOk code, "npm install exited with code 0"
      s.close()
      cb stderr
      return

    return

  return
cleanup = ->
  
  # windows fix for locked files
  process.chdir osenv.tmpdir()
  rimraf.sync path.resolve(pkg, "node_modules")
  return
test = require("tap").test
rimraf = require("rimraf")
path = require("path")
osenv = require("osenv")
mr = require("npm-registry-mock")
pkg = path.resolve(__dirname, "url-dependencies")
common = require("../common-tap")
mockRoutes = get:
  "/underscore/-/underscore-1.3.1.tgz": [200]

test "url-dependencies: download first time", (t) ->
  cleanup()
  performInstall t, (output) ->
    unless tarballWasFetched(output)
      t.fail "Tarball was not fetched"
    else
      t.pass "Tarball was fetched"
    t.end()
    return

  return

test "url-dependencies: do not download subsequent times", (t) ->
  cleanup()
  performInstall t, ->
    performInstall t, (output) ->
      if tarballWasFetched(output)
        t.fail "Tarball was fetched second time around"
      else
        t.pass "Tarball was not fetched"
      t.end()
      return

    return

  return

