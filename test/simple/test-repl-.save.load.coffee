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

# A stream to push an array into a REPL
ArrayStream = ->
  @run = (data) ->
    self = this
    data.forEach (line) ->
      self.emit "data", line + "\n"
      return

    return

  return
assert = require("assert")
util = require("util")
join = require("path").join
fs = require("fs")
common = require("../common")
repl = require("repl")
util.inherits ArrayStream, require("stream").Stream
ArrayStream::readable = true
ArrayStream::writable = true
ArrayStream::resume = ->

ArrayStream::write = ->

works = [
  ["inner.one"]
  "inner.o"
]
putIn = new ArrayStream()
testMe = repl.start("", putIn)
testFile = [
  "var top = function () {"
  "var inner = {one:1};"
]
saveFileName = join(common.tmpDir, "test.save.js")

# input some data
putIn.run testFile

# save it to a file
putIn.run [".save " + saveFileName]

# the file should have what I wrote
assert.equal fs.readFileSync(saveFileName, "utf8"), testFile.join("\n") + "\n"

# make sure that the REPL data is "correct"
# so when I load it back I know I'm good
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, works
  return


# clear the REPL
putIn.run [".clear"]

# Load the file back in
putIn.run [".load " + saveFileName]

# make sure that the REPL data is "correct"
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, works
  return


# clear the REPL
putIn.run [".clear"]
loadFile = join(common.tmpDir, "file.does.not.exist")

# should not break
putIn.write = (data) ->
  
  # make sure I get a failed to load message and not some crazy error
  assert.equal data, "Failed to load:" + loadFile + "\n"
  
  # eat me to avoid work
  putIn.write = ->

  return

putIn.run [".load " + loadFile]

#TODO how do I do a failed .save test?
