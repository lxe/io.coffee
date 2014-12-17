test = require("tap").test
npmconf = require("../../lib/config/core.js")
common = require("./00-config-setup.js")
test "with malformed", (t) ->
  npmconf.load {}, common.malformed, (er, conf) ->
    t.ok er, "Expected parse error"
    throw er  unless er and /Failed parsing JSON config key email/.test(er.message)
    t.end()
    return

  return

