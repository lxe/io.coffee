util = require("util")
test = require("tap").test
npmconf = require("../../lib/config/core.js")
common = require("./00-config-setup.js")
cli = tag: "v2.x"
log = require("npmlog")
test "tag cannot be a SemVer", (t) ->
  messages = []
  log.warn = (m) ->
    messages.push m + " " + util.format.apply(util, [].slice.call(arguments, 1))
    return

  expect = [
    "invalid config tag=\"v2.x\""
    "invalid config Tag must not be a SemVer range"
  ]
  npmconf.load cli, common.builtin, (er, conf) ->
    throw er  if er
    t.equal conf.get("tag"), "latest"
    t.same messages, expect
    t.end()
    return

  return

