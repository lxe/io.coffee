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
get_printer = (timeout) ->
  ->
    console.log "Running from setTimeout " + timeout
    done.push timeout
    return
common = require("../common")
assert = require("assert")
i = undefined
N = 30
done = []
process.nextTick ->
  console.log "Running from nextTick"
  done.push "nextTick"
  return

i = 0
while i < N
  setTimeout get_printer(i), i
  i += 1
console.log "Running from main."
process.on "exit", ->
  assert.equal "nextTick", done[0]
  return


# Disabling this test. I don't think we can ensure the order
#  for (i = 0; i < N; i += 1) {
#    assert.equal(i, done[i + 1]);
#  }
#  
