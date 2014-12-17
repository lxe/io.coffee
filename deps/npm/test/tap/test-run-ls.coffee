common = require("../common-tap.js")
test = require("tap").test
path = require("path")
cwd = path.resolve(__dirname, "..", "..")
testscript = require("../../package.json").scripts.test
tsregexp = testscript.replace(/([\[\.\*\]])/g, "\\$1")
test "default", (t) ->
  common.npm ["run"],
    cwd: cwd
  , (er, code, so) ->
    throw er  if er
    t.notOk code
    t.similar so, new RegExp("\\n  test\\n    " + tsregexp + "\\n")
    t.end()
    return

  return

test "parseable", (t) ->
  common.npm [
    "run"
    "-p"
  ],
    cwd: cwd
  , (er, code, so) ->
    throw er  if er
    t.notOk code
    t.similar so, new RegExp("\\ntest:" + tsregexp + "\\n")
    t.end()
    return

  return

test "parseable", (t) ->
  common.npm [
    "run"
    "--json"
  ],
    cwd: cwd
  , (er, code, so) ->
    throw er  if er
    t.notOk code
    t.equal JSON.parse(so).test, testscript
    t.end()
    return

  return

