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
cleanup = ->
  try
    fs.unlinkSync filepath
  try
    fs.rmdirSync testsubdir
  return
common = require("../common")
assert = require("assert")
path = require("path")
fs = require("fs")
testDir = common.tmpDir
testsubdir = path.join(testDir, "testsubdir")
filepath = path.join(testsubdir, "watch.txt")
process.on "exit", cleanup
cleanup()
try
  fs.mkdirSync testsubdir, 0700

# Need a grace period, else the mkdirSync() above fires off an event.
setTimeout (->
  watcher = fs.watch(testDir,
    persistent: true
  , assert.fail)
  setTimeout (->
    fs.writeFileSync filepath, "test"
    return
  ), 100
  setTimeout (->
    watcher.close()
    return
  ), 500
  return
), 50
