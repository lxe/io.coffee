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
vm = require("vm")
assert.throws (->
  vm.runInDebugContext "*"
  return
), /SyntaxError/
assert.throws (->
  vm.runInDebugContext toString: assert.fail
  return
), /AssertionError/
assert.throws (->
  vm.runInDebugContext "throw URIError(\"BAM\")"
  return
), /URIError/
assert.throws (->
  vm.runInDebugContext "(function(f) { f(f) })(function(f) { f(f) })"
  return
), /RangeError/
assert.equal typeof (vm.runInDebugContext("this")), "object"
assert.equal typeof (vm.runInDebugContext("Debug")), "object"
assert.strictEqual vm.runInDebugContext(), `undefined`
assert.strictEqual vm.runInDebugContext(0), 0
assert.strictEqual vm.runInDebugContext(null), null
assert.strictEqual vm.runInDebugContext(`undefined`), `undefined`
