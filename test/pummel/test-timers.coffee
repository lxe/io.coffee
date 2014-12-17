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
# why is does this need to be so big?

# check that these don't blow up.

# this timer shouldn't execute

# Single param:

# Multiple param

# setInterval(cb, 0) should be called multiple times.

# we should be able to clearTimeout multiple times without breakage.
t = ->
  expectedTimeouts--
  return
common = require("../common")
assert = require("assert")
WINDOW = 200
interval_count = 0
setTimeout_called = false
clearTimeout null
clearInterval null
assert.equal true, setTimeout instanceof Function
starttime = new Date
setTimeout (->
  endtime = new Date
  diff = endtime - starttime
  assert.ok diff > 0
  console.error "diff: " + diff
  assert.equal true, 1000 - WINDOW < diff and diff < 1000 + WINDOW
  setTimeout_called = true
  return
), 1000
id = setTimeout(->
  assert.equal true, false
  return
, 500)
clearTimeout id
setInterval (->
  interval_count += 1
  endtime = new Date
  diff = endtime - starttime
  assert.ok diff > 0
  console.error "diff: " + diff
  t = interval_count * 1000
  assert.equal true, t - WINDOW < diff and diff < t + WINDOW
  assert.equal true, interval_count <= 3
  clearInterval this  if interval_count is 3
  return
), 1000
setTimeout ((param) ->
  assert.equal "test param", param
  return
), 1000, "test param"
interval_count2 = 0
setInterval ((param) ->
  ++interval_count2
  assert.equal "test param", param
  clearInterval this  if interval_count2 is 3
  return
), 1000, "test param"
setTimeout ((param1, param2) ->
  assert.equal "param1", param1
  assert.equal "param2", param2
  return
), 1000, "param1", "param2"
interval_count3 = 0
setInterval ((param1, param2) ->
  ++interval_count3
  assert.equal "param1", param1
  assert.equal "param2", param2
  clearInterval this  if interval_count3 is 3
  return
), 1000, "param1", "param2"
count4 = 0
interval4 = setInterval(->
  clearInterval interval4  if ++count4 > 10
  return
, 0)
expectedTimeouts = 3
w = setTimeout(t, 200)
x = setTimeout(t, 200)
y = setTimeout(t, 200)
clearTimeout y
z = setTimeout(t, 200)
clearTimeout y
process.on "exit", ->
  assert.equal true, setTimeout_called
  assert.equal 3, interval_count
  assert.equal 11, count4
  assert.equal 0, expectedTimeouts, "clearTimeout cleared too many timeouts"
  return

