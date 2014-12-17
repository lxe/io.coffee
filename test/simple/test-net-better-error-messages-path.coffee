common = require("../common")
net = require("net")
assert = require("assert")
fp = "/tmp/fadagagsdfgsdf"
c = net.connect(fp)
c.on "connect", assert.fail
c.on "error", common.mustCall((e) ->
  assert.equal e.code, "ENOENT"
  assert.equal e.message, "connect ENOENT " + fp
  return
)
