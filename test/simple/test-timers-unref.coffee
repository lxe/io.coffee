# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
common = require("../common")
assert = require("assert")
interval_fired = false
timeout_fired = false
unref_interval = false
unref_timer = false
interval = undefined
check_unref = undefined
checks = 0
LONG_TIME = 10 * 1000
SHORT_TIME = 100
setInterval(->
  interval_fired = true
  return
, LONG_TIME).unref()
setTimeout(->
  timeout_fired = true
  return
, LONG_TIME).unref()
interval = setInterval(->
  unref_interval = true
  clearInterval interval
  return
, SHORT_TIME).unref()
setTimeout(->
  unref_timer = true
  return
, SHORT_TIME).unref()
check_unref = setInterval(->
  clearInterval check_unref  if checks > 5 or (unref_interval and unref_timer)
  checks += 1
  return
, 100)

# Should not assert on args.Holder()->InternalFieldCount() > 0. See #4261.
(->
  t = setInterval(->
  , 1)
  process.nextTick t.unref.bind({})
  process.nextTick t.unref.bind(t)
  return
)()
process.on "exit", ->
  assert.strictEqual interval_fired, false, "Interval should not fire"
  assert.strictEqual timeout_fired, false, "Timeout should not fire"
  assert.strictEqual unref_timer, true, "An unrefd timeout should still fire"
  assert.strictEqual unref_interval, true, "An unrefd interval should still fire"
  return

