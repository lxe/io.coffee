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
fs = require("fs")
stream = fs.createWriteStream(common.tmpDir + "/out",
  highWaterMark: 10
)
err = new Error("BAM")
write = fs.write
writeCalls = 0
fs.write = ->
  switch writeCalls++
    when 0
      console.error "first write"
      
      # first time is ok.
      write.apply fs, arguments
    when 1
      
      # then it breaks
      console.error "second write"
      cb = arguments[arguments.length - 1]
      process.nextTick ->
        cb err
        return

    else
      
      # and should not be called again!
      throw new Error("BOOM!")
  return

fs.close = common.mustCall((fd_, cb) ->
  console.error "fs.close", fd_, stream.fd
  assert.equal fd_, stream.fd
  process.nextTick cb
  return
)
stream.on "error", common.mustCall((err_) ->
  console.error "error handler"
  assert.equal stream.fd, null
  assert.equal err_, err
  return
)
stream.write new Buffer(256), ->
  console.error "first cb"
  stream.write new Buffer(256), common.mustCall((err_) ->
    console.error "second cb"
    assert.equal err_, err
    return
  )
  return

