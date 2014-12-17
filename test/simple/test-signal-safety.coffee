common = require("../common.js")
assert = require("assert")
Signal = process.binding("signal_wrap").Signal

# Test Signal `this` safety
# https://github.com/joyent/node/issues/6690
assert.throws (->
  s = new Signal()
  nots = start: s.start
  nots.start 9
  return
), TypeError
