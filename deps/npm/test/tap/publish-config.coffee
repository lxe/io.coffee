common = require("../common-tap.js")
test = require("tap").test
fs = require("fs")
osenv = require("osenv")
pkg = process.env.npm_config_tmp or "/tmp"
pkg += "/npm-test-publish-config"
require("mkdirp").sync pkg
fs.writeFileSync pkg + "/package.json", JSON.stringify(
  name: "npm-test-publish-config"
  version: "1.2.3"
  publishConfig:
    registry: common.registry
), "utf8"
fs.writeFileSync pkg + "/fixture_npmrc", "//localhost:1337/:email = fancy@feast.net\n" + "//localhost:1337/:username = fancy\n" + "//localhost:1337/:_password = " + new Buffer("feast").toString("base64") + "\n" + "registry = http://localhost:1337/"
test (t) ->
  child = undefined
  require("http").createServer((req, res) ->
    t.pass "got request on the fakey fake registry"
    t.end()
    @close()
    res.statusCode = 500
    res.end JSON.stringify(error: "sshhh. naptime nao. \\^O^/ <(YAWWWWN!)")
    child.kill()
    return
  ).listen common.port, ->
    t.pass "server is listening"
    
    # don't much care about listening to the child's results
    # just wanna make sure it hits the server we just set up.
    #
    # there are plenty of other tests to verify that publish
    # itself functions normally.
    #
    # Make sure that we don't sit around waiting for lock files
    child = common.npm([
      "publish"
      "--userconfig=" + pkg + "/fixture_npmrc"
    ],
      cwd: pkg
      stdio: "inherit"
      env:
        npm_config_cache_lock_stale: 1000
        npm_config_cache_lock_wait: 1000
        HOME: process.env.HOME
        Path: process.env.PATH
        PATH: process.env.PATH
        USERPROFILE: osenv.home()
    , (err, code) ->
      t.ifError err, "publish command finished successfully"
      t.notOk code, "npm install exited with code 0"
      return
    )
    return

  return

