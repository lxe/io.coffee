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
completed = 0
expected_tests = 4

# test creating and reading symbolic link
linkData = path.join(common.fixturesDir, "cycles/")
linkPath = path.join(common.tmpDir, "cycles_link")

# Delete previously created link
try
  fs.unlinkSync linkPath
console.log "linkData: " + linkData
console.log "linkPath: " + linkPath
fs.symlink linkData, linkPath, "junction", (err) ->
  throw err  if err
  completed++
  fs.lstat linkPath, (err, stats) ->
    throw err  if err
    assert.ok stats.isSymbolicLink()
    completed++
    fs.readlink linkPath, (err, destination) ->
      throw err  if err
      assert.equal destination, linkData
      completed++
      fs.unlink linkPath, (err) ->
        throw err  if err
        assert not fs.existsSync(linkPath)
        assert fs.existsSync(linkData)
        completed++
        return

      return

    return

  return

process.on "exit", ->
  assert.equal completed, expected_tests
  return

