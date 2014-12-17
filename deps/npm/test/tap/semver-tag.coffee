# should not allow tagging with a valid semver range
common = require("../common-tap.js")
test = require("tap").test
test "try to tag with semver range as tag name", (t) ->
  cmd = [
    "tag"
    "zzzz@1.2.3"
    "v2.x"
    "--registry=http://localhost"
  ]
  common.npm cmd,
    stdio: "pipe"
  , (er, code, so, se) ->
    throw er  if er
    t.similar se, /Tag name must not be a valid SemVer range: v2.x\n/
    t.equal code, 1
    t.end()
    return

  return

