common = require("../common")
assert = require("assert")
net = require("net")
server = net.createServer(assert.fail)
server.listen 1, "1.1.1.1", assert.fail
server.on "error", common.mustCall((e) ->
  assert.equal e.address, "1.1.1.1"
  assert.equal e.port, 1
  assert.equal e.syscall, "listen"
  return
)
