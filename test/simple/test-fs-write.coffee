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
path = require("path")
Buffer = require("buffer").Buffer
fs = require("fs")
fn = path.join(common.tmpDir, "write.txt")
fn2 = path.join(common.tmpDir, "write2.txt")
expected = "ümlaut."
constants = require("constants")
found = undefined
found2 = undefined
fs.open fn, "w", 0644, (err, fd) ->
  throw err  if err
  console.log "open done"
  fs.write fd, "", 0, "utf8", (err, written) ->
    assert.equal 0, written
    return

  fs.write fd, expected, 0, "utf8", (err, written) ->
    console.log "write done"
    throw err  if err
    assert.equal Buffer.byteLength(expected), written
    fs.closeSync fd
    found = fs.readFileSync(fn, "utf8")
    console.log "expected: \"%s\"", expected
    console.log "found: \"%s\"", found
    fs.unlinkSync fn
    return

  return

fs.open fn2, constants.O_CREAT | constants.O_WRONLY | constants.O_TRUNC, 0644, (err, fd) ->
  throw err  if err
  console.log "open done"
  fs.write fd, "", 0, "utf8", (err, written) ->
    assert.equal 0, written
    return

  fs.write fd, expected, 0, "utf8", (err, written) ->
    console.log "write done"
    throw err  if err
    assert.equal Buffer.byteLength(expected), written
    fs.closeSync fd
    found2 = fs.readFileSync(fn2, "utf8")
    console.log "expected: \"%s\"", expected
    console.log "found: \"%s\"", found2
    fs.unlinkSync fn2
    return

  return

process.on "exit", ->
  assert.equal expected, found
  assert.equal expected, found2
  return

