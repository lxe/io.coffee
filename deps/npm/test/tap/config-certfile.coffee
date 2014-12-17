require "./00-config-setup.js"
path = require("path")
fs = require("fs")
test = require("tap").test
npmconf = require("../../lib/config/core.js")
test "cafile loads as ca", (t) ->
  cafile = path.join(__dirname, "..", "fixtures", "config", "multi-ca")
  npmconf.load
    cafile: cafile
  , (er, conf) ->
    throw er  if er
    t.same conf.get("cafile"), cafile
    t.same conf.get("ca").join("\n"), fs.readFileSync(cafile, "utf8").trim()
    t.end()
    return

  return

