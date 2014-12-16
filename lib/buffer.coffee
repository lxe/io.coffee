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
createPool = ->
  poolSize = Buffer.poolSize
  allocPool = alloc({}, poolSize)
  poolOffset = 0
  return
Buffer = (subject, encoding) ->
  return new Buffer(subject, encoding)  unless util.isBuffer(this)
  if util.isNumber(subject)
    @length = (if subject > 0 then subject >>> 0 else 0)
  else if util.isString(subject)
    encoding = "utf8"  if not util.isString(encoding) or encoding.length is 0
    @length = Buffer.byteLength(subject, encoding)
  
  # Handle Arrays, Buffers, Uint8Arrays or JSON.
  else if util.isObject(subject)
    subject = subject.data  if subject.type is "Buffer" and util.isArray(subject.data)
    
    # Must use floor() because array length may be > kMaxLength.
    @length = (if +subject.length > 0 then Math.floor(+subject.length) else 0)
  else
    throw new TypeError("must start with number, buffer, array or string")
  throw new RangeError("Attempt to allocate Buffer larger than maximum " + "size: 0x" + kMaxLength.toString(16) + " bytes")  if @length > kMaxLength
  @parent = `undefined`
  if @length <= (Buffer.poolSize >>> 1) and @length > 0
    createPool()  if @length > poolSize - poolOffset
    @parent = sliceOnto(allocPool, this, poolOffset, poolOffset + @length)
    poolOffset += @length
  else
    alloc this, @length
  return  if util.isNumber(subject)
  if util.isString(subject)
    
    # In the case of base64 it's possible that the size of the buffer
    # allocated was slightly too large. In this case we need to rewrite
    # the length to the actual length written.
    len = @write(subject, encoding)
    
    # Buffer was truncated after decode, realloc internal ExternalArray
    if len isnt @length
      prevLen = @length
      @length = len
      truncate this, @length
      poolOffset -= (prevLen - len)
  else if util.isBuffer(subject)
    subject.copy this, 0, 0, @length
  else if util.isNumber(subject.length) or util.isArray(subject)
    
    # Really crappy way to handle Uint8Arrays, but V8 doesn't give a simple
    # way to access the data from the C++ API.
    i = 0

    while i < @length
      this[i] = subject[i]
      i++
  return
SlowBuffer = (length) ->
  length = length >>> 0
  throw new RangeError("Attempt to allocate Buffer larger than maximum " + "size: 0x" + kMaxLength.toString(16) + " bytes")  if length > kMaxLength
  b = new NativeBuffer(length)
  alloc b, length
  b

# Bypass all checks for instantiating unallocated Buffer required for
# Objects created in C++. Significantly faster than calling the Buffer
# function.
NativeBuffer = (length) ->
  @length = length >>> 0
  
  # Set this to keep the object map the same.
  @parent = `undefined`
  return

# add methods to Buffer prototype

# Static methods

# toString(encoding, start=0, end=buffer.length)

# Inspect

# XXX remove in v0.13

# XXX remove in v0.13

# TODO(trevnorris): fix these checks to follow new standard
# write(string, offset = 0, length = buffer.length, encoding = 'utf8')

# Buffer#write(string);

# Buffer#write(string, encoding)

# Buffer#write(string, offset[, length][, encoding])

# XXX legacy write(string, encoding, offset, length) - remove in v0.13

# Warning: maxLength not taken into account in base64Write

# TODO(trevnorris): currently works like Array.prototype.slice(), which
# doesn't follow the new standard for throwing on out of range indexes.
checkOffset = (offset, ext, length) ->
  throw new RangeError("index out of range")  if offset + ext > length
  return
checkInt = (buffer, value, offset, ext, max, min) ->
  throw new TypeError("buffer must be a Buffer instance")  unless buffer instanceof Buffer
  throw new TypeError("value is out of bounds")  if value > max or value < min
  throw new RangeError("index out of range")  if offset + ext > buffer.length
  return
checkFloat = (buffer, value, offset, ext) ->
  throw new TypeError("buffer must be a Buffer instance")  unless buffer instanceof Buffer
  throw new RangeError("index out of range")  if offset + ext > buffer.length
  return
"use strict"
buffer = process.binding("buffer")
smalloc = process.binding("smalloc")
util = require("util")
alloc = smalloc.alloc
truncate = smalloc.truncate
sliceOnto = smalloc.sliceOnto
kMaxLength = smalloc.kMaxLength
internal = {}
exports.Buffer = Buffer
exports.SlowBuffer = SlowBuffer
exports.INSPECT_MAX_BYTES = 50
Buffer.poolSize = 8 * 1024
poolSize = undefined
poolOffset = undefined
allocPool = undefined
createPool()
NativeBuffer:: = Buffer::
buffer.setupBufferJS NativeBuffer, internal
Buffer.isBuffer = isBuffer = (b) ->
  util.isBuffer b

Buffer.compare = compare = (a, b) ->
  throw new TypeError("Arguments must be Buffers")  if (a not instanceof Buffer) or (b not instanceof Buffer)
  internal.compare a, b

Buffer.isEncoding = (encoding) ->
  switch (encoding + "").toLowerCase()
    when "hex", "utf8", "utf-8", "ascii", "binary", "base64", "ucs2", "ucs-2", "utf16le", "utf-16le", "raw"
      true
    else
      false

Buffer.concat = (list, length) ->
  throw new TypeError("Usage: Buffer.concat(list[, length])")  unless util.isArray(list)
  if util.isUndefined(length)
    length = 0
    i = 0

    while i < list.length
      length += list[i].length
      i++
  else
    length = length >>> 0
  if list.length is 0
    return new Buffer(0)
  else return list[0]  if list.length is 1
  buffer = new Buffer(length)
  pos = 0
  i = 0

  while i < list.length
    buf = list[i]
    buf.copy buffer, pos
    pos += buf.length
    i++
  buffer

Buffer.byteLength = (str, enc) ->
  ret = undefined
  str = str + ""
  switch enc
    when "ascii", "binary", "raw"
      ret = str.length
    when "ucs2", "ucs-2", "utf16le", "utf-16le"
      ret = str.length * 2
    when "hex"
      ret = str.length >>> 1
    else
      ret = internal.byteLength(str, enc)
  ret

Buffer::toString = (encoding, start, end) ->
  loweredCase = false
  start = start >>> 0
  end = (if util.isUndefined(end) or end is Infinity then @length else end >>> 0)
  encoding = "utf8"  unless encoding
  start = 0  if start < 0
  end = @length  if end > @length
  return ""  if end <= start
  loop
    switch encoding
      when "hex"
        return @hexSlice(start, end)
      when "utf8", "utf-8"
        return @utf8Slice(start, end)
      when "ascii"
        return @asciiSlice(start, end)
      when "binary"
        return @binarySlice(start, end)
      when "base64"
        return @base64Slice(start, end)
      when "ucs2", "ucs-2", "utf16le", "utf-16le"
        return @ucs2Slice(start, end)
      else
        throw new TypeError("Unknown encoding: " + encoding)  if loweredCase
        encoding = (encoding + "").toLowerCase()
        loweredCase = true
  return

Buffer::equals = equals = (b) ->
  throw new TypeError("Argument must be a Buffer")  unless b instanceof Buffer
  internal.compare(this, b) is 0

Buffer::inspect = inspect = ->
  str = ""
  max = exports.INSPECT_MAX_BYTES
  if @length > 0
    str = @toString("hex", 0, max).match(/.{2}/g).join(" ")
    str += " ... "  if @length > max
  "<" + @constructor.name + " " + str + ">"

Buffer::compare = compare = (b) ->
  throw new TypeError("Argument must be a Buffer")  unless b instanceof Buffer
  internal.compare this, b

Buffer::fill = fill = (val, start, end) ->
  start = start >> 0
  end = (if (end is `undefined`) then @length else end >> 0)
  throw new RangeError("out of range index")  if start < 0 or end > @length
  return this  if end <= start
  if typeof val isnt "string"
    val = val >>> 0
  else if val.length is 1
    code = val.charCodeAt(0)
    val = code  if code < 256
  internal.fill this, val, start, end
  this

Buffer::get = util.deprecate(get = (offset) ->
  offset = ~~offset
  throw new RangeError("index out of range")  if offset < 0 or offset >= @length
  this[offset]
, ".get() is deprecated. Access using array indexes instead.")
Buffer::set = util.deprecate(set = (offset, v) ->
  offset = ~~offset
  throw new RangeError("index out of range")  if offset < 0 or offset >= @length
  this[offset] = v
, ".set() is deprecated. Set using array indexes instead.")
writeWarned = false
writeMsg = ".write(string, encoding, offset, length) is deprecated." + " Use write(string[, offset[, length]][, encoding]) instead."
Buffer::write = (string, offset, length, encoding) ->
  if util.isUndefined(offset)
    encoding = "utf8"
    length = @length
    offset = 0
  else if util.isUndefined(length) and util.isString(offset)
    encoding = offset
    length = @length
    offset = 0
  else if isFinite(offset)
    offset = offset >>> 0
    if isFinite(length)
      length = length >>> 0
      encoding = "utf8"  if util.isUndefined(encoding)
    else
      encoding = length
      length = `undefined`
  else
    unless writeWarned
      if process.throwDeprecation
        throw new Error(writeMsg)
      else if process.traceDeprecation
        console.trace writeMsg
      else
        console.error writeMsg
      writeWarned = true
    swap = encoding
    encoding = offset
    offset = length >>> 0
    length = swap
  remaining = @length - offset
  length = remaining  if util.isUndefined(length) or length > remaining
  encoding = (if !!encoding then (encoding + "").toLowerCase() else "utf8")
  throw new RangeError("attempt to write outside buffer bounds")  if string.length > 0 and (length < 0 or offset < 0)
  ret = undefined
  switch encoding
    when "hex"
      ret = @hexWrite(string, offset, length)
    when "utf8", "utf-8"
      ret = @utf8Write(string, offset, length)
    when "ascii"
      ret = @asciiWrite(string, offset, length)
    when "binary"
      ret = @binaryWrite(string, offset, length)
    when "base64"
      ret = @base64Write(string, offset, length)
    when "ucs2", "ucs-2", "utf16le", "utf-16le"
      ret = @ucs2Write(string, offset, length)
    else
      throw new TypeError("Unknown encoding: " + encoding)
  ret

Buffer::toJSON = ->
  type: "Buffer"
  data: Array::slice.call(this, 0)

Buffer::slice = (start, end) ->
  len = @length
  start = ~~start
  end = (if util.isUndefined(end) then len else ~~end)
  if start < 0
    start += len
    start = 0  if start < 0
  else start = len  if start > len
  if end < 0
    end += len
    end = 0  if end < 0
  else end = len  if end > len
  end = start  if end < start
  buf = new NativeBuffer()
  sliceOnto this, buf, start, end
  buf.length = end - start
  buf.parent = (if util.isUndefined(@parent) then this else @parent)  if buf.length > 0
  buf

Buffer::readUIntLE = (offset, byteLength, noAssert) ->
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  checkOffset offset, byteLength, @length  unless noAssert
  val = this[offset]
  mul = 1
  i = 0
  val += this[offset + i] * mul  while ++i < byteLength and (mul *= 0x100)
  val

Buffer::readUIntBE = (offset, byteLength, noAssert) ->
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  checkOffset offset, byteLength, @length  unless noAssert
  val = this[offset + --byteLength]
  mul = 1
  val += this[offset + --byteLength] * mul  while byteLength > 0 and (mul *= 0x100)
  val

Buffer::readUInt8 = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 1, @length  unless noAssert
  this[offset]

Buffer::readUInt16LE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 2, @length  unless noAssert
  this[offset] | (this[offset + 1] << 8)

Buffer::readUInt16BE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 2, @length  unless noAssert
  (this[offset] << 8) | this[offset + 1]

Buffer::readUInt32LE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 4, @length  unless noAssert
  ((this[offset]) | (this[offset + 1] << 8) | (this[offset + 2] << 16)) + (this[offset + 3] * 0x1000000)

Buffer::readUInt32BE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 4, @length  unless noAssert
  (this[offset] * 0x1000000) + ((this[offset + 1] << 16) | (this[offset + 2] << 8) | this[offset + 3])

Buffer::readIntLE = (offset, byteLength, noAssert) ->
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  checkOffset offset, byteLength, @length  unless noAssert
  val = this[offset]
  mul = 1
  i = 0
  val += this[offset + i] * mul  while ++i < byteLength and (mul *= 0x100)
  mul *= 0x80
  val -= Math.pow(2, 8 * byteLength)  if val >= mul
  val

Buffer::readIntBE = (offset, byteLength, noAssert) ->
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  checkOffset offset, byteLength, @length  unless noAssert
  i = byteLength
  mul = 1
  val = this[offset + --i]
  val += this[offset + --i] * mul  while i > 0 and (mul *= 0x100)
  mul *= 0x80
  val -= Math.pow(2, 8 * byteLength)  if val >= mul
  val

Buffer::readInt8 = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 1, @length  unless noAssert
  val = this[offset]
  (if not (val & 0x80) then val else (0xff - val + 1) * -1)

Buffer::readInt16LE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 2, @length  unless noAssert
  val = this[offset] | (this[offset + 1] << 8)
  (if (val & 0x8000) then val | 0xffff0000 else val)

Buffer::readInt16BE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 2, @length  unless noAssert
  val = this[offset + 1] | (this[offset] << 8)
  (if (val & 0x8000) then val | 0xffff0000 else val)

Buffer::readInt32LE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 4, @length  unless noAssert
  (this[offset]) | (this[offset + 1] << 8) | (this[offset + 2] << 16) | (this[offset + 3] << 24)

Buffer::readInt32BE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 4, @length  unless noAssert
  (this[offset] << 24) | (this[offset + 1] << 16) | (this[offset + 2] << 8) | (this[offset + 3])

Buffer::readFloatLE = readFloatLE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 4, @length  unless noAssert
  internal.readFloatLE this, offset

Buffer::readFloatBE = readFloatBE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 4, @length  unless noAssert
  internal.readFloatBE this, offset

Buffer::readDoubleLE = readDoubleLE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 8, @length  unless noAssert
  internal.readDoubleLE this, offset

Buffer::readDoubleBE = readDoubleBE = (offset, noAssert) ->
  offset = offset >>> 0
  checkOffset offset, 8, @length  unless noAssert
  internal.readDoubleBE this, offset

Buffer::writeUIntLE = (value, offset, byteLength, noAssert) ->
  value = +value
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  checkInt this, value, offset, byteLength, Math.pow(2, 8 * byteLength), 0  unless noAssert
  mul = 1
  i = 0
  this[offset] = value
  this[offset + i] = (value / mul) >>> 0  while ++i < byteLength and (mul *= 0x100)
  offset + byteLength

Buffer::writeUIntBE = (value, offset, byteLength, noAssert) ->
  value = +value
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  checkInt this, value, offset, byteLength, Math.pow(2, 8 * byteLength), 0  unless noAssert
  i = byteLength - 1
  mul = 1
  this[offset + i] = value
  this[offset + i] = (value / mul) >>> 0  while --i >= 0 and (mul *= 0x100)
  offset + byteLength

Buffer::writeUInt8 = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 1, 0xff, 0  unless noAssert
  this[offset] = value
  offset + 1

Buffer::writeUInt16LE = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 2, 0xffff, 0  unless noAssert
  this[offset] = value
  this[offset + 1] = (value >>> 8)
  offset + 2

Buffer::writeUInt16BE = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 2, 0xffff, 0  unless noAssert
  this[offset] = (value >>> 8)
  this[offset + 1] = value
  offset + 2

Buffer::writeUInt32LE = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 4, 0xffffffff, 0  unless noAssert
  this[offset + 3] = (value >>> 24)
  this[offset + 2] = (value >>> 16)
  this[offset + 1] = (value >>> 8)
  this[offset] = value
  offset + 4

Buffer::writeUInt32BE = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 4, 0xffffffff, 0  unless noAssert
  this[offset] = (value >>> 24)
  this[offset + 1] = (value >>> 16)
  this[offset + 2] = (value >>> 8)
  this[offset + 3] = value
  offset + 4

Buffer::writeIntLE = (value, offset, byteLength, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, byteLength, Math.pow(2, 8 * byteLength - 1) - 1, -Math.pow(2, 8 * byteLength - 1)  unless noAssert
  i = 0
  mul = 1
  sub = (if value < 0 then 1 else 0)
  this[offset] = value
  this[offset + i] = ((value / mul) >> 0) - sub  while ++i < byteLength and (mul *= 0x100)
  offset + byteLength

Buffer::writeIntBE = (value, offset, byteLength, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, byteLength, Math.pow(2, 8 * byteLength - 1) - 1, -Math.pow(2, 8 * byteLength - 1)  unless noAssert
  i = byteLength - 1
  mul = 1
  sub = (if value < 0 then 1 else 0)
  this[offset + i] = value
  this[offset + i] = ((value / mul) >> 0) - sub  while --i >= 0 and (mul *= 0x100)
  offset + byteLength

Buffer::writeInt8 = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 1, 0x7f, -0x80  unless noAssert
  this[offset] = value
  offset + 1

Buffer::writeInt16LE = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 2, 0x7fff, -0x8000  unless noAssert
  this[offset] = value
  this[offset + 1] = (value >>> 8)
  offset + 2

Buffer::writeInt16BE = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 2, 0x7fff, -0x8000  unless noAssert
  this[offset] = (value >>> 8)
  this[offset + 1] = value
  offset + 2

Buffer::writeInt32LE = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 4, 0x7fffffff, -0x80000000  unless noAssert
  this[offset] = value
  this[offset + 1] = (value >>> 8)
  this[offset + 2] = (value >>> 16)
  this[offset + 3] = (value >>> 24)
  offset + 4

Buffer::writeInt32BE = (value, offset, noAssert) ->
  value = +value
  offset = offset >>> 0
  checkInt this, value, offset, 4, 0x7fffffff, -0x80000000  unless noAssert
  this[offset] = (value >>> 24)
  this[offset + 1] = (value >>> 16)
  this[offset + 2] = (value >>> 8)
  this[offset + 3] = value
  offset + 4

Buffer::writeFloatLE = writeFloatLE = (val, offset, noAssert) ->
  val = +val
  offset = offset >>> 0
  checkFloat this, val, offset, 4  unless noAssert
  internal.writeFloatLE this, val, offset
  offset + 4

Buffer::writeFloatBE = writeFloatBE = (val, offset, noAssert) ->
  val = +val
  offset = offset >>> 0
  checkFloat this, val, offset, 4  unless noAssert
  internal.writeFloatBE this, val, offset
  offset + 4

Buffer::writeDoubleLE = writeDoubleLE = (val, offset, noAssert) ->
  val = +val
  offset = offset >>> 0
  checkFloat this, val, offset, 8  unless noAssert
  internal.writeDoubleLE this, val, offset
  offset + 8

Buffer::writeDoubleBE = writeDoubleBE = (val, offset, noAssert) ->
  val = +val
  offset = offset >>> 0
  checkFloat this, val, offset, 8  unless noAssert
  internal.writeDoubleBE this, val, offset
  offset + 8
