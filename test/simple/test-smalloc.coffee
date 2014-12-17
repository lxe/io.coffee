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
os = require("os")

# first grab js api's
smalloc = require("smalloc")
alloc = smalloc.alloc
dispose = smalloc.dispose
copyOnto = smalloc.copyOnto
kMaxLength = smalloc.kMaxLength
Types = smalloc.Types

# sliceOnto is volatile and cannot be exposed to users.
sliceOnto = process.binding("smalloc").sliceOnto

# verify allocation
b = alloc(5, {})
assert.ok typeof b is "object"
i = 0

while i < 5
  assert.ok b[i] isnt `undefined`
  i++
b = {}
c = alloc(5, b)
assert.equal b, c
assert.deepEqual b, c
b = alloc(5, {})
c = {}
c._data = sliceOnto(b, c, 0, 5)
assert.ok typeof c._data is "object"
assert.equal b, c._data
assert.deepEqual b, c._data

# verify writes
b = alloc(5, {})
i = 0

while i < 5
  b[i] = i
  i++
i = 0

while i < 5
  assert.equal b[i], i
  i++
b = alloc(1, Types.Uint8)
b[0] = 256
assert.equal b[0], 0
assert.equal b[1], `undefined`
b = alloc(1, Types.Int8)
b[0] = 128
assert.equal b[0], -128
assert.equal b[1], `undefined`
b = alloc(1, Types.Uint16)
b[0] = 65536
assert.equal b[0], 0
assert.equal b[1], `undefined`
b = alloc(1, Types.Int16)
b[0] = 32768
assert.equal b[0], -32768
assert.equal b[1], `undefined`
b = alloc(1, Types.Uint32)
b[0] = 4294967296
assert.equal b[0], 0
assert.equal b[1], `undefined`
b = alloc(1, Types.Int32)
b[0] = 2147483648
assert.equal b[0], -2147483648
assert.equal b[1], `undefined`
b = alloc(1, Types.Float)
b[0] = 0.1111111111111111
assert.equal b[0], 0.1111111119389534
assert.equal b[1], `undefined`
b = alloc(1, Types.Double)
b[0] = 0.1111111111111111
assert.equal b[0], 0.1111111111111111
assert.equal b[1], `undefined`
b = alloc(1, Types.Uint8Clamped)
b[0] = 300
assert.equal b[0], 255
assert.equal b[1], `undefined`
b = alloc(6, {})
c0 = {}
c1 = {}
c0._data = sliceOnto(b, c0, 0, 3)
c1._data = sliceOnto(b, c1, 3, 6)
i = 0

while i < 3
  c0[i] = i
  c1[i] = i + 3
  i++
i = 0

while i < 3
  assert.equal b[i], i
  i++
i = 3

while i < 6
  assert.equal b[i], i
  i++
a = alloc(6, {})
b = alloc(6, {})
c = alloc(12, {})
i = 0

while i < 6
  a[i] = i
  b[i] = i * 2
  i++
copyOnto a, 0, c, 0, 6
copyOnto b, 0, c, 6, 6
i = 0

while i < 6
  assert.equal c[i], i
  assert.equal c[i + 6], i * 2
  i++
b = alloc(1, Types.Double)
c = alloc(2, Types.Uint32)
if os.endianness() is "LE"
  c[0] = 2576980378
  c[1] = 1069128089
else
  c[0] = 1069128089
  c[1] = 2576980378
copyOnto c, 0, b, 0, 2
assert.equal b[0], 0.1
b = alloc(1, Types.Uint16)
c = alloc(2, Types.Uint8)
c[0] = c[1] = 0xff
copyOnto c, 0, b, 0, 2
assert.equal b[0], 0xffff
b = alloc(2, Types.Uint8)
c = alloc(1, Types.Uint16)
c[0] = 0xffff
copyOnto c, 0, b, 0, 1
assert.equal b[0], 0xff
assert.equal b[1], 0xff

# verify checking external if has external memory

# check objects
b = {}
assert.ok not smalloc.hasExternalData(b)
alloc 1, b
assert.ok smalloc.hasExternalData(b)
f = ->

alloc 1, f
assert.ok smalloc.hasExternalData(f)

# and non-objects
assert.ok not smalloc.hasExternalData(true)
assert.ok not smalloc.hasExternalData(1)
assert.ok not smalloc.hasExternalData("string")
assert.ok not smalloc.hasExternalData(null)
assert.ok not smalloc.hasExternalData()

# verify alloc throws properly

# arrays are not supported
assert.throws (->
  alloc 0, []
  return
), TypeError

# no allocations larger than kMaxLength
assert.throws (->
  alloc kMaxLength + 1
  return
), RangeError

# properly convert to uint32 before checking overflow
assert.throws (->
  alloc -1
  return
), RangeError

# no allocating on what's been allocated
assert.throws (->
  alloc 1, alloc(1)
  return
), TypeError

# throw for values passed that are not objects
assert.throws (->
  alloc 1, "a"
  return
), TypeError
assert.throws (->
  alloc 1, true
  return
), TypeError
assert.throws (->
  alloc 1, null
  return
), TypeError

# should not throw allocating to most objects
alloc 1, ->

alloc 1, /abc/
alloc 1, new Date()

# range check on external array enumeration
assert.throws (->
  alloc 1, 0
  return
), TypeError
assert.throws (->
  alloc 1, 10
  return
), TypeError

# very copyOnto throws properly

# source must have data
assert.throws (->
  copyOnto {}, 0, alloc(1), 0, 0
  return
), Error

# dest must have data
assert.throws (->
  copyOnto alloc(1), 0, {}, 0, 0
  return
), Error

# copyLength <= sourceLength
assert.throws (->
  copyOnto alloc(1), 0, alloc(3), 0, 2
  return
), RangeError

# copyLength <= destLength
assert.throws (->
  copyOnto alloc(3), 0, alloc(1), 0, 2
  return
), RangeError

# sourceStart <= sourceLength
assert.throws (->
  copyOnto alloc(1), 3, alloc(1), 0, 1
  return
), RangeError

# destStart <= destLength
assert.throws (->
  copyOnto alloc(1), 0, alloc(1), 3, 1
  return
), RangeError

# sourceStart + copyLength <= sourceLength
assert.throws (->
  copyOnto alloc(3), 1, alloc(3), 0, 3
  return
), RangeError

# destStart + copyLength <= destLength
assert.throws (->
  copyOnto alloc(3), 0, alloc(3), 1, 3
  return
), RangeError

# copy_length * array_size <= dest_length
assert.throws (->
  copyOnto alloc(2, Types.Double), 0, alloc(2, Types.Uint32), 0, 2
  return
), RangeError

# test disposal
b = alloc(5, {})
dispose b
i = 0

while i < 5
  assert.equal b[i], `undefined`
  i++

# verify dispose throws properly

# only allow object to be passed to dispose
assert.throws ->
  smalloc.dispose null
  return


# can't dispose a Buffer
assert.throws ->
  smalloc.dispose new Buffer()
  return

assert.throws ->
  smalloc.dispose new Uint8Array(new ArrayBuffer(1))
  return

assert.throws ->
  smalloc.dispose {}
  return

