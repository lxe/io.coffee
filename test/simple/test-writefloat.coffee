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

#
# * Tests to verify we're writing floats correctly
# 
test = (clazz) ->
  buffer = new clazz(8)
  buffer.writeFloatBE 1, 0
  buffer.writeFloatLE 1, 4
  ASSERT.equal 0x3f, buffer[0]
  ASSERT.equal 0x80, buffer[1]
  ASSERT.equal 0x00, buffer[2]
  ASSERT.equal 0x00, buffer[3]
  ASSERT.equal 0x00, buffer[4]
  ASSERT.equal 0x00, buffer[5]
  ASSERT.equal 0x80, buffer[6]
  ASSERT.equal 0x3f, buffer[7]
  buffer.writeFloatBE 1 / 3, 0
  buffer.writeFloatLE 1 / 3, 4
  ASSERT.equal 0x3e, buffer[0]
  ASSERT.equal 0xaa, buffer[1]
  ASSERT.equal 0xaa, buffer[2]
  ASSERT.equal 0xab, buffer[3]
  ASSERT.equal 0xab, buffer[4]
  ASSERT.equal 0xaa, buffer[5]
  ASSERT.equal 0xaa, buffer[6]
  ASSERT.equal 0x3e, buffer[7]
  buffer.writeFloatBE 3.4028234663852886e+38, 0
  buffer.writeFloatLE 3.4028234663852886e+38, 4
  ASSERT.equal 0x7f, buffer[0]
  ASSERT.equal 0x7f, buffer[1]
  ASSERT.equal 0xff, buffer[2]
  ASSERT.equal 0xff, buffer[3]
  ASSERT.equal 0xff, buffer[4]
  ASSERT.equal 0xff, buffer[5]
  ASSERT.equal 0x7f, buffer[6]
  ASSERT.equal 0x7f, buffer[7]
  buffer.writeFloatLE 1.1754943508222875e-38, 0
  buffer.writeFloatBE 1.1754943508222875e-38, 4
  ASSERT.equal 0x00, buffer[0]
  ASSERT.equal 0x00, buffer[1]
  ASSERT.equal 0x80, buffer[2]
  ASSERT.equal 0x00, buffer[3]
  ASSERT.equal 0x00, buffer[4]
  ASSERT.equal 0x80, buffer[5]
  ASSERT.equal 0x00, buffer[6]
  ASSERT.equal 0x00, buffer[7]
  buffer.writeFloatBE 0 * -1, 0
  buffer.writeFloatLE 0 * -1, 4
  ASSERT.equal 0x80, buffer[0]
  ASSERT.equal 0x00, buffer[1]
  ASSERT.equal 0x00, buffer[2]
  ASSERT.equal 0x00, buffer[3]
  ASSERT.equal 0x00, buffer[4]
  ASSERT.equal 0x00, buffer[5]
  ASSERT.equal 0x00, buffer[6]
  ASSERT.equal 0x80, buffer[7]
  buffer.writeFloatBE Infinity, 0
  buffer.writeFloatLE Infinity, 4
  ASSERT.equal 0x7f, buffer[0]
  ASSERT.equal 0x80, buffer[1]
  ASSERT.equal 0x00, buffer[2]
  ASSERT.equal 0x00, buffer[3]
  ASSERT.equal 0x00, buffer[4]
  ASSERT.equal 0x00, buffer[5]
  ASSERT.equal 0x80, buffer[6]
  ASSERT.equal 0x7f, buffer[7]
  ASSERT.equal Infinity, buffer.readFloatBE(0)
  ASSERT.equal Infinity, buffer.readFloatLE(4)
  buffer.writeFloatBE -Infinity, 0
  buffer.writeFloatLE -Infinity, 4
  
  # Darwin ia32 does the other kind of NaN.
  # Compiler bug.  No one really cares.
  ASSERT 0xff is buffer[0] or 0x7f is buffer[0]
  ASSERT.equal 0x80, buffer[1]
  ASSERT.equal 0x00, buffer[2]
  ASSERT.equal 0x00, buffer[3]
  ASSERT.equal 0x00, buffer[4]
  ASSERT.equal 0x00, buffer[5]
  ASSERT.equal 0x80, buffer[6]
  ASSERT.equal 0xff, buffer[7]
  ASSERT.equal -Infinity, buffer.readFloatBE(0)
  ASSERT.equal -Infinity, buffer.readFloatLE(4)
  buffer.writeFloatBE NaN, 0
  buffer.writeFloatLE NaN, 4
  
  # Darwin ia32 does the other kind of NaN.
  # Compiler bug.  No one really cares.
  ASSERT 0x7f is buffer[0] or 0xff is buffer[0]
  
  # mips processors use a slightly different NaN
  ASSERT 0xc0 is buffer[1] or 0xbf is buffer[1]
  ASSERT 0x00 is buffer[2] or 0xff is buffer[2]
  ASSERT 0x00 is buffer[3] or 0xff is buffer[3]
  ASSERT 0x00 is buffer[4] or 0xff is buffer[4]
  ASSERT 0x00 is buffer[5] or 0xff is buffer[5]
  ASSERT 0xc0 is buffer[6] or 0xbf is buffer[6]
  
  # Darwin ia32 does the other kind of NaN.
  # Compiler bug.  No one really cares.
  ASSERT 0x7f is buffer[7] or 0xff is buffer[7]
  ASSERT.ok isNaN(buffer.readFloatBE(0))
  ASSERT.ok isNaN(buffer.readFloatLE(4))
  return
common = require("../common")
ASSERT = require("assert")
test Buffer
