
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
events = require("events")
EventEmitter = require("events").EventEmitter
assert = require("assert")
e = new EventEmitter
fl = undefined # foo listeners
fl = e.listeners("foo")
assert Array.isArray(fl)
assert fl.length is 0
assert.deepEqual e._events, {}
e.on "foo", assert.fail
fl = e.listeners("foo")
assert e._events.foo is assert.fail
assert Array.isArray(fl)
assert fl.length is 1
assert fl[0] is assert.fail
e.listeners "bar"
assert not e._events.hasOwnProperty("bar")
e.on "foo", assert.ok
fl = e.listeners("foo")
assert Array.isArray(e._events.foo)
assert e._events.foo.length is 2
assert e._events.foo[0] is assert.fail
assert e._events.foo[1] is assert.ok
assert Array.isArray(fl)
assert fl.length is 2
assert fl[0] is assert.fail
assert fl[1] is assert.ok
console.log "ok"
