common = require("../common")
net = require("net")
assert = require("assert")
c = net.createConnection(common.PORT, "blah.blah")
c.on "connect", assert.fail
c.on "error", common.mustCall((e) ->
  assert.equal e.code, "ENOTFOUND"
  assert.equal e.port, common.PORT
  assert.equal e.hostname, "blah.blah"
  return
)
