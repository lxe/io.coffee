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
open = ->
  openCount++
  fs._open.apply fs, arguments
openSync = ->
  openCount++
  fs._openSync.apply fs, arguments
close = ->
  openCount--
  fs._close.apply fs, arguments
closeSync = ->
  openCount--
  fs._closeSync.apply fs, arguments
common = require("../common")
assert = require("assert")
path = require("path")
fs = require("fs")
got_error = false
success_count = 0
mode_async = undefined
mode_sync = undefined
is_windows = process.platform is "win32"
fs._open = fs.open
fs._openSync = fs.openSync
fs.open = open
fs.openSync = openSync
fs._close = fs.close
fs._closeSync = fs.closeSync
fs.close = close
fs.closeSync = closeSync
openCount = 0

# On Windows chmod is only able to manipulate read-only bit
if is_windows
  mode_async = 0400 # read-only
  mode_sync = 0600 # read-write
else
  mode_async = 0777
  mode_sync = 0644
file1 = path.join(common.fixturesDir, "a.js")
file2 = path.join(common.fixturesDir, "a1.js")
fs.chmod file1, mode_async.toString(8), (err) ->
  if err
    got_error = true
  else
    console.log fs.statSync(file1).mode
    if is_windows
      assert.ok (fs.statSync(file1).mode & 0777) & mode_async
    else
      assert.equal mode_async, fs.statSync(file1).mode & 0777
    fs.chmodSync file1, mode_sync
    if is_windows
      assert.ok (fs.statSync(file1).mode & 0777) & mode_sync
    else
      assert.equal mode_sync, fs.statSync(file1).mode & 0777
    success_count++
  return

fs.open file2, "a", (err, fd) ->
  if err
    got_error = true
    console.error err.stack
    return
  fs.fchmod fd, mode_async.toString(8), (err) ->
    if err
      got_error = true
    else
      console.log fs.fstatSync(fd).mode
      if is_windows
        assert.ok (fs.fstatSync(fd).mode & 0777) & mode_async
      else
        assert.equal mode_async, fs.fstatSync(fd).mode & 0777
      fs.fchmodSync fd, mode_sync
      if is_windows
        assert.ok (fs.fstatSync(fd).mode & 0777) & mode_sync
      else
        assert.equal mode_sync, fs.fstatSync(fd).mode & 0777
      success_count++
      fs.close fd
    return

  return


# lchmod
if fs.lchmod
  link = path.join(common.tmpDir, "symbolic-link")
  try
    fs.unlinkSync link
  fs.symlinkSync file2, link
  fs.lchmod link, mode_async, (err) ->
    if err
      got_error = true
    else
      console.log fs.lstatSync(link).mode
      assert.equal mode_async, fs.lstatSync(link).mode & 0777
      fs.lchmodSync link, mode_sync
      assert.equal mode_sync, fs.lstatSync(link).mode & 0777
      success_count++
    return

else
  success_count++
process.on "exit", ->
  assert.equal 3, success_count
  assert.equal 0, openCount
  assert.equal false, got_error
  return

