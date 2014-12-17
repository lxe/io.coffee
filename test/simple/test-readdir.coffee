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
fs = require("fs")
got_error = false
readdirDir = path.join(common.fixturesDir, "readdir")
files = [
  "are"
  "dir"
  "empty"
  "files"
  "for"
  "just"
  "testing.js"
  "these"
]
console.log "readdirSync " + readdirDir
f = fs.readdirSync(readdirDir)
console.dir f
assert.deepEqual files, f.sort()
console.log "readdir " + readdirDir
fs.readdir readdirDir, (err, f) ->
  if err
    console.log "error"
    got_error = true
  else
    console.dir f
    assert.deepEqual files, f.sort()
  return

process.on "exit", ->
  assert.equal false, got_error
  console.log "exit"
  return


# readdir() on file should throw ENOTDIR
# https://github.com/joyent/node/issues/1869
(->
  has_caught = false
  try
    fs.readdirSync __filename
  catch e
    has_caught = true
    assert.equal e.code, "ENOTDIR"
  assert has_caught
  return
)()
(->
  readdir_cb_called = false
  fs.readdir __filename, (e) ->
    readdir_cb_called = true
    assert.equal e.code, "ENOTDIR"
    return

  process.on "exit", ->
    assert readdir_cb_called
    return

  return
)()
