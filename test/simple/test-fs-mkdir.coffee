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
unlink = (pathname) ->
  try
    fs.rmdirSync pathname
  return
common = require("../common")
assert = require("assert")
fs = require("fs")
(->
  ncalls = 0
  pathname = common.tmpDir + "/test1"
  unlink pathname
  fs.mkdir pathname, (err) ->
    assert.equal err, null
    assert.equal fs.existsSync(pathname), true
    ncalls++
    return

  process.on "exit", ->
    unlink pathname
    assert.equal ncalls, 1
    return

  return
)()
(->
  ncalls = 0
  pathname = common.tmpDir + "/test2"
  unlink pathname
  fs.mkdir pathname, 511, (err) -> #=0777
    assert.equal err, null
    assert.equal fs.existsSync(pathname), true
    ncalls++
    return

  process.on "exit", ->
    unlink pathname
    assert.equal ncalls, 1
    return

  return
)()
(->
  pathname = common.tmpDir + "/test3"
  unlink pathname
  fs.mkdirSync pathname
  exists = fs.existsSync(pathname)
  unlink pathname
  assert.equal exists, true
  return
)()

# Keep the event loop alive so the async mkdir() requests
# have a chance to run (since they don't ref the event loop).
process.nextTick ->

