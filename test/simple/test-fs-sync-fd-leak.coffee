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

# ensure that (read|write|append)FileSync() closes the file descriptor
ensureThrows = (cb) ->
  got_exception = false
  close_called = 0
  try
    cb()
  catch e
    assert.equal e.message, "BAM"
    got_exception = true
  assert.equal close_called, 1
  assert.equal got_exception, true
  return
common = require("../common")
assert = require("assert")
fs = require("fs")
fs.openSync = ->
  42

fs.closeSync = (fd) ->
  assert.equal fd, 42
  close_called++
  return

fs.readSync = ->
  throw new Error("BAM")return

fs.writeSync = ->
  throw new Error("BAM")return

fs.fstatSync = ->
  throw new Error("BAM")return

ensureThrows ->
  fs.readFileSync "dummy"
  return

ensureThrows ->
  fs.writeFileSync "dummy", "xxx"
  return

ensureThrows ->
  fs.appendFileSync "dummy", "xxx"
  return

close_called = 0
