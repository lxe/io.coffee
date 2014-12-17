# Copyright io.js contributors.
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
fs = require("fs")
path = require("path")
doesNotExist = __filename + "__this_should_not_exist"
readOnlyFile = path.join(common.tmpDir, "read_only_file")
removeFile = (file) ->
  try
    fs.unlinkSync file
  return


# Ignore error
createReadOnlyFile = (file) ->
  removeFile file
  fs.writeFileSync file, ""
  fs.chmodSync file, 0444
  return

createReadOnlyFile readOnlyFile
assert typeof fs.F_OK is "number"
assert typeof fs.R_OK is "number"
assert typeof fs.W_OK is "number"
assert typeof fs.X_OK is "number"
fs.access __filename, (err) ->
  assert.strictEqual err, null, "error should not exist"
  return

fs.access __filename, fs.R_OK, (err) ->
  assert.strictEqual err, null, "error should not exist"
  return

fs.access doesNotExist, (err) ->
  assert.notEqual err, null, "error should exist"
  assert.strictEqual err.code, "ENOENT"
  assert.strictEqual err.path, doesNotExist
  return

fs.access readOnlyFile, fs.F_OK | fs.R_OK, (err) ->
  assert.strictEqual err, null, "error should not exist"
  return

fs.access readOnlyFile, fs.W_OK, (err) ->
  assert.notEqual err, null, "error should exist"
  assert.strictEqual err.path, readOnlyFile
  return

assert.throws (->
  fs.access 100, fs.F_OK, (err) ->

  return
), /path must be a string/
assert.throws (->
  fs.access __filename, fs.F_OK
  return
), /callback must be a function/
assert.doesNotThrow ->
  fs.accessSync __filename
  return

assert.doesNotThrow ->
  mode = fs.F_OK | fs.R_OK | fs.W_OK
  fs.accessSync __filename, mode
  return

assert.throws (->
  fs.accessSync doesNotExist
  return
), (err) ->
  err.code is "ENOENT" and err.path is doesNotExist

process.on "exit", ->
  removeFile readOnlyFile
  return

