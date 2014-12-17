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
removeTestFile = ->
  try
    fs.unlinkSync filepath
  return
run_test_1 = ->
  file = undefined
  buffer = undefined
  options = undefined
  options = {}
  file = fs.createWriteStream(filepath, options)
  console.log "    (debug: start         ", file.start
  console.log "    (debug: pos           ", file.pos
  file.on "open", (fd) ->
    cb_occurred += "open "
    return

  file.on "close", ->
    cb_occurred += "close "
    console.log "    (debug: bytesWritten  ", file.bytesWritten
    console.log "    (debug: start         ", file.start
    console.log "    (debug: pos           ", file.pos
    assert.strictEqual file.bytesWritten, buffer.length
    fileData = fs.readFileSync(filepath, "utf8")
    console.log "    (debug: file data   ", fileData
    console.log "    (debug: expected    ", fileDataExpected_1
    assert.equal fileData, fileDataExpected_1
    run_test_2()
    return

  file.on "error", (err) ->
    cb_occurred += "error "
    console.log "    (debug: err event ", err
    throw errreturn

  buffer = new Buffer(fileDataInitial)
  file.write buffer
  cb_occurred += "write "
  file.end()
  return
run_test_2 = ->
  file = undefined
  buffer = undefined
  options = undefined
  buffer = new Buffer("123456")
  options =
    start: 10
    flags: "r+"

  file = fs.createWriteStream(filepath, options)
  console.log "    (debug: start         ", file.start
  console.log "    (debug: pos           ", file.pos
  file.on "open", (fd) ->
    cb_occurred += "open "
    return

  file.on "close", ->
    cb_occurred += "close "
    console.log "    (debug: bytesWritten  ", file.bytesWritten
    console.log "    (debug: start         ", file.start
    console.log "    (debug: pos           ", file.pos
    assert.strictEqual file.bytesWritten, buffer.length
    fileData = fs.readFileSync(filepath, "utf8")
    console.log "    (debug: file data   ", fileData
    console.log "    (debug: expected    ", fileDataExpected_2
    assert.equal fileData, fileDataExpected_2
    run_test_3()
    return

  file.on "error", (err) ->
    cb_occurred += "error "
    console.log "    (debug: err event ", err
    throw errreturn

  file.write buffer
  cb_occurred += "write "
  file.end()
  return
run_test_3 = ->
  file = undefined
  buffer = undefined
  options = undefined
  data = "……" # 3 bytes * 2 = 6 bytes in UTF-8
  fileData = undefined
  options =
    start: 10
    flags: "r+"

  file = fs.createWriteStream(filepath, options)
  console.log "    (debug: start         ", file.start
  console.log "    (debug: pos           ", file.pos
  file.on "open", (fd) ->
    cb_occurred += "open "
    return

  file.on "close", ->
    cb_occurred += "close "
    console.log "    (debug: bytesWritten  ", file.bytesWritten
    console.log "    (debug: start         ", file.start
    console.log "    (debug: pos           ", file.pos
    assert.strictEqual file.bytesWritten, data.length * 3
    fileData = fs.readFileSync(filepath, "utf8")
    console.log "    (debug: file data   ", fileData
    console.log "    (debug: expected    ", fileDataExpected_3
    assert.equal fileData, fileDataExpected_3
    run_test_4()
    return

  file.on "error", (err) ->
    cb_occurred += "error "
    console.log "    (debug: err event ", err
    throw errreturn

  file.write data, "utf8"
  cb_occurred += "write "
  file.end()
  return
run_test_4 = ->
  file = undefined
  options = undefined
  options =
    start: -5
    flags: "r+"

  
  #  Error: start must be >= zero
  assert.throws (->
    file = fs.createWriteStream(filepath, options)
    return
  ), /start must be/
  return
common = require("../common")
assert = require("assert")
path = require("path")
fs = require("fs")
util = require("util")
filepath = path.join(common.tmpDir, "write_pos.txt")
cb_expected = "write open close write open close write open close "
cb_occurred = ""
fileDataInitial = "abcdefghijklmnopqrstuvwxyz"
fileDataExpected_1 = "abcdefghijklmnopqrstuvwxyz"
fileDataExpected_2 = "abcdefghij123456qrstuvwxyz"
fileDataExpected_3 = "abcdefghij……qrstuvwxyz"
process.on "exit", ->
  removeTestFile()
  if cb_occurred isnt cb_expected
    console.log "  Test callback events missing or out of order:"
    console.log "    expected: %j", cb_expected
    console.log "    occurred: %j", cb_occurred
    assert.strictEqual cb_occurred, cb_expected, "events missing or out of order: \"" + cb_occurred + "\" !== \"" + cb_expected + "\""
  return

removeTestFile()
run_test_1()
