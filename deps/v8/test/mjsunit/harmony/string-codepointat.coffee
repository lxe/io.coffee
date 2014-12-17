# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --harmony-strings

# Tests taken from:
# https://github.com/mathiasbynens/String.prototype.codePointAt
assertEquals String::codePointAt.length, 1
assertEquals String::propertyIsEnumerable("codePointAt"), false

# String that starts with a BMP symbol
assertEquals "abc𝌆def".codePointAt(""), 0x61
assertEquals "abc𝌆def".codePointAt("_"), 0x61
assertEquals "abc𝌆def".codePointAt(), 0x61
assertEquals "abc𝌆def".codePointAt(-Infinity), `undefined`
assertEquals "abc𝌆def".codePointAt(-1), `undefined`
assertEquals "abc𝌆def".codePointAt(-0), 0x61
assertEquals "abc𝌆def".codePointAt(0), 0x61
assertEquals "abc𝌆def".codePointAt(3), 0x1d306
assertEquals "abc𝌆def".codePointAt(4), 0xdf06
assertEquals "abc𝌆def".codePointAt(5), 0x64
assertEquals "abc𝌆def".codePointAt(42), `undefined`
assertEquals "abc𝌆def".codePointAt(Infinity), `undefined`
assertEquals "abc𝌆def".codePointAt(Infinity), `undefined`
assertEquals "abc𝌆def".codePointAt(NaN), 0x61
assertEquals "abc𝌆def".codePointAt(false), 0x61
assertEquals "abc𝌆def".codePointAt(null), 0x61
assertEquals "abc𝌆def".codePointAt(`undefined`), 0x61

# String that starts with an astral symbol
assertEquals "𝌆def".codePointAt(""), 0x1d306
assertEquals "𝌆def".codePointAt("1"), 0xdf06
assertEquals "𝌆def".codePointAt("_"), 0x1d306
assertEquals "𝌆def".codePointAt(), 0x1d306
assertEquals "𝌆def".codePointAt(-1), `undefined`
assertEquals "𝌆def".codePointAt(-0), 0x1d306
assertEquals "𝌆def".codePointAt(0), 0x1d306
assertEquals "𝌆def".codePointAt(1), 0xdf06
assertEquals "𝌆def".codePointAt(42), `undefined`
assertEquals "𝌆def".codePointAt(false), 0x1d306
assertEquals "𝌆def".codePointAt(null), 0x1d306
assertEquals "𝌆def".codePointAt(`undefined`), 0x1d306

# Lone high surrogates
assertEquals "�abc".codePointAt(""), 0xd834
assertEquals "�abc".codePointAt("_"), 0xd834
assertEquals "�abc".codePointAt(), 0xd834
assertEquals "�abc".codePointAt(-1), `undefined`
assertEquals "�abc".codePointAt(-0), 0xd834
assertEquals "�abc".codePointAt(0), 0xd834
assertEquals "�abc".codePointAt(false), 0xd834
assertEquals "�abc".codePointAt(NaN), 0xd834
assertEquals "�abc".codePointAt(null), 0xd834
assertEquals "�abc".codePointAt(`undefined`), 0xd834

# Lone low surrogates
assertEquals "�abc".codePointAt(""), 0xdf06
assertEquals "�abc".codePointAt("_"), 0xdf06
assertEquals "�abc".codePointAt(), 0xdf06
assertEquals "�abc".codePointAt(-1), `undefined`
assertEquals "�abc".codePointAt(-0), 0xdf06
assertEquals "�abc".codePointAt(0), 0xdf06
assertEquals "�abc".codePointAt(false), 0xdf06
assertEquals "�abc".codePointAt(NaN), 0xdf06
assertEquals "�abc".codePointAt(null), 0xdf06
assertEquals "�abc".codePointAt(`undefined`), 0xdf06
assertThrows (->
  String::codePointAt.call `undefined`
  return
), TypeError
assertThrows (->
  String::codePointAt.call `undefined`, 4
  return
), TypeError
assertThrows (->
  String::codePointAt.call null
  return
), TypeError
assertThrows (->
  String::codePointAt.call null, 4
  return
), TypeError
assertEquals String::codePointAt.call(42, 0), 0x34
assertEquals String::codePointAt.call(42, 1), 0x32
assertEquals String::codePointAt.call(
  toString: ->
    "abc"
, 2), 0x63
tmp = 0
assertEquals String::codePointAt.call(
  toString: ->
    ++tmp
    String tmp
, 0), 0x31
assertEquals tmp, 1
