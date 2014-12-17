# Copyright 2014 the V8 project authors. All rights reserved.
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

# Flags: --harmony-strings
testNonStringValues = ->
  i = 0
  l = TEST_INPUT.length
  while i < l
    e = TEST_INPUT[i]
    v = e.val
    s = String(v)
    assertTrue s.endsWith(v), e.msg
    assertTrue String::endsWith.call(v, v), e.msg
    assertTrue String::endsWith.apply(v, [v]), e.msg
    i++
  return
testCutomType = ->
  i = 0
  l = TEST_INPUT.length
  while i < l
    e = TEST_INPUT[i]
    v = e.val
    o = new CustomType(v)
    assertTrue o.endsWith(v), e.msg
    i++
  return
assertEquals 1, String::endsWith.length
testString = "Hello World"
assertTrue testString.endsWith("")
assertTrue testString.endsWith("World")
assertFalse testString.endsWith("world")
assertFalse testString.endsWith("Hello World!")
assertFalse testString.endsWith(null)
assertFalse testString.endsWith(`undefined`)
assertTrue "null".endsWith(null)
assertTrue "undefined".endsWith(`undefined`)
georgianUnicodeString = "აბგდევზთ"
assertTrue georgianUnicodeString.endsWith(georgianUnicodeString)
assertTrue georgianUnicodeString.endsWith("ევზთ")
assertFalse georgianUnicodeString.endsWith("ა")
assertThrows "String.prototype.endsWith.call(null, 'test')", TypeError
assertThrows "String.prototype.endsWith.call(null, null)", TypeError
assertThrows "String.prototype.endsWith.call(undefined, undefined)", TypeError
assertThrows "String.prototype.endsWith.apply(null, ['test'])", TypeError
assertThrows "String.prototype.endsWith.apply(null, [null])", TypeError
assertThrows "String.prototype.endsWith.apply(undefined, [undefined])", TypeError
TEST_INPUT = [
  {
    msg: "Empty string"
    val: ""
  }
  {
    msg: "Number 1234.34"
    val: 1234.34
  }
  {
    msg: "Integer number 0"
    val: 0
  }
  {
    msg: "Negative number -1"
    val: -1
  }
  {
    msg: "Boolean true"
    val: true
  }
  {
    msg: "Boolean false"
    val: false
  }
  {
    msg: "Empty array []"
    val: []
  }
  {
    msg: "Empty object {}"
    val: {}
  }
  {
    msg: "Array of size 3"
    val: new Array(3)
  }
]
testNonStringValues()
CustomType = (value) ->
  @endsWith = String::endsWith
  @toString = ->
    String value

  return

testCutomType()

# Test cases found in FF
assertTrue "abc".endsWith("abc")
assertTrue "abcd".endsWith("bcd")
assertTrue "abc".endsWith("c")
assertFalse "abc".endsWith("abcd")
assertFalse "abc".endsWith("bbc")
assertFalse "abc".endsWith("b")
assertTrue "abc".endsWith("abc", 3)
assertTrue "abc".endsWith("bc", 3)
assertFalse "abc".endsWith("a", 3)
assertTrue "abc".endsWith("bc", 3)
assertTrue "abc".endsWith("a", 1)
assertFalse "abc".endsWith("abc", 1)
assertTrue "abc".endsWith("b", 2)
assertFalse "abc".endsWith("d", 2)
assertFalse "abc".endsWith("dcd", 2)
assertFalse "abc".endsWith("a", 42)
assertTrue "abc".endsWith("bc", Infinity)
assertFalse "abc".endsWith("a", Infinity)
assertTrue "abc".endsWith("bc", `undefined`)
assertFalse "abc".endsWith("bc", -43)
assertFalse "abc".endsWith("bc", -Infinity)
assertFalse "abc".endsWith("bc", NaN)

# Test cases taken from
# https://github.com/mathiasbynens/String.prototype.endsWith/blob/master/tests/tests.js
Object::[1] = 2 # try to break `arguments[1]`
assertEquals String::endsWith.length, 1
assertEquals String::propertyIsEnumerable("endsWith"), false
assertEquals "undefined".endsWith(), true
assertEquals "undefined".endsWith(`undefined`), true
assertEquals "undefined".endsWith(null), false
assertEquals "null".endsWith(), false
assertEquals "null".endsWith(`undefined`), false
assertEquals "null".endsWith(null), true
assertEquals "abc".endsWith(), false
assertEquals "abc".endsWith(""), true
assertEquals "abc".endsWith("\u0000"), false
assertEquals "abc".endsWith("c"), true
assertEquals "abc".endsWith("b"), false
assertEquals "abc".endsWith("ab"), false
assertEquals "abc".endsWith("bc"), true
assertEquals "abc".endsWith("abc"), true
assertEquals "abc".endsWith("bcd"), false
assertEquals "abc".endsWith("abcd"), false
assertEquals "abc".endsWith("bcde"), false
assertEquals "abc".endsWith("", NaN), true
assertEquals "abc".endsWith("\u0000", NaN), false
assertEquals "abc".endsWith("c", NaN), false
assertEquals "abc".endsWith("b", NaN), false
assertEquals "abc".endsWith("ab", NaN), false
assertEquals "abc".endsWith("bc", NaN), false
assertEquals "abc".endsWith("abc", NaN), false
assertEquals "abc".endsWith("bcd", NaN), false
assertEquals "abc".endsWith("abcd", NaN), false
assertEquals "abc".endsWith("bcde", NaN), false
assertEquals "abc".endsWith("", false), true
assertEquals "abc".endsWith("\u0000", false), false
assertEquals "abc".endsWith("c", false), false
assertEquals "abc".endsWith("b", false), false
assertEquals "abc".endsWith("ab", false), false
assertEquals "abc".endsWith("bc", false), false
assertEquals "abc".endsWith("abc", false), false
assertEquals "abc".endsWith("bcd", false), false
assertEquals "abc".endsWith("abcd", false), false
assertEquals "abc".endsWith("bcde", false), false
assertEquals "abc".endsWith("", `undefined`), true
assertEquals "abc".endsWith("\u0000", `undefined`), false
assertEquals "abc".endsWith("c", `undefined`), true
assertEquals "abc".endsWith("b", `undefined`), false
assertEquals "abc".endsWith("ab", `undefined`), false
assertEquals "abc".endsWith("bc", `undefined`), true
assertEquals "abc".endsWith("abc", `undefined`), true
assertEquals "abc".endsWith("bcd", `undefined`), false
assertEquals "abc".endsWith("abcd", `undefined`), false
assertEquals "abc".endsWith("bcde", `undefined`), false
assertEquals "abc".endsWith("", null), true
assertEquals "abc".endsWith("\u0000", null), false
assertEquals "abc".endsWith("c", null), false
assertEquals "abc".endsWith("b", null), false
assertEquals "abc".endsWith("ab", null), false
assertEquals "abc".endsWith("bc", null), false
assertEquals "abc".endsWith("abc", null), false
assertEquals "abc".endsWith("bcd", null), false
assertEquals "abc".endsWith("abcd", null), false
assertEquals "abc".endsWith("bcde", null), false
assertEquals "abc".endsWith("", -Infinity), true
assertEquals "abc".endsWith("\u0000", -Infinity), false
assertEquals "abc".endsWith("c", -Infinity), false
assertEquals "abc".endsWith("b", -Infinity), false
assertEquals "abc".endsWith("ab", -Infinity), false
assertEquals "abc".endsWith("bc", -Infinity), false
assertEquals "abc".endsWith("abc", -Infinity), false
assertEquals "abc".endsWith("bcd", -Infinity), false
assertEquals "abc".endsWith("abcd", -Infinity), false
assertEquals "abc".endsWith("bcde", -Infinity), false
assertEquals "abc".endsWith("", -1), true
assertEquals "abc".endsWith("\u0000", -1), false
assertEquals "abc".endsWith("c", -1), false
assertEquals "abc".endsWith("b", -1), false
assertEquals "abc".endsWith("ab", -1), false
assertEquals "abc".endsWith("bc", -1), false
assertEquals "abc".endsWith("abc", -1), false
assertEquals "abc".endsWith("bcd", -1), false
assertEquals "abc".endsWith("abcd", -1), false
assertEquals "abc".endsWith("bcde", -1), false
assertEquals "abc".endsWith("", -0), true
assertEquals "abc".endsWith("\u0000", -0), false
assertEquals "abc".endsWith("c", -0), false
assertEquals "abc".endsWith("b", -0), false
assertEquals "abc".endsWith("ab", -0), false
assertEquals "abc".endsWith("bc", -0), false
assertEquals "abc".endsWith("abc", -0), false
assertEquals "abc".endsWith("bcd", -0), false
assertEquals "abc".endsWith("abcd", -0), false
assertEquals "abc".endsWith("bcde", -0), false
assertEquals "abc".endsWith("", +0), true
assertEquals "abc".endsWith("\u0000", +0), false
assertEquals "abc".endsWith("c", +0), false
assertEquals "abc".endsWith("b", +0), false
assertEquals "abc".endsWith("ab", +0), false
assertEquals "abc".endsWith("bc", +0), false
assertEquals "abc".endsWith("abc", +0), false
assertEquals "abc".endsWith("bcd", +0), false
assertEquals "abc".endsWith("abcd", +0), false
assertEquals "abc".endsWith("bcde", +0), false
assertEquals "abc".endsWith("", 1), true
assertEquals "abc".endsWith("\u0000", 1), false
assertEquals "abc".endsWith("c", 1), false
assertEquals "abc".endsWith("b", 1), false
assertEquals "abc".endsWith("ab", 1), false
assertEquals "abc".endsWith("bc", 1), false
assertEquals "abc".endsWith("abc", 1), false
assertEquals "abc".endsWith("bcd", 1), false
assertEquals "abc".endsWith("abcd", 1), false
assertEquals "abc".endsWith("bcde", 1), false
assertEquals "abc".endsWith("", 2), true
assertEquals "abc".endsWith("\u0000", 2), false
assertEquals "abc".endsWith("c", 2), false
assertEquals "abc".endsWith("b", 2), true
assertEquals "abc".endsWith("ab", 2), true
assertEquals "abc".endsWith("bc", 2), false
assertEquals "abc".endsWith("abc", 2), false
assertEquals "abc".endsWith("bcd", 2), false
assertEquals "abc".endsWith("abcd", 2), false
assertEquals "abc".endsWith("bcde", 2), false
assertEquals "abc".endsWith("", +Infinity), true
assertEquals "abc".endsWith("\u0000", +Infinity), false
assertEquals "abc".endsWith("c", +Infinity), true
assertEquals "abc".endsWith("b", +Infinity), false
assertEquals "abc".endsWith("ab", +Infinity), false
assertEquals "abc".endsWith("bc", +Infinity), true
assertEquals "abc".endsWith("abc", +Infinity), true
assertEquals "abc".endsWith("bcd", +Infinity), false
assertEquals "abc".endsWith("abcd", +Infinity), false
assertEquals "abc".endsWith("bcde", +Infinity), false
assertEquals "abc".endsWith("", true), true
assertEquals "abc".endsWith("\u0000", true), false
assertEquals "abc".endsWith("c", true), false
assertEquals "abc".endsWith("b", true), false
assertEquals "abc".endsWith("ab", true), false
assertEquals "abc".endsWith("bc", true), false
assertEquals "abc".endsWith("abc", true), false
assertEquals "abc".endsWith("bcd", true), false
assertEquals "abc".endsWith("abcd", true), false
assertEquals "abc".endsWith("bcde", true), false
assertEquals "abc".endsWith("", "x"), true
assertEquals "abc".endsWith("\u0000", "x"), false
assertEquals "abc".endsWith("c", "x"), false
assertEquals "abc".endsWith("b", "x"), false
assertEquals "abc".endsWith("ab", "x"), false
assertEquals "abc".endsWith("bc", "x"), false
assertEquals "abc".endsWith("abc", "x"), false
assertEquals "abc".endsWith("bcd", "x"), false
assertEquals "abc".endsWith("abcd", "x"), false
assertEquals "abc".endsWith("bcde", "x"), false
assertEquals "[a-z]+(bar)?".endsWith("(bar)?"), true
assertThrows (->
  "[a-z]+(bar)?".endsWith /(bar)?/
  return
), TypeError
assertEquals "[a-z]+(bar)?".endsWith("[a-z]+", 6), true
assertThrows (->
  "[a-z]+(bar)?".endsWith /(bar)?/
  return
), TypeError
assertThrows (->
  "[a-z]+/(bar)?/".endsWith /(bar)?/
  return
), TypeError

# http://mathiasbynens.be/notes/javascript-unicode#poo-test
string = "Iñtërnâtiônàlizætiøn☃💩"
assertEquals string.endsWith(""), true
assertEquals string.endsWith("ñtër"), false
assertEquals string.endsWith("ñtër", 5), true
assertEquals string.endsWith("àlizæ"), false
assertEquals string.endsWith("àlizæ", 16), true
assertEquals string.endsWith("øn☃💩"), true
assertEquals string.endsWith("øn☃💩", 23), true
assertEquals string.endsWith("☃"), false
assertEquals string.endsWith("☃", 21), true
assertEquals string.endsWith("💩"), true
assertEquals string.endsWith("💩", 23), true
assertThrows (->
  String::endsWith.call `undefined`
  return
), TypeError
assertThrows (->
  String::endsWith.call `undefined`, "b"
  return
), TypeError
assertThrows (->
  String::endsWith.call `undefined`, "b", 4
  return
), TypeError
assertThrows (->
  String::endsWith.call null
  return
), TypeError
assertThrows (->
  String::endsWith.call null, "b"
  return
), TypeError
assertThrows (->
  String::endsWith.call null, "b", 4
  return
), TypeError
assertEquals String::endsWith.call(42, "2"), true
assertEquals String::endsWith.call(42, "4"), false
assertEquals String::endsWith.call(42, "b", 4), false
assertEquals String::endsWith.call(42, "2", 1), false
assertEquals String::endsWith.call(42, "2", 4), true
assertEquals String::endsWith.call(
  toString: ->
    "abc"
, "b", 0), false
assertEquals String::endsWith.call(
  toString: ->
    "abc"
, "b", 1), false
assertEquals String::endsWith.call(
  toString: ->
    "abc"
, "b", 2), true
assertThrows (->
  String::endsWith.call
    toString: ->
      throw RangeError()return
  , /./
  return
), RangeError
assertThrows (->
  String::endsWith.call
    toString: ->
      "abc"
  , /./
  return
), TypeError
assertThrows (->
  String::endsWith.apply `undefined`
  return
), TypeError
assertThrows (->
  String::endsWith.apply `undefined`, ["b"]
  return
), TypeError
assertThrows (->
  String::endsWith.apply `undefined`, [
    "b"
    4
  ]
  return
), TypeError
assertThrows (->
  String::endsWith.apply null
  return
), TypeError
assertThrows (->
  String::endsWith.apply null, ["b"]
  return
), TypeError
assertThrows (->
  String::endsWith.apply null, [
    "b"
    4
  ]
  return
), TypeError
assertEquals String::endsWith.apply(42, ["2"]), true
assertEquals String::endsWith.apply(42, ["4"]), false
assertEquals String::endsWith.apply(42, [
  "b"
  4
]), false
assertEquals String::endsWith.apply(42, [
  "2"
  1
]), false
assertEquals String::endsWith.apply(42, [
  "2"
  4
]), true
assertEquals String::endsWith.apply(
  toString: ->
    "abc"
, [
  "b"
  0
]), false
assertEquals String::endsWith.apply(
  toString: ->
    "abc"
, [
  "b"
  1
]), false
assertEquals String::endsWith.apply(
  toString: ->
    "abc"
, [
  "b"
  2
]), true
assertThrows (->
  String::endsWith.apply
    toString: ->
      throw RangeError()return
  , [/./]
  return
), RangeError
assertThrows (->
  String::endsWith.apply
    toString: ->
      "abc"
  , [/./]
  return
), TypeError
