hasOnlyAscii = (s) ->
  /^[\000-\177]*$/.test s
common = require("../common-tap.js")
test = require("tap").test
mr = require("npm-registry-mock")
path = require("path")
pkg = path.resolve(__dirname, "install-cli")
EXEC_OPTS = cwd: pkg
test "does not use unicode with --unicode false", (t) ->
  t.plan 5
  mr common.port, (s) ->
    common.npm [
      "install"
      "--unicode"
      "false"
      "read"
    ], EXEC_OPTS, (err, code, stdout) ->
      t.ifError err, "install package read without unicode success"
      t.notOk code, "npm install exited with code 0"
      t.ifError err
      t.ok stdout, stdout.length
      t.ok hasOnlyAscii(stdout)
      s.close()
      return

    return

  return

test "cleanup", (t) ->
  mr common.port, (s) ->
    common.npm [
      "uninstall"
      "read"
    ], EXEC_OPTS, (err, code) ->
      t.ifError err, "uninstall read package success"
      t.notOk code, "npm uninstall exited with code 0"
      s.close()
      return

    return

  t.end()
  return

