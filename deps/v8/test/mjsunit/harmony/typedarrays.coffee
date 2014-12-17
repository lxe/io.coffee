# Copyright 2013 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Flags: --harmony-tostring

# ArrayBuffer
TestByteLength = (param, expectedByteLength) ->
  ab = new ArrayBuffer(param)
  assertSame expectedByteLength, ab.byteLength
  return
TestArrayBufferCreation = ->
  TestByteLength 1, 1
  TestByteLength 256, 256
  TestByteLength 2.567, 2
  TestByteLength "abc", 0
  TestByteLength 0, 0
  assertThrows (->
    new ArrayBuffer(-10)
    return
  ), RangeError
  assertThrows (->
    new ArrayBuffer(-2.567)
    return
  ), RangeError
  
  # TODO[dslomov]: Reenable the test
  #  assertThrows(function() {
  #    var ab1 = new ArrayBuffer(0xFFFFFFFFFFFF)
  #  }, RangeError);
  #
  ab = new ArrayBuffer()
  assertSame 0, ab.byteLength
  assertEquals "[object ArrayBuffer]", Object::toString.call(ab)
  return
TestByteLengthNotWritable = ->
  ab = new ArrayBuffer(1024)
  assertSame 1024, ab.byteLength
  assertThrows (->
    "use strict"
    ab.byteLength = 42
    return
  ), TypeError
  return
TestSlice = (expectedResultLen, initialLen, start, end) ->
  ab = new ArrayBuffer(initialLen)
  a1 = new Uint8Array(ab)
  i = 0

  while i < a1.length
    a1[i] = 0xca
    i++
  slice = ab.slice(start, end)
  assertSame expectedResultLen, slice.byteLength
  a2 = new Uint8Array(slice)
  i = 0

  while i < a2.length
    assertSame 0xca, a2[i]
    i++
  return
TestArrayBufferSlice = ->
  ab = new ArrayBuffer(1024)
  ab1 = ab.slice(512, 1024)
  assertSame 512, ab1.byteLength
  TestSlice 512, 1024, 512, 1024
  TestSlice 512, 1024, 512
  TestSlice 0, 0, 1, 20
  TestSlice 100, 100, 0, 100
  TestSlice 100, 100, 0, 1000
  TestSlice 0, 100, 5, 1
  TestSlice 1, 100, -11, -10
  TestSlice 9, 100, -10, 99
  TestSlice 0, 100, -10, 80
  TestSlice 10, 100, 80, -10
  TestSlice 10, 100, 90, "100"
  TestSlice 10, 100, "90", "100"
  TestSlice 0, 100, 90, "abc"
  TestSlice 10, 100, "abc", 10
  TestSlice 10, 100, 0.96, 10.96
  TestSlice 10, 100, 0.96, 10.01
  TestSlice 10, 100, 0.01, 10.01
  TestSlice 10, 100, 0.01, 10.96
  TestSlice 10, 100, 90
  TestSlice 10, 100, -10
  return

# Typed arrays
TestTypedArray = (constr, elementSize, typicalElement) ->
  assertSame elementSize, constr.BYTES_PER_ELEMENT
  ab = new ArrayBuffer(256 * elementSize)
  a0 = new constr(30)
  assertEquals "[object " + constr.name + "]", Object::toString.call(a0)
  assertTrue ArrayBuffer.isView(a0)
  assertSame elementSize, a0.BYTES_PER_ELEMENT
  assertSame 30, a0.length
  assertSame 30 * elementSize, a0.byteLength
  assertSame 0, a0.byteOffset
  assertSame 30 * elementSize, a0.buffer.byteLength
  aLen0 = new constr(0)
  assertSame elementSize, aLen0.BYTES_PER_ELEMENT
  assertSame 0, aLen0.length
  assertSame 0, aLen0.byteLength
  assertSame 0, aLen0.byteOffset
  assertSame 0, aLen0.buffer.byteLength
  aOverBufferLen0 = new constr(ab, 128 * elementSize, 0)
  assertSame ab, aOverBufferLen0.buffer
  assertSame elementSize, aOverBufferLen0.BYTES_PER_ELEMENT
  assertSame 0, aOverBufferLen0.length
  assertSame 0, aOverBufferLen0.byteLength
  assertSame 128 * elementSize, aOverBufferLen0.byteOffset
  a1 = new constr(ab, 128 * elementSize, 128)
  assertSame ab, a1.buffer
  assertSame elementSize, a1.BYTES_PER_ELEMENT
  assertSame 128, a1.length
  assertSame 128 * elementSize, a1.byteLength
  assertSame 128 * elementSize, a1.byteOffset
  a2 = new constr(ab, 64 * elementSize, 128)
  assertSame ab, a2.buffer
  assertSame elementSize, a2.BYTES_PER_ELEMENT
  assertSame 128, a2.length
  assertSame 128 * elementSize, a2.byteLength
  assertSame 64 * elementSize, a2.byteOffset
  a3 = new constr(ab, 192 * elementSize)
  assertSame ab, a3.buffer
  assertSame 64, a3.length
  assertSame 64 * elementSize, a3.byteLength
  assertSame 192 * elementSize, a3.byteOffset
  a4 = new constr(ab)
  assertSame ab, a4.buffer
  assertSame 256, a4.length
  assertSame 256 * elementSize, a4.byteLength
  assertSame 0, a4.byteOffset
  i = undefined
  i = 0
  while i < 128
    a1[i] = typicalElement
    i++
  i = 0
  while i < 128
    assertSame typicalElement, a1[i]
    i++
  i = 0
  while i < 64
    assertSame 0, a2[i]
    i++
  i = 64
  while i < 128
    assertSame typicalElement, a2[i]
    i++
  i = 0
  while i < 64
    assertSame typicalElement, a3[i]
    i++
  i = 0
  while i < 128
    assertSame 0, a4[i]
    i++
  i = 128
  while i < 256
    assertSame typicalElement, a4[i]
    i++
  aAtTheEnd = new constr(ab, 256 * elementSize)
  assertSame elementSize, aAtTheEnd.BYTES_PER_ELEMENT
  assertSame 0, aAtTheEnd.length
  assertSame 0, aAtTheEnd.byteLength
  assertSame 256 * elementSize, aAtTheEnd.byteOffset
  assertThrows (->
    new constr(ab, 257 * elementSize)
    return
  ), RangeError
  assertThrows (->
    new constr(ab, 128 * elementSize, 192)
    return
  ), RangeError
  if elementSize isnt 1
    assertThrows (->
      new constr(ab, 128 * elementSize - 1, 10)
      return
    ), RangeError
    unalignedArrayBuffer = new ArrayBuffer(10 * elementSize + 1)
    goodArray = new constr(unalignedArrayBuffer, 0, 10)
    assertSame 10, goodArray.length
    assertSame 10 * elementSize, goodArray.byteLength
    assertThrows (->
      new constr(unalignedArrayBuffer)
      return
    ), RangeError
    assertThrows (->
      new constr(unalignedArrayBuffer, 5 * elementSize)
      return
    ), RangeError
  aFromString = new constr("30")
  assertSame elementSize, aFromString.BYTES_PER_ELEMENT
  assertSame 30, aFromString.length
  assertSame 30 * elementSize, aFromString.byteLength
  assertSame 0, aFromString.byteOffset
  assertSame 30 * elementSize, aFromString.buffer.byteLength
  jsArray = []
  i = 0
  while i < 30
    jsArray.push typicalElement
    i++
  aFromArray = new constr(jsArray)
  assertSame elementSize, aFromArray.BYTES_PER_ELEMENT
  assertSame 30, aFromArray.length
  assertSame 30 * elementSize, aFromArray.byteLength
  assertSame 0, aFromArray.byteOffset
  assertSame 30 * elementSize, aFromArray.buffer.byteLength
  i = 0
  while i < 30
    assertSame typicalElement, aFromArray[i]
    i++
  abLen0 = new ArrayBuffer(0)
  aOverAbLen0 = new constr(abLen0)
  assertSame abLen0, aOverAbLen0.buffer
  assertSame elementSize, aOverAbLen0.BYTES_PER_ELEMENT
  assertSame 0, aOverAbLen0.length
  assertSame 0, aOverAbLen0.byteLength
  assertSame 0, aOverAbLen0.byteOffset
  aNoParam = new constr()
  assertSame elementSize, aNoParam.BYTES_PER_ELEMENT
  assertSame 0, aNoParam.length
  assertSame 0, aNoParam.byteLength
  assertSame 0, aNoParam.byteOffset
  a = new constr(ab, 64 * elementSize, 128)
  assertEquals "[object " + constr.name + "]", Object::toString.call(a)
  desc = Object.getOwnPropertyDescriptor(constr::, Symbol.toStringTag)
  assertTrue desc.configurable
  assertFalse desc.enumerable
  assertFalse !!desc.writable
  assertFalse !!desc.set
  assertEquals "function", typeof desc.get
  return
SubarrayTestCase = (constructor, item, expectedResultLen, expectedStartIndex, initialLen, start, end) ->
  a = new constructor(initialLen)
  s = a.subarray(start, end)
  assertSame constructor, s.constructor
  assertSame expectedResultLen, s.length
  if s.length > 0
    s[0] = item
    assertSame item, a[expectedStartIndex]
  return
TestSubArray = (constructor, item) ->
  SubarrayTestCase constructor, item, 512, 512, 1024, 512, 1024
  SubarrayTestCase constructor, item, 512, 512, 1024, 512
  SubarrayTestCase constructor, item, 0, `undefined`, 0, 1, 20
  SubarrayTestCase constructor, item, 100, 0, 100, 0, 100
  SubarrayTestCase constructor, item, 100, 0, 100, 0, 1000
  SubarrayTestCase constructor, item, 0, `undefined`, 100, 5, 1
  SubarrayTestCase constructor, item, 1, 89, 100, -11, -10
  SubarrayTestCase constructor, item, 9, 90, 100, -10, 99
  SubarrayTestCase constructor, item, 0, `undefined`, 100, -10, 80
  SubarrayTestCase constructor, item, 10, 80, 100, 80, -10
  SubarrayTestCase constructor, item, 10, 90, 100, 90, "100"
  SubarrayTestCase constructor, item, 10, 90, 100, "90", "100"
  SubarrayTestCase constructor, item, 0, `undefined`, 100, 90, "abc"
  SubarrayTestCase constructor, item, 10, 0, 100, "abc", 10
  SubarrayTestCase constructor, item, 10, 0, 100, 0.96, 10.96
  SubarrayTestCase constructor, item, 10, 0, 100, 0.96, 10.01
  SubarrayTestCase constructor, item, 10, 0, 100, 0.01, 10.01
  SubarrayTestCase constructor, item, 10, 0, 100, 0.01, 10.96
  SubarrayTestCase constructor, item, 10, 90, 100, 90
  SubarrayTestCase constructor, item, 10, 90, 100, -10
  method = constructor::subarray
  method.call new constructor(100), 0, 100
  o = {}
  assertThrows (->
    method.call o, 0, 100
    return
  ), TypeError
  return
TestTypedArrayOutOfRange = (constructor, value, result) ->
  a = new constructor(1)
  a[0] = value
  assertSame result, a[0]
  return
TestPropertyTypeChecks = (constructor) ->
  CheckProperty = (name) ->
    d = Object.getOwnPropertyDescriptor(constructor::, name)
    o = {}
    assertThrows (->
      d.get.call o
      return
    ), TypeError
    i = 0

    while i < typedArrayConstructors.length
      ctor = typedArrayConstructors[i]
      a = new ctor(10)
      if ctor is constructor
        d.get.call a # shouldn't throw
      else
        assertThrows (->
          d.get.call a
          return
        ), TypeError
      i++
    return
  CheckProperty "buffer"
  CheckProperty "byteOffset"
  CheckProperty "byteLength"
  CheckProperty "length"
  return
TestTypedArraySet = ->
  
  # Test array.set in different combinations.
  assertArrayPrefix = (expected, array) ->
    i = 0

    while i < expected.length
      assertEquals expected[i], array[i]
      ++i
    return
  a11 = new Int16Array([
    1
    2
    3
    4
    0
    -1
  ])
  a12 = new Uint16Array(15)
  a12.set a11, 3
  assertArrayPrefix [
    0
    0
    0
    1
    2
    3
    4
    0
    0xffff
    0
    0
  ], a12
  assertThrows ->
    a11.set a12
    return

  a21 = [
    1
    `undefined`
    10
    NaN
    0
    -1
    {
      valueOf: ->
        3
    }
  ]
  a22 = new Int32Array(12)
  a22.set a21, 2
  assertArrayPrefix [
    0
    0
    1
    0
    10
    0
    0
    -1
    3
    0
  ], a22
  a31 = new Float32Array([
    2
    4
    6
    8
    11
    NaN
    1 / 0
    -3
  ])
  a32 = a31.subarray(2, 6)
  a31.set a32, 4
  assertArrayPrefix [
    2
    4
    6
    8
    6
    8
    11
    NaN
  ], a31
  assertArrayPrefix [
    6
    8
    6
    8
  ], a32
  a4 = new Uint8ClampedArray([
    3
    2
    5
    6
  ])
  a4.set a4
  assertArrayPrefix [
    3
    2
    5
    6
  ], a4
  
  # Cases with overlapping backing store but different element sizes.
  b = new ArrayBuffer(4)
  a5 = new Int16Array(b)
  a50 = new Int8Array(b)
  a51 = new Int8Array(b, 0, 2)
  a52 = new Int8Array(b, 1, 2)
  a53 = new Int8Array(b, 2, 2)
  a5.set [
    0x5050
    0x0a0a
  ]
  assertArrayPrefix [
    0x50
    0x50
    0x0a
    0x0a
  ], a50
  assertArrayPrefix [
    0x50
    0x50
  ], a51
  assertArrayPrefix [
    0x50
    0x0a
  ], a52
  assertArrayPrefix [
    0x0a
    0x0a
  ], a53
  a50.set [
    0x50
    0x50
    0x0a
    0x0a
  ]
  a51.set a5
  assertArrayPrefix [
    0x50
    0x0a
    0x0a
    0x0a
  ], a50
  a50.set [
    0x50
    0x50
    0x0a
    0x0a
  ]
  a52.set a5
  assertArrayPrefix [
    0x50
    0x50
    0x0a
    0x0a
  ], a50
  a50.set [
    0x50
    0x50
    0x0a
    0x0a
  ]
  a53.set a5
  assertArrayPrefix [
    0x50
    0x50
    0x50
    0x0a
  ], a50
  a50.set [
    0x50
    0x51
    0x0a
    0x0b
  ]
  a5.set a51
  assertArrayPrefix [
    0x0050
    0x0051
  ], a5
  a50.set [
    0x50
    0x51
    0x0a
    0x0b
  ]
  a5.set a52
  assertArrayPrefix [
    0x0051
    0x000a
  ], a5
  a50.set [
    0x50
    0x51
    0x0a
    0x0b
  ]
  a5.set a53
  assertArrayPrefix [
    0x000a
    0x000b
  ], a5
  
  # Mixed types of same size.
  a61 = new Float32Array([
    1.2
    12.3
  ])
  a62 = new Int32Array(2)
  a62.set a61
  assertArrayPrefix [
    1
    12
  ], a62
  a61.set a62
  assertArrayPrefix [
    1
    12
  ], a61
  
  # Invalid source
  a = new Uint16Array(50)
  expected = []
  i = 0
  while i < 50
    a[i] = i
    expected.push i
    i++
  a.set {}
  assertArrayPrefix expected, a
  assertThrows (->
    a.set.call {}
    return
  ), TypeError
  assertThrows (->
    a.set.call []
    return
  ), TypeError
  assertThrows (->
    a.set 0
    return
  ), TypeError
  assertThrows (->
    a.set 0, 1
    return
  ), TypeError
  return
TestTypedArraysWithIllegalIndices = ->
  a = new Int32Array(100)
  a[-10] = 10
  assertEquals `undefined`, a[-10]
  a["-10"] = 10
  assertEquals `undefined`, a["-10"]
  s = "    -10"
  a[s] = 10
  assertEquals 10, a[s]
  s1 = "    -10   "
  a[s] = 10
  assertEquals 10, a[s]
  a["-1e2"] = 10
  assertEquals 10, a["-1e2"]
  assertEquals `undefined`, a[-1e2]
  a["-0"] = 256
  s2 = "     -0"
  a[s2] = 255
  assertEquals `undefined`, a["-0"]
  assertEquals 255, a[s2]
  assertEquals 0, a[-0]
  
  # Chromium bug: 424619
  #   * a[-Infinity] = 50;
  #   * assertEquals(undefined, a[-Infinity]);
  #   
  a[1.5] = 10
  assertEquals `undefined`, a[1.5]
  nan = Math.sqrt(-1)
  a[nan] = 5
  assertEquals 5, a[nan]
  x = 0
  y = -0
  assertEquals Infinity, 1 / x
  assertEquals -Infinity, 1 / y
  a[x] = 5
  a[y] = 27
  assertEquals 27, a[x]
  assertEquals 27, a[y]
  return
TestTypedArraysWithIllegalIndicesStrict = ->
  "use strict"
  a = new Int32Array(100)
  a[-10] = 10
  assertEquals `undefined`, a[-10]
  a["-10"] = 10
  assertEquals `undefined`, a["-10"]
  s = "    -10"
  a[s] = 10
  assertEquals 10, a[s]
  s1 = "    -10   "
  a[s] = 10
  assertEquals 10, a[s]
  a["-1e2"] = 10
  assertEquals 10, a["-1e2"]
  assertEquals `undefined`, a[-1e2]
  a["-0"] = 256
  s2 = "     -0"
  a[s2] = 255
  assertEquals `undefined`, a["-0"]
  assertEquals 255, a[s2]
  assertEquals 0, a[-0]
  
  # Chromium bug: 424619
  #   * a[-Infinity] = 50;
  #   * assertEquals(undefined, a[-Infinity]);
  #   
  a[1.5] = 10
  assertEquals `undefined`, a[1.5]
  nan = Math.sqrt(-1)
  a[nan] = 5
  assertEquals 5, a[nan]
  x = 0
  y = -0
  assertEquals Infinity, 1 / x
  assertEquals -Infinity, 1 / y
  a[x] = 5
  a[y] = 27
  assertEquals 27, a[x]
  assertEquals 27, a[y]
  return

# DataView
TestDataViewConstructor = ->
  ab = new ArrayBuffer(256)
  d1 = new DataView(ab, 1, 255)
  assertTrue ArrayBuffer.isView(d1)
  assertSame ab, d1.buffer
  assertSame 1, d1.byteOffset
  assertSame 255, d1.byteLength
  d2 = new DataView(ab, 2)
  assertSame ab, d2.buffer
  assertSame 2, d2.byteOffset
  assertSame 254, d2.byteLength
  d3 = new DataView(ab)
  assertSame ab, d3.buffer
  assertSame 0, d3.byteOffset
  assertSame 256, d3.byteLength
  d3a = new DataView(ab, 1, 0)
  assertSame ab, d3a.buffer
  assertSame 1, d3a.byteOffset
  assertSame 0, d3a.byteLength
  d3b = new DataView(ab, 256, 0)
  assertSame ab, d3b.buffer
  assertSame 256, d3b.byteOffset
  assertSame 0, d3b.byteLength
  d3c = new DataView(ab, 256)
  assertSame ab, d3c.buffer
  assertSame 256, d3c.byteOffset
  assertSame 0, d3c.byteLength
  d4 = new DataView(ab, 1, 3.1415926)
  assertSame ab, d4.buffer
  assertSame 1, d4.byteOffset
  assertSame 3, d4.byteLength
  
  # error cases
  assertThrows (->
    new DataView(ab, -1)
    return
  ), RangeError
  assertThrows (->
    new DataView(ab, 1, -1)
    return
  ), RangeError
  assertThrows (->
    new DataView()
    return
  ), TypeError
  assertThrows (->
    new DataView([])
    return
  ), TypeError
  assertThrows (->
    new DataView(ab, 257)
    return
  ), RangeError
  assertThrows (->
    new DataView(ab, 1, 1024)
    return
  ), RangeError
  return
TestDataViewPropertyTypeChecks = ->
  CheckProperty = (name) ->
    d = Object.getOwnPropertyDescriptor(DataView::, name)
    o = {}
    assertThrows (->
      d.get.call o
      return
    ), TypeError
    d.get.call a # shouldn't throw
    return
  a = new DataView(new ArrayBuffer(10))
  CheckProperty "buffer"
  CheckProperty "byteOffset"
  CheckProperty "byteLength"
  return
TestDataViewToStringTag = ->
  a = new DataView(new ArrayBuffer(10))
  assertEquals "[object DataView]", Object::toString.call(a)
  desc = Object.getOwnPropertyDescriptor(DataView::, Symbol.toStringTag)
  assertTrue desc.configurable
  assertFalse desc.enumerable
  assertFalse desc.writable
  assertEquals "DataView", desc.value
  return

# General tests for properties

# Test property attribute [[Enumerable]]
TestEnumerable = (func, obj) ->
  props = (x) ->
    array = []
    for p of x
      array.push p
    array.sort()
  assertArrayEquals [], props(func)
  assertArrayEquals [], props(func::)
  assertArrayEquals [], props(obj)  if obj
  return

# Test arbitrary properties on ArrayBuffer
TestArbitrary = (m) ->
  TestProperty = (map, property, value) ->
    map[property] = value
    assertEquals value, map[property]
    return
  i = 0

  while i < 20
    TestProperty m, "key" + i, "val" + i
    TestProperty m, "foo" + i, "bar" + i
    i++
  return
TestArrayBufferCreation()
TestByteLengthNotWritable()
TestArrayBufferSlice()
TestTypedArray Uint8Array, 1, 0xff
TestTypedArray Int8Array, 1, -0x7f
TestTypedArray Uint16Array, 2, 0xffff
TestTypedArray Int16Array, 2, -0x7fff
TestTypedArray Uint32Array, 4, 0xffffffff
TestTypedArray Int32Array, 4, -0x7fffffff
TestTypedArray Float32Array, 4, 0.5
TestTypedArray Float64Array, 8, 0.5
TestTypedArray Uint8ClampedArray, 1, 0xff
TestSubArray Uint8Array, 0xff
TestSubArray Int8Array, -0x7f
TestSubArray Uint16Array, 0xffff
TestSubArray Int16Array, -0x7fff
TestSubArray Uint32Array, 0xffffffff
TestSubArray Int32Array, -0x7fffffff
TestSubArray Float32Array, 0.5
TestSubArray Float64Array, 0.5
TestSubArray Uint8ClampedArray, 0xff
TestTypedArrayOutOfRange Uint8Array, 0x1fa, 0xfa
TestTypedArrayOutOfRange Uint8Array, -1, 0xff
TestTypedArrayOutOfRange Int8Array, 0x1fa, 0x7a - 0x80
TestTypedArrayOutOfRange Uint16Array, 0x1fffa, 0xfffa
TestTypedArrayOutOfRange Uint16Array, -1, 0xffff
TestTypedArrayOutOfRange Int16Array, 0x1fffa, 0x7ffa - 0x8000
TestTypedArrayOutOfRange Uint32Array, 0x1fffffffa, 0xfffffffa
TestTypedArrayOutOfRange Uint32Array, -1, 0xffffffff
TestTypedArrayOutOfRange Int32Array, 0x1fffffffa, 0x7ffffffa - 0x80000000
TestTypedArrayOutOfRange Uint8ClampedArray, 0x1fa, 0xff
TestTypedArrayOutOfRange Uint8ClampedArray, -1, 0
typedArrayConstructors = [
  Uint8Array
  Int8Array
  Uint16Array
  Int16Array
  Uint32Array
  Int32Array
  Uint8ClampedArray
  Float32Array
  Float64Array
]
i = 0
while i < typedArrayConstructors.length
  TestPropertyTypeChecks typedArrayConstructors[i]
  i++
TestTypedArraySet()
TestTypedArraysWithIllegalIndices()
TestTypedArraysWithIllegalIndicesStrict()
TestDataViewConstructor()
TestDataViewPropertyTypeChecks()
TestEnumerable ArrayBuffer, new ArrayBuffer()
i = 0
while i < typedArrayConstructors.length
  TestEnumerable typedArrayConstructors[i]
  i++
TestEnumerable DataView, new DataView(new ArrayBuffer())
TestArbitrary new ArrayBuffer(256)
i = 0
while i < typedArrayConstructors.length
  TestArbitrary new typedArrayConstructors[i](10)
  i++
TestArbitrary new DataView(new ArrayBuffer(256))

# Test direct constructor call
assertThrows (->
  ArrayBuffer()
  return
), TypeError
assertThrows (->
  DataView new ArrayBuffer()
  return
), TypeError
