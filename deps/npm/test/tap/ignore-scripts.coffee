
# ignore-scripts/package.json has scripts that always exit with non-zero error
# codes. The "install" script is omitted so that npm tries to run node-gyp,
# which should also fail.
createChild = (args, cb) ->
  env =
    HOME: process.env.HOME
    Path: process.env.PATH
    PATH: process.env.PATH
    npm_config_loglevel: "silent"

  env.npm_config_cache = "%APPDATA%\\npm-cache"  if process.platform is "win32"
  common.npm args,
    cwd: pkg
    stdio: "inherit"
    env: env
  , cb
common = require("../common-tap")
test = require("tap").test
path = require("path")
pkg = path.resolve(__dirname, "ignore-scripts")
test "ignore-scripts: install using the option", (t) ->
  createChild [
    "install"
    "--ignore-scripts"
  ], (err, code) ->
    t.ifError err, "install with scripts ignored finished successfully"
    t.equal code, 0, "npm install exited with code"
    t.end()
    return

  return

test "ignore-scripts: install NOT using the option", (t) ->
  createChild ["install"], (err, code) ->
    t.ifError err, "install with scripts successful"
    t.notEqual code, 0, "npm install exited with code"
    t.end()
    return

  return

scripts = [
  "prepublish"
  "publish"
  "postpublish"
  "preinstall"
  "install"
  "postinstall"
  "preuninstall"
  "uninstall"
  "postuninstall"
  "preupdate"
  "update"
  "postupdate"
  "pretest"
  "test"
  "posttest"
  "prestop"
  "stop"
  "poststop"
  "prestart"
  "start"
  "poststart"
  "prerestart"
  "restart"
  "postrestart"
]
scripts.forEach (script) ->
  test "ignore-scripts: run-script " + script + " using the option", (t) ->
    createChild [
      "--ignore-scripts"
      "run-script"
      script
    ], (err, code) ->
      t.ifError err, "run-script " + script + " with ignore-scripts successful"
      t.equal code, 0, "npm run-script exited with code"
      t.end()
      return

    return

  return

scripts.forEach (script) ->
  test "ignore-scripts: run-script " + script + " NOT using the option", (t) ->
    createChild [
      "run-script"
      script
    ], (err, code) ->
      t.ifError err, "run-script " + script + " finished successfully"
      t.notEqual code, 0, "npm run-script exited with code"
      t.end()
      return

    return

  return

