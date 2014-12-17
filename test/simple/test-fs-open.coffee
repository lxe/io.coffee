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
constants = require("constants")
common = require("../common")
assert = require("assert")
fs = require("fs")
caughtException = false
try
  
  # should throw ENOENT, not EBADF
  # see https://github.com/joyent/node/pull/1228
  fs.openSync "/path/to/file/that/does/not/exist", "r"
catch e
  assert.equal e.code, "ENOENT"
  caughtException = true
assert.ok caughtException
openFd = undefined
fs.open __filename, "r", (err, fd) ->
  throw err  if err
  openFd = fd
  return

openFd2 = undefined
fs.open __filename, "rs", (err, fd) ->
  throw err  if err
  openFd2 = fd
  return

process.on "exit", ->
  assert.ok openFd
  assert.ok openFd2
  return

