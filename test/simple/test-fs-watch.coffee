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
expectFilePath = process.platform is "win32" or process.platform is "linux" or process.platform is "darwin"
watchSeenOne = 0
watchSeenTwo = 0
watchSeenThree = 0
testDir = common.tmpDir
filenameOne = "watch.txt"
filepathOne = path.join(testDir, filenameOne)
filenameTwo = "hasOwnProperty"
filepathTwo = filenameTwo
filepathTwoAbs = path.join(testDir, filenameTwo)
filenameThree = "newfile.txt"
testsubdir = path.join(testDir, "testsubdir")
filepathThree = path.join(testsubdir, filenameThree)
process.on "exit", ->
  assert.ok watchSeenOne > 0
  assert.ok watchSeenTwo > 0
  assert.ok watchSeenThree > 0
  return


# Clean up stale files (if any) from previous run.
try
  fs.unlinkSync filepathOne
try
  fs.unlinkSync filepathTwoAbs
try
  fs.unlinkSync filepathThree
try
  fs.rmdirSync testsubdir
fs.writeFileSync filepathOne, "hello"
assert.doesNotThrow ->
  watcher = fs.watch(filepathOne)
  watcher.on "change", (event, filename) ->
    assert.equal "change", event
    assert.equal "watch.txt", filename  if expectFilePath
    watcher.close()
    ++watchSeenOne
    return

  return

setTimeout (->
  fs.writeFileSync filepathOne, "world"
  return
), 10
process.chdir testDir
fs.writeFileSync filepathTwoAbs, "howdy"
assert.doesNotThrow ->
  watcher = fs.watch(filepathTwo, (event, filename) ->
    assert.equal "change", event
    assert.equal "hasOwnProperty", filename  if expectFilePath
    watcher.close()
    ++watchSeenTwo
    return
  )
  return

setTimeout (->
  fs.writeFileSync filepathTwoAbs, "pardner"
  return
), 10
try
  fs.unlinkSync filepathThree
try
  fs.mkdirSync testsubdir, 0700
assert.doesNotThrow ->
  watcher = fs.watch(testsubdir, (event, filename) ->
    renameEv = (if process.platform is "sunos" then "change" else "rename")
    assert.equal renameEv, event
    if expectFilePath
      assert.equal "newfile.txt", filename
    else
      assert.equal null, filename
    watcher.close()
    ++watchSeenThree
    return
  )
  return

setTimeout (->
  fd = fs.openSync(filepathThree, "w")
  fs.closeSync fd
  return
), 10

# https://github.com/joyent/node/issues/2293 - non-persistent watcher should
# not block the event loop
fs.watch __filename,
  persistent: false
, ->
  assert 0
  return


# whitebox test to ensure that wrapped FSEvent is safe
# https://github.com/joyent/node/issues/6690
oldhandle = undefined
assert.throws (->
  w = fs.watch(__filename, (event, filename) ->
  )
  oldhandle = w._handle
  w._handle = close: w._handle.close
  w.close()
  return
), TypeError
oldhandle.close() # clean up
assert.throws (->
  w = fs.watchFile(__filename,
    persistent: false
  , ->
  )
  oldhandle = w._handle
  w._handle = stop: w._handle.stop
  w.stop()
  return
), TypeError
oldhandle.stop() # clean up
