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
fs = require("fs")
got_error = false
success_count = 0
fs.stat ".", (err, stats) ->
  if err
    got_error = true
  else
    console.dir stats
    assert.ok stats.mtime instanceof Date
    success_count++
  assert this is global
  return

fs.stat ".", (err, stats) ->
  assert.ok stats.hasOwnProperty("blksize")
  assert.ok stats.hasOwnProperty("blocks")
  return

fs.lstat ".", (err, stats) ->
  if err
    got_error = true
  else
    console.dir stats
    assert.ok stats.mtime instanceof Date
    success_count++
  assert this is global
  return


# fstat
fs.open ".", "r", `undefined`, (err, fd) ->
  assert.ok not err
  assert.ok fd
  fs.fstat fd, (err, stats) ->
    if err
      got_error = true
    else
      console.dir stats
      assert.ok stats.mtime instanceof Date
      success_count++
      fs.close fd
    assert this is global
    return

  assert this is global
  return


# fstatSync
fs.open ".", "r", `undefined`, (err, fd) ->
  stats = undefined
  try
    stats = fs.fstatSync(fd)
  catch err
    got_error = true
  if stats
    console.dir stats
    assert.ok stats.mtime instanceof Date
    success_count++
  fs.close fd
  return

console.log "stating: " + __filename
fs.stat __filename, (err, s) ->
  if err
    got_error = true
  else
    console.dir s
    success_count++
    console.log "isDirectory: " + JSON.stringify(s.isDirectory())
    assert.equal false, s.isDirectory()
    console.log "isFile: " + JSON.stringify(s.isFile())
    assert.equal true, s.isFile()
    console.log "isSocket: " + JSON.stringify(s.isSocket())
    assert.equal false, s.isSocket()
    console.log "isBlockDevice: " + JSON.stringify(s.isBlockDevice())
    assert.equal false, s.isBlockDevice()
    console.log "isCharacterDevice: " + JSON.stringify(s.isCharacterDevice())
    assert.equal false, s.isCharacterDevice()
    console.log "isFIFO: " + JSON.stringify(s.isFIFO())
    assert.equal false, s.isFIFO()
    console.log "isSymbolicLink: " + JSON.stringify(s.isSymbolicLink())
    assert.equal false, s.isSymbolicLink()
    assert.ok s.mtime instanceof Date
  return

process.on "exit", ->
  assert.equal 5, success_count
  assert.equal false, got_error
  return

