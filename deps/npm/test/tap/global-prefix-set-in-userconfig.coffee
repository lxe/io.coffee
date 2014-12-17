common = require("../common-tap.js")
test = require("tap").test
rimraf = require("rimraf")
prefix = __filename.replace(/\.js$/, "")
rcfile = __filename.replace(/\.js$/, ".npmrc")
fs = require("fs")
conf = "prefix = " + prefix + "\n"
test "setup", (t) ->
  rimraf.sync prefix
  fs.writeFileSync rcfile, conf
  t.pass "ready"
  t.end()
  return

test "run command", (t) ->
  args = [
    "prefix"
    "-g"
    "--userconfig=" + rcfile
  ]
  common.npm args,
    env: {}
  , (er, code, so) ->
    throw er  if er
    t.notOk code, "npm prefix exited with code 0"
    t.equal so.trim(), prefix
    t.end()
    return

  return

test "made dir", (t) ->
  t.ok fs.statSync(prefix).isDirectory()
  t.end()
  return

test "cleanup", (t) ->
  rimraf.sync prefix
  rimraf.sync rcfile
  t.pass "clean"
  t.end()
  return

