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

# Need to hijack fs.open/close to make sure that things
# get closed once they're opened.

# Reset the umask for testing

# On Windows chmod is only able to manipulate read-only bit. Test if creating
# the file in read-only mode works.

# Test writeFileSync

# Test appendFileSync

# Verify that all opened files were closed.

# Removes a file if it exists.
removeFile = (file) ->
  try
    fs.chmodSync file, 0666  if isWindows
    fs.unlinkSync file
  catch err
    throw err  if err and err.code isnt "ENOENT"
  return
openSync = ->
  openCount++
  fs._openSync.apply fs, arguments
closeSync = ->
  openCount--
  fs._closeSync.apply fs, arguments
common = require("../common")
assert = require("assert")
path = require("path")
fs = require("fs")
isWindows = process.platform is "win32"
openCount = 0
mode = undefined
content = undefined
fs._openSync = fs.openSync
fs.openSync = openSync
fs._closeSync = fs.closeSync
fs.closeSync = closeSync
mask = process.umask(0000)
if isWindows
  mode = 0444
else
  mode = 0755
file1 = path.join(common.tmpDir, "testWriteFileSync.txt")
removeFile file1
fs.writeFileSync file1, "123",
  mode: mode

content = fs.readFileSync(file1,
  encoding: "utf8"
)
assert.equal "123", content
assert.equal mode, fs.statSync(file1).mode & 0777
removeFile file1
file2 = path.join(common.tmpDir, "testAppendFileSync.txt")
removeFile file2
fs.appendFileSync file2, "abc",
  mode: mode

content = fs.readFileSync(file2,
  encoding: "utf8"
)
assert.equal "abc", content
assert.equal mode, fs.statSync(file2).mode & mode
removeFile file2
assert.equal 0, openCount
