common = require("../common")
assert = require("assert")
net = require("net")
fp = "/blah/fadfa"
server = net.createServer(assert.fail)
server.listen fp, assert.fail
server.on "error", common.mustCall((e) ->
  assert.equal e.address, fp
  return
)
