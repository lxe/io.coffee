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
test = (env, cb) ->
  filename = path.join(common.fixturesDir, "test-fs-readfile-error.js")
  execPath = process.execPath + " " + filename
  options = env: env or {}
  exec execPath, options, (err, stdout, stderr) ->
    assert err
    assert.equal stdout, ""
    assert.notEqual stderr, ""
    cb "" + stderr
    return

  return
common = require("../common")
assert = require("assert")
exec = require("child_process").exec
path = require("path")
callbacks = 0
test
  NODE_DEBUG: ""
, (data) ->
  assert /EISDIR/.test(data)
  assert not /test-fs-readfile-error/.test(data)
  callbacks++
  return

test
  NODE_DEBUG: "fs"
, (data) ->
  assert /EISDIR/.test(data)
  assert /test-fs-readfile-error/.test(data)
  callbacks++
  return

process.on "exit", ->
  assert.equal callbacks, 2
  return

