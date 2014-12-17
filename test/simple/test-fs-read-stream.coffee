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

# TODO Improved this test. test_ca.pem is too small. A proper test would
# great a large utf8 (with multibyte chars) file and stream it in,
# performing sanity checks throughout.

# GH-535

#assert.equal(fs.readFileSync(fn), fileContent);

# http://www.fileformat.info/info/unicode/char/2026/index.htm

# https://github.com/joyent/node/issues/2320

# pause and then resume immediately.
file7Next = ->
  
  # This will tell us if the fd is usable again or not.
  file7 = fs.createReadStream(null,
    fd: file7.fd
    start: 0
  )
  file7.data = ""
  file7.on "data", (data) ->
    file7.data += data
    return

  file7.on "end", (err) ->
    assert.equal file7.data, "xyz\n"
    return

  return
common = require("../common")
assert = require("assert")
path = require("path")
fs = require("fs")
fn = path.join(common.fixturesDir, "elipses.txt")
rangeFile = path.join(common.fixturesDir, "x.txt")
callbacks =
  open: 0
  end: 0
  close: 0

paused = false
file = fs.ReadStream(fn)
file.on "open", (fd) ->
  file.length = 0
  callbacks.open++
  assert.equal "number", typeof fd
  assert.ok file.readable
  file.pause()
  file.resume()
  file.pause()
  file.resume()
  return

file.on "data", (data) ->
  assert.ok data instanceof Buffer
  assert.ok not paused
  file.length += data.length
  paused = true
  file.pause()
  setTimeout (->
    paused = false
    file.resume()
    return
  ), 10
  return

file.on "end", (chunk) ->
  callbacks.end++
  return

file.on "close", ->
  callbacks.close++
  return

file3 = fs.createReadStream(fn,
  encoding: "utf8"
)
file3.length = 0
file3.on "data", (data) ->
  assert.equal "string", typeof (data)
  file3.length += data.length
  i = 0

  while i < data.length
    assert.equal "…", data[i]
    i++
  return

file3.on "close", ->
  callbacks.close++
  return

process.on "exit", ->
  assert.equal 1, callbacks.open
  assert.equal 1, callbacks.end
  assert.equal 2, callbacks.close
  assert.equal 30000, file.length
  assert.equal 10000, file3.length
  console.error "ok"
  return

file4 = fs.createReadStream(rangeFile,
  bufferSize: 1
  start: 1
  end: 2
)
contentRead = ""
file4.on "data", (data) ->
  contentRead += data.toString("utf-8")
  return

file4.on "end", (data) ->
  assert.equal contentRead, "yz"
  return

file5 = fs.createReadStream(rangeFile,
  bufferSize: 1
  start: 1
)
file5.data = ""
file5.on "data", (data) ->
  file5.data += data.toString("utf-8")
  return

file5.on "end", ->
  assert.equal file5.data, "yz\n"
  return

file6 = fs.createReadStream(rangeFile,
  bufferSize: 1.23
  start: 1
)
file6.data = ""
file6.on "data", (data) ->
  file6.data += data.toString("utf-8")
  return

file6.on "end", ->
  assert.equal file6.data, "yz\n"
  return

assert.throws (->
  fs.createReadStream rangeFile,
    start: 10
    end: 2

  return
), /start must be <= end/
stream = fs.createReadStream(rangeFile,
  start: 0
  end: 0
)
stream.data = ""
stream.on "data", (chunk) ->
  stream.data += chunk
  return

stream.on "end", ->
  assert.equal "x", stream.data
  return

pauseRes = fs.createReadStream(rangeFile)
pauseRes.pause()
pauseRes.resume()
file7 = fs.createReadStream(rangeFile,
  autoClose: false
)
file7.on "data", ->

file7.on "end", ->
  process.nextTick ->
    assert not file7.closed
    assert not file7.destroyed
    file7Next()
    return

  return


# Just to make sure autoClose won't close the stream because of error.
file8 = fs.createReadStream(null,
  fd: 13337
  autoClose: false
)
file8.on "data", ->

file8.on "error", common.mustCall(->
)

# Make sure stream is destroyed when file does not exist.
file9 = fs.createReadStream("/path/to/file/that/does/not/exist")
file9.on "data", ->

file9.on "error", common.mustCall(->
)
process.on "exit", ->
  assert file7.closed
  assert file7.destroyed
  assert not file8.closed
  assert not file8.destroyed
  assert file8.fd
  assert not file9.closed
  assert file9.destroyed
  return

