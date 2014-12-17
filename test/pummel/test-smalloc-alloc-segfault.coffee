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
spawn = require("child_process").spawn
alloc = process.binding("smalloc").alloc

# child
if process.argv[2] is "child"
  
  # test that many allocations won't cause early ones to free prematurely
  # note: if memory frees prematurely then reading out the values will cause
  # it to seg fault
  arr = []
  i = 0

  while i < 1e4
    arr.push alloc({}, 1)
    alloc {}, 1024
    gc()  if i % 10 is 0
    i++
  sum = 0
  i = 0

  while i < 1e4
    sum += arr[i][0]
    arr[i][0] = sum
    i++
else
  
  # test case
  child = spawn(process.execPath, [
    "--expose_gc"
    __filename
    "child"
  ])
  child.on "exit", (code, signal) ->
    assert.equal code, 0, signal
    console.log "alloc didn't segfault"
    return

