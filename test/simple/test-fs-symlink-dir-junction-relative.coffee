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

# Test creating and resolving relative junction or symbolic link

# Prepare.

# Test fs.symlink()

# Test fs.symlinkSync()
verifyLink = (linkPath) ->
  stats = fs.lstatSync(linkPath)
  assert.ok stats.isSymbolicLink()
  data1 = fs.readFileSync(linkPath + "/x.txt", "ascii")
  data2 = fs.readFileSync(linkTarget + "/x.txt", "ascii")
  assert.strictEqual data1, data2
  
  # Clean up.
  fs.unlinkSync linkPath
  completed++
  return
common = require("../common")
assert = require("assert")
path = require("path")
fs = require("fs")
completed = 0
expected_tests = 2
linkPath1 = path.join(common.tmpDir, "junction1")
linkPath2 = path.join(common.tmpDir, "junction2")
linkTarget = path.join(common.fixturesDir)
linkData = "../fixtures"
try
  fs.mkdirSync common.tmpDir
try
  fs.unlinkSync linkPath1
try
  fs.unlinkSync linkPath2
fs.symlink linkData, linkPath1, "junction", (err) ->
  throw err  if err
  verifyLink linkPath1
  return

fs.symlinkSync linkData, linkPath2, "junction"
verifyLink linkPath2
process.on "exit", ->
  assert.equal completed, expected_tests
  return

