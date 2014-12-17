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
dgram = require("dgram")
source = dgram.createSocket("udp4")
target = dgram.createSocket("udp4")
messages = 0
process.on "exit", ->
  assert.equal messages, 2
  return

target.on "message", (buf) ->
  ++messages  if buf.toString() is "abc"
  ++messages  if buf.toString() is "def"
  if messages is 2
    source.close()
    target.close()
  return

target.on "listening", ->
  
  # Second .send() call should not throw a bind error.
  source.send Buffer("abc"), 0, 3, common.PORT, "127.0.0.1"
  source.send Buffer("def"), 0, 3, common.PORT, "127.0.0.1"
  return

target.bind common.PORT
