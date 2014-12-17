common = require("../common")
net = require("net")
assert = require("assert")
c = net.createConnection(common.PORT)
c.on "connect", assert.fail
c.on "error", common.mustCall((e) ->
  assert.equal e.code, "ECONNREFUSED"
  assert.equal e.port, common.PORT
  assert.equal e.address, "127.0.0.1"
  return
)
