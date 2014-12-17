common = require("../common-tap.js")
test = require("tap").test
test "cache add", (t) ->
  common.npm [
    "cache"
    "add"
    "superfoo"
  ], {}, (er, c, so, se) ->
    throw er  if er
    t.ok c, "got non-zero exit code"
    t.equal so, "", "nothing printed to stdout"
    t.similar se, /404 Not Found: superfoo/, "got expected error"
    t.end()
    return

  return

