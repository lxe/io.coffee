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

# truncateSync

# ftruncateSync

# async tests
testTruncate = (cb) ->
  fs.writeFile filename, data, (er) ->
    return cb(er)  if er
    fs.stat filename, (er, stat) ->
      return cb(er)  if er
      assert.equal stat.size, 1024 * 16
      fs.truncate filename, 1024, (er) ->
        return cb(er)  if er
        fs.stat filename, (er, stat) ->
          return cb(er)  if er
          assert.equal stat.size, 1024
          fs.truncate filename, (er) ->
            return cb(er)  if er
            fs.stat filename, (er, stat) ->
              return cb(er)  if er
              assert.equal stat.size, 0
              cb()
              return

            return

          return

        return

      return

    return

  return
testFtruncate = (cb) ->
  fs.writeFile filename, data, (er) ->
    return cb(er)  if er
    fs.stat filename, (er, stat) ->
      return cb(er)  if er
      assert.equal stat.size, 1024 * 16
      fs.open filename, "w", (er, fd) ->
        return cb(er)  if er
        fs.ftruncate fd, 1024, (er) ->
          return cb(er)  if er
          fs.stat filename, (er, stat) ->
            return cb(er)  if er
            assert.equal stat.size, 1024
            fs.ftruncate fd, (er) ->
              return cb(er)  if er
              fs.stat filename, (er, stat) ->
                return cb(er)  if er
                assert.equal stat.size, 0
                fs.close fd, cb
                return

              return

            return

          return

        return

      return

    return

  return
common = require("../common")
assert = require("assert")
path = require("path")
fs = require("fs")
tmp = common.tmpDir
filename = path.resolve(tmp, "truncate-file.txt")
data = new Buffer(1024 * 16)
data.fill "x"
stat = undefined
fs.writeFileSync filename, data
stat = fs.statSync(filename)
assert.equal stat.size, 1024 * 16
fs.truncateSync filename, 1024
stat = fs.statSync(filename)
assert.equal stat.size, 1024
fs.truncateSync filename
stat = fs.statSync(filename)
assert.equal stat.size, 0
fs.writeFileSync filename, data
fd = fs.openSync(filename, "r+")
stat = fs.statSync(filename)
assert.equal stat.size, 1024 * 16
fs.ftruncateSync fd, 1024
stat = fs.statSync(filename)
assert.equal stat.size, 1024
fs.ftruncateSync fd
stat = fs.statSync(filename)
assert.equal stat.size, 0
fs.closeSync fd
success = 0
testTruncate (er) ->
  throw er  if er
  success++
  testFtruncate (er) ->
    throw er  if er
    success++
    return

  return

process.on "exit", ->
  assert.equal success, 2
  console.log "ok"
  return

