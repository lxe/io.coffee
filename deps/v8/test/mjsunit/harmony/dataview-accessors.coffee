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

# These tests are adapted from Khronos DataView tests
getElementSize = (func) ->
  switch func
    when "Int8", "Uint8"
      1
    when "Int16", "Uint16"
      2
    when "Int32", "Uint32", "Float32"
      4
    when "Float64"
      8
    else
      assertUnreachable func
  return
checkGet = (func, index, expected, littleEndian) ->
  doGet = ->
    if littleEndian?
      view["get" + func] index, littleEndian
    else
      view["get" + func] index
  if index >= 0 and index + getElementSize(func) - 1 < view.byteLength
    assertSame expected, doGet()
  else
    assertThrows doGet, RangeError
  return
checkSet = (func, index, value, littleEndian) ->
  doSet = ->
    if littleEndian?
      view["set" + func] index, value, littleEndian
    else
      view["set" + func] index, value
    return
  if index >= 0 and index + getElementSize(func) - 1 < view.byteLength
    assertSame `undefined`, doSet()
    checkGet func, index, value, littleEndian
  else
    assertThrows doSet, RangeError
  return
test = (isTestingGet, func, index, value, littleEndian) ->
  if isTestingGet
    checkGet func, index, value, littleEndian
  else
    checkSet func, index, value, littleEndian
  return
createDataView = (array, frontPaddingNum, littleEndian, start, length) ->
  array.reverse()  unless littleEndian
  paddingArray = new Array(frontPaddingNum)
  arrayBuffer = (new Uint8Array(paddingArray.concat(array))).buffer
  view = new DataView(arrayBuffer, viewStart, viewLength)
  array.reverse()  unless littleEndian # restore the array.
  return
runIntegerTestCases = (isTestingGet, array, start, length) ->
  createDataView array, 0, true, start, length
  test isTestingGet, "Int8", 0, 0
  test isTestingGet, "Int8", `undefined`, 0
  test isTestingGet, "Int8", 8, -128
  test isTestingGet, "Int8", 15, -1
  test isTestingGet, "Int8", 1e12, `undefined`
  test isTestingGet, "Uint8", 0, 0
  test isTestingGet, "Uint8", `undefined`, 0
  test isTestingGet, "Uint8", 8, 128
  test isTestingGet, "Uint8", 15, 255
  test isTestingGet, "Uint8", 1e12, `undefined`
  
  # Little endian.
  test isTestingGet, "Int16", 0, 256, true
  test isTestingGet, "Int16", `undefined`, 256, true
  test isTestingGet, "Int16", 5, 26213, true
  test isTestingGet, "Int16", 9, -32127, true
  test isTestingGet, "Int16", 14, -2, true
  test isTestingGet, "Int16", 1e12, `undefined`, true
  
  # Big endian.
  test isTestingGet, "Int16", 0, 1
  test isTestingGet, "Int16", `undefined`, 1
  test isTestingGet, "Int16", 5, 25958
  test isTestingGet, "Int16", 9, -32382
  test isTestingGet, "Int16", 14, -257
  test isTestingGet, "Int16", 1e12, `undefined`
  
  # Little endian.
  test isTestingGet, "Uint16", 0, 256, true
  test isTestingGet, "Uint16", `undefined`, 256, true
  test isTestingGet, "Uint16", 5, 26213, true
  test isTestingGet, "Uint16", 9, 33409, true
  test isTestingGet, "Uint16", 14, 65534, true
  test isTestingGet, "Uint16", 1e12, `undefined`, true
  
  # Big endian.
  test isTestingGet, "Uint16", 0, 1
  test isTestingGet, "Uint16", `undefined`, 1
  test isTestingGet, "Uint16", 5, 25958
  test isTestingGet, "Uint16", 9, 33154
  test isTestingGet, "Uint16", 14, 65279
  test isTestingGet, "Uint16", 1e12, `undefined`
  
  # Little endian.
  test isTestingGet, "Int32", 0, 50462976, true
  test isTestingGet, "Int32", `undefined`, 50462976, true
  test isTestingGet, "Int32", 3, 1717920771, true
  test isTestingGet, "Int32", 6, -2122291354, true
  test isTestingGet, "Int32", 9, -58490239, true
  test isTestingGet, "Int32", 12, -66052, true
  test isTestingGet, "Int32", 1e12, `undefined`, true
  
  # Big endian.
  test isTestingGet, "Int32", 0, 66051
  test isTestingGet, "Int32", `undefined`, 66051
  test isTestingGet, "Int32", 3, 56911206
  test isTestingGet, "Int32", 6, 1718059137
  test isTestingGet, "Int32", 9, -2122152964
  test isTestingGet, "Int32", 12, -50462977
  test isTestingGet, "Int32", 1e12, `undefined`
  
  # Little endian.
  test isTestingGet, "Uint32", 0, 50462976, true
  test isTestingGet, "Uint32", `undefined`, 50462976, true
  test isTestingGet, "Uint32", 3, 1717920771, true
  test isTestingGet, "Uint32", 6, 2172675942, true
  test isTestingGet, "Uint32", 9, 4236477057, true
  test isTestingGet, "Uint32", 12, 4294901244, true
  test isTestingGet, "Uint32", 1e12, `undefined`, true
  
  # Big endian.
  test isTestingGet, "Uint32", 0, 66051
  test isTestingGet, "Uint32", `undefined`, 66051
  test isTestingGet, "Uint32", 3, 56911206
  test isTestingGet, "Uint32", 6, 1718059137
  test isTestingGet, "Uint32", 9, 2172814332
  test isTestingGet, "Uint32", 12, 4244504319
  test isTestingGet, "Uint32", 1e12, `undefined`
  return
testFloat = (isTestingGet, func, array, start, expected) ->
  
  # Little endian.
  createDataView array, 0, true, start
  test isTestingGet, func, 0, expected, true
  test isTestingGet, func, `undefined`, expected, true
  createDataView array, 3, true, start
  test isTestingGet, func, 3, expected, true
  createDataView array, 7, true, start
  test isTestingGet, func, 7, expected, true
  createDataView array, 10, true, start
  test isTestingGet, func, 10, expected, true
  test isTestingGet, func, 1e12, `undefined`, true
  
  # Big endian.
  createDataView array, 0, false
  test isTestingGet, func, 0, expected, false
  test isTestingGet, func, `undefined`, expected, false
  createDataView array, 3, false
  test isTestingGet, func, 3, expected, false
  createDataView array, 7, false
  test isTestingGet, func, 7, expected, false
  createDataView array, 10, false
  test isTestingGet, func, 10, expected, false
  test isTestingGet, func, 1e12, `undefined`, false
  return
runFloatTestCases = (isTestingGet, start) ->
  testFloat isTestingGet, "Float32", (if isTestingGet then [
    0
    0
    32
    65
  ] else initialArray), start, 10
  testFloat isTestingGet, "Float32", (if isTestingGet then [
    164
    112
    157
    63
  ] else initialArray), start, 1.2300000190734863
  testFloat isTestingGet, "Float32", (if isTestingGet then [
    95
    53
    50
    199
  ] else initialArray), start, -45621.37109375
  testFloat isTestingGet, "Float32", (if isTestingGet then [
    255
    255
    255
    127
  ] else initialArray), start, NaN
  testFloat isTestingGet, "Float32", (if isTestingGet then [
    255
    255
    255
    255
  ] else initialArray), start, -NaN
  testFloat isTestingGet, "Float64", (if isTestingGet then [
    0
    0
    0
    0
    0
    0
    36
    64
  ] else initialArray), start, 10
  testFloat isTestingGet, "Float64", (if isTestingGet then [
    174
    71
    225
    122
    20
    174
    243
    63
  ] else initialArray), start, 1.23
  testFloat isTestingGet, "Float64", (if isTestingGet then [
    181
    55
    248
    30
    242
    179
    87
    193
  ] else initialArray), start, -6213576.4839
  testFloat isTestingGet, "Float64", (if isTestingGet then [
    255
    255
    255
    255
    255
    255
    255
    127
  ] else initialArray), start, NaN
  testFloat isTestingGet, "Float64", (if isTestingGet then [
    255
    255
    255
    255
    255
    255
    255
    255
  ] else initialArray), start, -NaN
  return
runNegativeIndexTests = (isTestingGet) ->
  createDataView intArray1, 0, true, 0, 16
  test isTestingGet, "Int8", -1, 0
  test isTestingGet, "Int8", -2, 0
  test isTestingGet, "Uint8", -1, 0
  test isTestingGet, "Uint8", -2, 0
  test isTestingGet, "Int16", -1, 1
  test isTestingGet, "Int16", -2, 1
  test isTestingGet, "Int16", -3, 1
  test isTestingGet, "Uint16", -1, 1
  test isTestingGet, "Uint16", -2, 1
  test isTestingGet, "Uint16", -3, 1
  test isTestingGet, "Int32", -1, 66051
  test isTestingGet, "Int32", -3, 66051
  test isTestingGet, "Int32", -5, 66051
  test isTestingGet, "Uint32", -1, 66051
  test isTestingGet, "Uint32", -3, 66051
  test isTestingGet, "Uint32", -5, 66051
  createDataView [
    0
    0
    0
    0
    0
    0
    0
    0
  ], 0, true, 0, 8
  test isTestingGet, "Float32", -1, 0
  test isTestingGet, "Float32", -3, 0
  test isTestingGet, "Float32", -5, 0
  test isTestingGet, "Float64", -1, 0
  test isTestingGet, "Float64", -5, 0
  test isTestingGet, "Float64", -9, 0
  return
TestGetters = ->
  runIntegerTestCases true, intArray1, 0, 16
  runFloatTestCases true, 0
  runIntegerTestCases true, intArray2, 3, 2
  runFloatTestCases true, 3
  runNegativeIndexTests true
  return
TestSetters = ->
  runIntegerTestCases false, initialArray, 0, 16
  runFloatTestCases false
  runIntegerTestCases false, initialArray, 3, 2
  runFloatTestCases false, 7
  runNegativeIndexTests false
  return
CheckOutOfRangeInt8 = (value, expected) ->
  view = new DataView(new ArrayBuffer(100))
  assertSame `undefined`, view.setInt8(0, value)
  assertSame expected, view.getInt8(0)
  assertSame `undefined`, view.setInt8(0, value, true)
  assertSame expected, view.getInt8(0, true)
  return
CheckOutOfRangeUint8 = (value, expected) ->
  view = new DataView(new ArrayBuffer(100))
  assertSame `undefined`, view.setUint8(0, value)
  assertSame expected, view.getUint8(0)
  assertSame `undefined`, view.setUint8(0, value, true)
  assertSame expected, view.getUint8(0, true)
  return
CheckOutOfRangeInt16 = (value, expected) ->
  view = new DataView(new ArrayBuffer(100))
  assertSame `undefined`, view.setInt16(0, value)
  assertSame expected, view.getInt16(0)
  assertSame `undefined`, view.setInt16(0, value, true)
  assertSame expected, view.getInt16(0, true)
  return
CheckOutOfRangeUint16 = (value, expected) ->
  view = new DataView(new ArrayBuffer(100))
  assertSame `undefined`, view.setUint16(0, value)
  assertSame expected, view.getUint16(0)
  assertSame `undefined`, view.setUint16(0, value, true)
  assertSame expected, view.getUint16(0, true)
  return
CheckOutOfRangeInt32 = (value, expected) ->
  view = new DataView(new ArrayBuffer(100))
  assertSame `undefined`, view.setInt32(0, value)
  assertSame expected, view.getInt32(0)
  assertSame `undefined`, view.setInt32(0, value, true)
  assertSame expected, view.getInt32(0, true)
  return
CheckOutOfRangeUint32 = (value, expected) ->
  view = new DataView(new ArrayBuffer(100))
  assertSame `undefined`, view.setUint32(0, value)
  assertSame expected, view.getUint32(0)
  assertSame `undefined`, view.setUint32(0, value, true)
  assertSame expected, view.getUint32(0, true)
  return
TestOutOfRange = ->
  CheckOutOfRangeInt8 0x80, -0x80
  CheckOutOfRangeInt8 0x1000, 0
  CheckOutOfRangeInt8 -0x81, 0x7f
  CheckOutOfRangeUint8 0x100, 0
  CheckOutOfRangeUint8 0x1000, 0
  CheckOutOfRangeUint8 -0x80, 0x80
  CheckOutOfRangeUint8 -1, 0xff
  CheckOutOfRangeUint8 -0xff, 1
  CheckOutOfRangeInt16 0x8000, -0x8000
  CheckOutOfRangeInt16 0x10000, 0
  CheckOutOfRangeInt16 -0x8001, 0x7fff
  CheckOutOfRangeUint16 0x10000, 0
  CheckOutOfRangeUint16 0x100000, 0
  CheckOutOfRangeUint16 -0x8000, 0x8000
  CheckOutOfRangeUint16 -1, 0xffff
  CheckOutOfRangeUint16 -0xffff, 1
  CheckOutOfRangeInt32 0x80000000, -0x80000000
  CheckOutOfRangeInt32 0x100000000, 0
  CheckOutOfRangeInt32 -0x80000001, 0x7fffffff
  CheckOutOfRangeUint32 0x100000000, 0
  CheckOutOfRangeUint32 0x1000000000, 0
  CheckOutOfRangeUint32 -0x80000000, 0x80000000
  CheckOutOfRangeUint32 -1, 0xffffffff
  CheckOutOfRangeUint32 -0xffffffff, 1
  return
TestGeneralAccessors = ->
  CheckAccessor = (name) ->
    f = a[name]
    assertThrows (->
      f()
      return
    ), TypeError
    f.call a, 0, 0 # should not throw
    assertThrows (->
      f.call {}, 0, 0
      return
    ), TypeError
    assertThrows (->
      f.call a
      return
    ), TypeError
    if name.indexOf("set") is 0
      assertThrows (->
        f.call a, 1
        return
      ), TypeError
    else
      f.call a, 1 # should not throw
    return
  a = new DataView(new ArrayBuffer(256))
  CheckAccessor "getUint8"
  CheckAccessor "setUint8"
  CheckAccessor "getInt8"
  CheckAccessor "setInt8"
  CheckAccessor "getUint16"
  CheckAccessor "setUint16"
  CheckAccessor "getInt16"
  CheckAccessor "setInt16"
  CheckAccessor "getUint32"
  CheckAccessor "setUint32"
  CheckAccessor "getInt32"
  CheckAccessor "setInt32"
  CheckAccessor "getFloat32"
  CheckAccessor "setFloat32"
  CheckAccessor "getFloat64"
  CheckAccessor "setFloat64"
  return
TestInsufficientArguments = ->
  a = new DataView(new ArrayBuffer(256))
  assertThrows (->
    a.getUint8()
    return
  ), TypeError
  assertThrows (->
    a.getInt8()
    return
  ), TypeError
  assertThrows (->
    a.getUint16()
    return
  ), TypeError
  assertThrows (->
    a.getInt16()
    return
  ), TypeError
  assertThrows (->
    a.getUint32()
    return
  ), TypeError
  assertThrows (->
    a.getInt32()
    return
  ), TypeError
  assertThrows (->
    a.getFloat32()
    return
  ), TypeError
  assertThrows (->
    a.getFloat64()
    return
  ), TypeError
  assertThrows (->
    a.setUint8()
    return
  ), TypeError
  assertThrows (->
    a.setInt8()
    return
  ), TypeError
  assertThrows (->
    a.setUint16()
    return
  ), TypeError
  assertThrows (->
    a.setInt16()
    return
  ), TypeError
  assertThrows (->
    a.setUint32()
    return
  ), TypeError
  assertThrows (->
    a.setInt32()
    return
  ), TypeError
  assertThrows (->
    a.setFloat32()
    return
  ), TypeError
  assertThrows (->
    a.setFloat64()
    return
  ), TypeError
  assertThrows (->
    a.setUint8 1
    return
  ), TypeError
  assertThrows (->
    a.setInt8 1
    return
  ), TypeError
  assertThrows (->
    a.setUint16 1
    return
  ), TypeError
  assertThrows (->
    a.setInt16 1
    return
  ), TypeError
  assertThrows (->
    a.setUint32 1
    return
  ), TypeError
  assertThrows (->
    a.setInt32 1
    return
  ), TypeError
  assertThrows (->
    a.setFloat32 1
    return
  ), TypeError
  assertThrows (->
    a.setFloat64 1
    return
  ), TypeError
  return
intArray1 = [
  0
  1
  2
  3
  100
  101
  102
  103
  128
  129
  130
  131
  252
  253
  254
  255
]
intArray2 = [
  31
  32
  33
  0
  1
  2
  3
  100
  101
  102
  103
  128
  129
  130
  131
  252
  253
  254
  255
]
initialArray = [
  204
  204
  204
  204
  204
  204
  204
  204
  204
  204
  204
  204
  204
  204
  204
  204
]
arayBuffer = null
view = null
viewStart = 0
viewLength = 0
TestGetters()
TestSetters()
TestOutOfRange()
TestGeneralAccessors()
TestInsufficientArguments()
