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
dataExpected = fs.readFileSync(__filename, "utf8")

# sometimes stat returns size=0, but it's a lie.
fs._fstat = fs.fstat
fs._fstatSync = fs.fstatSync
fs.fstat = (fd, cb) ->
  fs._fstat fd, (er, st) ->
    return cb(er)  if er
    st.size = 0
    cb er, st

  return

fs.fstatSync = (fd) ->
  st = fs._fstatSync
  st.size = 0
  st

d = fs.readFileSync(__filename, "utf8")
assert.equal d, dataExpected
called = false
fs.readFile __filename, "utf8", (er, d) ->
  assert.equal d, dataExpected
  called = true
  return

process.on "exit", ->
  assert called
  console.log "ok"
  return

