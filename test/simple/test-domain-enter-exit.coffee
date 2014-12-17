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

# Make sure the domain stack is a stack
names = (array) ->
  array.map((d) ->
    d.name
  ).join ", "
assert = require("assert")
domain = require("domain")
a = domain.create()
a.name = "a"
b = domain.create()
b.name = "b"
c = domain.create()
c.name = "c"
a.enter() # push
assert.deepEqual domain._stack, [a], "a not pushed: " + names(domain._stack)
b.enter() # push
assert.deepEqual domain._stack, [
  a
  b
], "b not pushed: " + names(domain._stack)
c.enter() # push
assert.deepEqual domain._stack, [
  a
  b
  c
], "c not pushed: " + names(domain._stack)
b.exit() # pop
assert.deepEqual domain._stack, [a], "b and c not popped: " + names(domain._stack)
b.enter() # push
assert.deepEqual domain._stack, [
  a
  b
], "b not pushed: " + names(domain._stack)
