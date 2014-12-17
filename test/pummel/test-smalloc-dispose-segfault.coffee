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
smalloc = process.binding("smalloc")
alloc = smalloc.alloc
dispose = smalloc.dispose

# child
if process.argv[2] is "child"
  
  # test that disposing an allocation won't cause the MakeWeakCallback to try
  # and free invalid memory
  i = 0

  while i < 1e4
    dispose alloc({}, 5)
    gc()  if i % 10 is 0
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
    console.log "dispose didn't segfault"
    return

