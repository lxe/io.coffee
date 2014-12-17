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
dirname = path.dirname(__filename)
d = path.join(common.tmpDir, "dir")
mkdir_error = false
rmdir_error = false
fs.mkdir d, 0666, (err) ->
  if err
    console.log "mkdir error: " + err.message
    mkdir_error = true
  else
    fs.mkdir d, 0666, (err) ->
      console.log "expect EEXIST error: ", err
      assert.ok err.message.match(/^EEXIST/), "got EEXIST message"
      assert.equal err.code, "EEXIST", "got EEXIST code"
      assert.equal err.path, d, "got proper path for EEXIST"
      console.log "mkdir okay!"
      fs.rmdir d, (err) ->
        if err
          console.log "rmdir error: " + err.message
          rmdir_error = true
        else
          console.log "rmdir okay!"
        return

      return

  return

process.on "exit", ->
  assert.equal false, mkdir_error
  assert.equal false, rmdir_error
  console.log "exit"
  return

