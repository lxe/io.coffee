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

# swallow
createFile = ->
  console.log "creating file"
  fs.writeFileSync FILENAME, "test"
  setTimeout touchFile, TIMEOUT
  return
touchFile = ->
  console.log "touch file"
  fs.writeFileSync FILENAME, "test"
  setTimeout removeFile, TIMEOUT
  return
removeFile = ->
  console.log "remove file"
  fs.unlinkSync FILENAME
  return
common = require("../common")
assert = require("assert")
path = require("path")
fs = require("fs")
FILENAME = path.join(common.tmpDir, "watch-me")
TIMEOUT = 1300
nevents = 0
try
  fs.unlinkSync FILENAME
fs.watchFile FILENAME,
  interval: TIMEOUT - 250
, (curr, prev) ->
  console.log [
    curr
    prev
  ]
  switch ++nevents
    when 1
      assert.equal fs.existsSync(FILENAME), false
    when 2, 3
      assert.equal fs.existsSync(FILENAME), true
    when 4
      assert.equal fs.existsSync(FILENAME), false
      fs.unwatchFile FILENAME
    else
      assert 0
  return

process.on "exit", ->
  assert.equal nevents, 4
  return

setTimeout createFile, TIMEOUT
