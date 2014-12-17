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
emptyFile = path.join(common.fixturesDir, "empty.txt")
fs.open emptyFile, "r", (error, fd) ->
  assert.ifError error
  read = fs.createReadStream(emptyFile,
    fd: fd
  )
  read.once "data", ->
    throw new Error("data event should not emit")return

  readEmit = false
  read.once "end", ->
    readEmit = true
    console.error "end event 1"
    return

  setTimeout (->
    assert.equal readEmit, true
    return
  ), 50
  return

fs.open emptyFile, "r", (error, fd) ->
  assert.ifError error
  read = fs.createReadStream(emptyFile,
    fd: fd
  )
  read.pause()
  read.once "data", ->
    throw new Error("data event should not emit")return

  readEmit = false
  read.once "end", ->
    readEmit = true
    console.error "end event 2"
    return

  setTimeout (->
    assert.equal readEmit, false
    return
  ), 50
  return

