# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --harmony-strings

# Tests taken from:
# https://github.com/mathiasbynens/String.fromCodePoint
assertEquals String.fromCodePoint.length, 1
assertEquals String.propertyIsEnumerable("fromCodePoint"), false
assertEquals String.fromCodePoint(""), "\u0000"
assertEquals String.fromCodePoint(), ""
assertEquals String.fromCodePoint(-0), "\u0000"
assertEquals String.fromCodePoint(0), "\u0000"
assertEquals String.fromCodePoint(0x1d306), "𝌆"
assertEquals String.fromCodePoint(0x1d306, 0x61, 0x1d307), "𝌆a𝌇"
assertEquals String.fromCodePoint(0x61, 0x62, 0x1d307), "ab𝌇"
assertEquals String.fromCodePoint(false), "\u0000"
assertEquals String.fromCodePoint(null), "\u0000"
assertThrows (->
  String.fromCodePoint "_"
  return
), RangeError
assertThrows (->
  String.fromCodePoint "+Infinity"
  return
), RangeError
assertThrows (->
  String.fromCodePoint "-Infinity"
  return
), RangeError
assertThrows (->
  String.fromCodePoint -1
  return
), RangeError
assertThrows (->
  String.fromCodePoint 0x10ffff + 1
  return
), RangeError
assertThrows (->
  String.fromCodePoint 3.14
  return
), RangeError
assertThrows (->
  String.fromCodePoint 3e-2
  return
), RangeError
assertThrows (->
  String.fromCodePoint -Infinity
  return
), RangeError
assertThrows (->
  String.fromCodePoint +Infinity
  return
), RangeError
assertThrows (->
  String.fromCodePoint NaN
  return
), RangeError
assertThrows (->
  String.fromCodePoint `undefined`
  return
), RangeError
assertThrows (->
  String.fromCodePoint {}
  return
), RangeError
assertThrows (->
  String.fromCodePoint /./
  return
), RangeError
assertThrows (->
  String.fromCodePoint valueOf: ->
    throw Error()return

  return
), Error
assertThrows (->
  String.fromCodePoint valueOf: ->
    throw Error()return

  return
), Error
tmp = 0x60
assertEquals String.fromCodePoint(valueOf: ->
  ++tmp
  tmp
), "a"
assertEquals tmp, 0x61
counter = Math.pow(2, 15) * 3 / 2
result = []
result.push 0  while --counter >= 0 # one code unit per symbol
String.fromCodePoint.apply null, result # must not throw
counter = Math.pow(2, 15) * 3 / 2
result = []
result.push 0xffff + 1  while --counter >= 0 # two code units per symbol
String.fromCodePoint.apply null, result # must not throw
