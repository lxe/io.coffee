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
test = (scheduleMicrotask) ->
  nextTickCalled = false
  expected++
  scheduleMicrotask ->
    process.nextTick ->
      nextTickCalled = true
      return

    setTimeout (->
      assert nextTickCalled
      done++
      return
    ), 0
    return

  return
common = require("../common")
assert = require("assert")
implementations = [
  (fn) ->
    Promise.resolve().then fn
  (fn) ->
    obj = {}
    Object.observe obj, fn
    obj.a = 1
]
expected = 0
done = 0
process.on "exit", ->
  assert.equal done, expected
  return


# first tick case
implementations.forEach test

# tick callback case
setTimeout (->
  implementations.forEach (impl) ->
    process.nextTick test.bind(null, impl)
    return

  return
), 0
