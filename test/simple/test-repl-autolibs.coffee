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
test1 = ->
  gotWrite = false
  putIn.write = (data) ->
    gotWrite = true
    if data.length
      
      # inspect output matches repl output
      assert.equal data, util.inspect(require("fs"), null, 2, false) + "\n"
      
      # globally added lib matches required lib
      assert.equal global.fs, require("fs")
      test2()
    return

  assert not gotWrite
  putIn.run ["fs"]
  assert gotWrite
  return
test2 = ->
  gotWrite = false
  putIn.write = (data) ->
    gotWrite = true
    if data.length
      
      # repl response error message
      assert.equal data, "{}\n"
      
      # original value wasn't overwritten
      assert.equal val, global.url
    return

  val = {}
  global.url = val
  assert not gotWrite
  putIn.run ["url"]
  assert gotWrite
  return
assert = require("assert")
util = require("util")
repl = require("repl")
util.inherits ArrayStream, require("stream").Stream
ArrayStream::readable = true
ArrayStream::writable = true
ArrayStream::resume = ->

ArrayStream::write = ->

putIn = new ArrayStream
testMe = repl.start("", putIn, null, true)
test1()
