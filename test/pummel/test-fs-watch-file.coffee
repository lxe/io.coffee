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
watchSeenOne = 0
watchSeenTwo = 0
watchSeenThree = 0
watchSeenFour = 0
startDir = process.cwd()
testDir = common.tmpDir
filenameOne = "watch.txt"
filepathOne = path.join(testDir, filenameOne)
filenameTwo = "hasOwnProperty"
filepathTwo = filenameTwo
filepathTwoAbs = path.join(testDir, filenameTwo)
filenameThree = "charm" # because the third time is
filenameFour = "get"
process.on "exit", ->
  fs.unlinkSync filepathOne
  fs.unlinkSync filepathTwoAbs
  fs.unlinkSync filenameThree
  fs.unlinkSync filenameFour
  assert.equal 1, watchSeenOne
  assert.equal 2, watchSeenTwo
  assert.equal 1, watchSeenThree
  assert.equal 1, watchSeenFour
  return

fs.writeFileSync filepathOne, "hello"
assert.throws (->
  fs.watchFile filepathOne
  return
), (e) ->
  e.message is "watchFile requires a listener function"

assert.doesNotThrow ->
  fs.watchFile filepathOne, (curr, prev) ->
    fs.unwatchFile filepathOne
    ++watchSeenOne
    return

  return

setTimeout (->
  fs.writeFileSync filepathOne, "world"
  return
), 1000
process.chdir testDir
fs.writeFileSync filepathTwoAbs, "howdy"
assert.throws (->
  fs.watchFile filepathTwo
  return
), (e) ->
  e.message is "watchFile requires a listener function"

assert.doesNotThrow ->
  a = (curr, prev) ->
    fs.unwatchFile filepathTwo, a
    ++watchSeenTwo
    return
  b = (curr, prev) ->
    fs.unwatchFile filepathTwo, b
    ++watchSeenTwo
    return
  fs.watchFile filepathTwo, a
  fs.watchFile filepathTwo, b
  return

setTimeout (->
  fs.writeFileSync filepathTwoAbs, "pardner"
  return
), 1000
assert.doesNotThrow ->
  a = (curr, prev) ->
    assert.ok 0 # should not run
    return
  b = (curr, prev) ->
    fs.unwatchFile filenameThree, b
    ++watchSeenThree
    return
  fs.watchFile filenameThree, a
  fs.watchFile filenameThree, b
  fs.unwatchFile filenameThree, a
  return

setTimeout (->
  fs.writeFileSync filenameThree, "pardner"
  return
), 1000
setTimeout (->
  fs.writeFileSync filenameFour, "hey"
  return
), 200
setTimeout (->
  fs.writeFileSync filenameFour, "hey"
  return
), 500
assert.doesNotThrow ->
  a = (curr, prev) ->
    ++watchSeenFour
    assert.equal 1, watchSeenFour
    fs.unwatchFile "." + path.sep + filenameFour, a
    return
  fs.watchFile filenameFour, a
  return

