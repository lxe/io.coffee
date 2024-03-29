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
listener1 = ->
  console.log "listener1"
  count++
  return
listener2 = ->
  console.log "listener2"
  count++
  return
listener3 = ->
  console.log "listener3"
  count++
  return
remove1 = ->
  assert 0
  return
remove2 = ->
  assert 0
  return
common = require("../common")
assert = require("assert")
events = require("events")
count = 0
e1 = new events.EventEmitter()
e1.on "hello", listener1
e1.on "removeListener", common.mustCall((name, cb) ->
  assert.equal name, "hello"
  assert.equal cb, listener1
  return
)
e1.removeListener "hello", listener1
assert.deepEqual [], e1.listeners("hello")
e2 = new events.EventEmitter()
e2.on "hello", listener1
e2.on "removeListener", assert.fail
e2.removeListener "hello", listener2
assert.deepEqual [listener1], e2.listeners("hello")
e3 = new events.EventEmitter()
e3.on "hello", listener1
e3.on "hello", listener2
e3.on "removeListener", common.mustCall((name, cb) ->
  assert.equal name, "hello"
  assert.equal cb, listener1
  return
)
e3.removeListener "hello", listener1
assert.deepEqual [listener2], e3.listeners("hello")
e4 = new events.EventEmitter()
e4.on "removeListener", common.mustCall((name, cb) ->
  return  if cb isnt remove1
  @removeListener "quux", remove2
  @emit "quux"
  return
, 2)
e4.on "quux", remove1
e4.on "quux", remove2
e4.removeListener "quux", remove1
