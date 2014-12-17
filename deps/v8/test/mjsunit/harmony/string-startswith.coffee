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
    assertTrue s.startsWith(v), e.msg
    assertTrue String::startsWith.call(v, v), e.msg
    assertTrue String::startsWith.apply(v, [v]), e.msg
    i++
  return
testCutomType = ->
  i = 0
  l = TEST_INPUT.length
  while i < l
    e = TEST_INPUT[i]
    v = e.val
    o = new CustomType(v)
    assertTrue o.startsWith(v), e.msg
    i++
  return
assertEquals 1, String::startsWith.length
testString = "Hello World"
assertTrue testString.startsWith("")
assertTrue testString.startsWith("Hello")
assertFalse testString.startsWith("hello")
assertFalse testString.startsWith("Hello World!")
assertFalse testString.startsWith(null)
assertFalse testString.startsWith(`undefined`)
assertTrue "null".startsWith(null)
assertTrue "undefined".startsWith(`undefined`)
georgianUnicodeString = "აბგდევზთ"
assertTrue georgianUnicodeString.startsWith(georgianUnicodeString)
assertTrue georgianUnicodeString.startsWith("აბგ")
assertFalse georgianUnicodeString.startsWith("ი")
assertThrows "String.prototype.startsWith.call(null, 'test')", TypeError
assertThrows "String.prototype.startsWith.call(null, null)", TypeError
assertThrows "String.prototype.startsWith.call(undefined, undefined)", TypeError
assertThrows "String.prototype.startsWith.apply(null, ['test'])", TypeError
assertThrows "String.prototype.startsWith.apply(null, [null])", TypeError
assertThrows "String.prototype.startsWith.apply(undefined, [undefined])", TypeError
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
  @startsWith = String::startsWith
  @toString = ->
    String value

  return

testCutomType()

# Test cases found in FF
assertTrue "abc".startsWith("abc")
assertTrue "abcd".startsWith("abc")
assertTrue "abc".startsWith("a")
assertFalse "abc".startsWith("abcd")
assertFalse "abc".startsWith("bcde")
assertFalse "abc".startsWith("b")
assertTrue "abc".startsWith("abc", 0)
assertFalse "abc".startsWith("bc", 0)
assertTrue "abc".startsWith("bc", 1)
assertFalse "abc".startsWith("c", 1)
assertFalse "abc".startsWith("abc", 1)
assertTrue "abc".startsWith("c", 2)
assertFalse "abc".startsWith("d", 2)
assertFalse "abc".startsWith("dcd", 2)
assertFalse "abc".startsWith("a", 42)
assertFalse "abc".startsWith("a", Infinity)
assertTrue "abc".startsWith("a", NaN)
assertFalse "abc".startsWith("b", NaN)
assertTrue "abc".startsWith("ab", -43)
assertTrue "abc".startsWith("ab", -Infinity)
assertFalse "abc".startsWith("bc", -42)
assertFalse "abc".startsWith("bc", -Infinity)

# Test cases taken from
# https://github.com/mathiasbynens/String.prototype.startsWith/blob/master/tests/tests.js
Object::[1] = 2 # try to break `arguments[1]`
assertEquals String::startsWith.length, 1
assertEquals String::propertyIsEnumerable("startsWith"), false
assertEquals "undefined".startsWith(), true
assertEquals "undefined".startsWith(`undefined`), true
assertEquals "undefined".startsWith(null), false
assertEquals "null".startsWith(), false
assertEquals "null".startsWith(`undefined`), false
assertEquals "null".startsWith(null), true
assertEquals "abc".startsWith(), false
assertEquals "abc".startsWith(""), true
assertEquals "abc".startsWith("\u0000"), false
assertEquals "abc".startsWith("a"), true
assertEquals "abc".startsWith("b"), false
assertEquals "abc".startsWith("ab"), true
assertEquals "abc".startsWith("bc"), false
assertEquals "abc".startsWith("abc"), true
assertEquals "abc".startsWith("bcd"), false
assertEquals "abc".startsWith("abcd"), false
assertEquals "abc".startsWith("bcde"), false
assertEquals "abc".startsWith("", NaN), true
assertEquals "abc".startsWith("\u0000", NaN), false
assertEquals "abc".startsWith("a", NaN), true
assertEquals "abc".startsWith("b", NaN), false
assertEquals "abc".startsWith("ab", NaN), true
assertEquals "abc".startsWith("bc", NaN), false
assertEquals "abc".startsWith("abc", NaN), true
assertEquals "abc".startsWith("bcd", NaN), false
assertEquals "abc".startsWith("abcd", NaN), false
assertEquals "abc".startsWith("bcde", NaN), false
assertEquals "abc".startsWith("", false), true
assertEquals "abc".startsWith("\u0000", false), false
assertEquals "abc".startsWith("a", false), true
assertEquals "abc".startsWith("b", false), false
assertEquals "abc".startsWith("ab", false), true
assertEquals "abc".startsWith("bc", false), false
assertEquals "abc".startsWith("abc", false), true
assertEquals "abc".startsWith("bcd", false), false
assertEquals "abc".startsWith("abcd", false), false
assertEquals "abc".startsWith("bcde", false), false
assertEquals "abc".startsWith("", `undefined`), true
assertEquals "abc".startsWith("\u0000", `undefined`), false
assertEquals "abc".startsWith("a", `undefined`), true
assertEquals "abc".startsWith("b", `undefined`), false
assertEquals "abc".startsWith("ab", `undefined`), true
assertEquals "abc".startsWith("bc", `undefined`), false
assertEquals "abc".startsWith("abc", `undefined`), true
assertEquals "abc".startsWith("bcd", `undefined`), false
assertEquals "abc".startsWith("abcd", `undefined`), false
assertEquals "abc".startsWith("bcde", `undefined`), false
assertEquals "abc".startsWith("", null), true
assertEquals "abc".startsWith("\u0000", null), false
assertEquals "abc".startsWith("a", null), true
assertEquals "abc".startsWith("b", null), false
assertEquals "abc".startsWith("ab", null), true
assertEquals "abc".startsWith("bc", null), false
assertEquals "abc".startsWith("abc", null), true
assertEquals "abc".startsWith("bcd", null), false
assertEquals "abc".startsWith("abcd", null), false
assertEquals "abc".startsWith("bcde", null), false
assertEquals "abc".startsWith("", -Infinity), true
assertEquals "abc".startsWith("\u0000", -Infinity), false
assertEquals "abc".startsWith("a", -Infinity), true
assertEquals "abc".startsWith("b", -Infinity), false
assertEquals "abc".startsWith("ab", -Infinity), true
assertEquals "abc".startsWith("bc", -Infinity), false
assertEquals "abc".startsWith("abc", -Infinity), true
assertEquals "abc".startsWith("bcd", -Infinity), false
assertEquals "abc".startsWith("abcd", -Infinity), false
assertEquals "abc".startsWith("bcde", -Infinity), false
assertEquals "abc".startsWith("", -1), true
assertEquals "abc".startsWith("\u0000", -1), false
assertEquals "abc".startsWith("a", -1), true
assertEquals "abc".startsWith("b", -1), false
assertEquals "abc".startsWith("ab", -1), true
assertEquals "abc".startsWith("bc", -1), false
assertEquals "abc".startsWith("abc", -1), true
assertEquals "abc".startsWith("bcd", -1), false
assertEquals "abc".startsWith("abcd", -1), false
assertEquals "abc".startsWith("bcde", -1), false
assertEquals "abc".startsWith("", -0), true
assertEquals "abc".startsWith("\u0000", -0), false
assertEquals "abc".startsWith("a", -0), true
assertEquals "abc".startsWith("b", -0), false
assertEquals "abc".startsWith("ab", -0), true
assertEquals "abc".startsWith("bc", -0), false
assertEquals "abc".startsWith("abc", -0), true
assertEquals "abc".startsWith("bcd", -0), false
assertEquals "abc".startsWith("abcd", -0), false
assertEquals "abc".startsWith("bcde", -0), false
assertEquals "abc".startsWith("", +0), true
assertEquals "abc".startsWith("\u0000", +0), false
assertEquals "abc".startsWith("a", +0), true
assertEquals "abc".startsWith("b", +0), false
assertEquals "abc".startsWith("ab", +0), true
assertEquals "abc".startsWith("bc", +0), false
assertEquals "abc".startsWith("abc", +0), true
assertEquals "abc".startsWith("bcd", +0), false
assertEquals "abc".startsWith("abcd", +0), false
assertEquals "abc".startsWith("bcde", +0), false
assertEquals "abc".startsWith("", 1), true
assertEquals "abc".startsWith("\u0000", 1), false
assertEquals "abc".startsWith("a", 1), false
assertEquals "abc".startsWith("b", 1), true
assertEquals "abc".startsWith("ab", 1), false
assertEquals "abc".startsWith("bc", 1), true
assertEquals "abc".startsWith("abc", 1), false
assertEquals "abc".startsWith("bcd", 1), false
assertEquals "abc".startsWith("abcd", 1), false
assertEquals "abc".startsWith("bcde", 1), false
assertEquals "abc".startsWith("", +Infinity), true
assertEquals "abc".startsWith("\u0000", +Infinity), false
assertEquals "abc".startsWith("a", +Infinity), false
assertEquals "abc".startsWith("b", +Infinity), false
assertEquals "abc".startsWith("ab", +Infinity), false
assertEquals "abc".startsWith("bc", +Infinity), false
assertEquals "abc".startsWith("abc", +Infinity), false
assertEquals "abc".startsWith("bcd", +Infinity), false
assertEquals "abc".startsWith("abcd", +Infinity), false
assertEquals "abc".startsWith("bcde", +Infinity), false
assertEquals "abc".startsWith("", true), true
assertEquals "abc".startsWith("\u0000", true), false
assertEquals "abc".startsWith("a", true), false
assertEquals "abc".startsWith("b", true), true
assertEquals "abc".startsWith("ab", true), false
assertEquals "abc".startsWith("bc", true), true
assertEquals "abc".startsWith("abc", true), false
assertEquals "abc".startsWith("bcd", true), false
assertEquals "abc".startsWith("abcd", true), false
assertEquals "abc".startsWith("bcde", true), false
assertEquals "abc".startsWith("", "x"), true
assertEquals "abc".startsWith("\u0000", "x"), false
assertEquals "abc".startsWith("a", "x"), true
assertEquals "abc".startsWith("b", "x"), false
assertEquals "abc".startsWith("ab", "x"), true
assertEquals "abc".startsWith("bc", "x"), false
assertEquals "abc".startsWith("abc", "x"), true
assertEquals "abc".startsWith("bcd", "x"), false
assertEquals "abc".startsWith("abcd", "x"), false
assertEquals "abc".startsWith("bcde", "x"), false
assertEquals "[a-z]+(bar)?".startsWith("[a-z]+"), true
assertThrows (->
  "[a-z]+(bar)?".startsWith /[a-z]+/
  return
), TypeError
assertEquals "[a-z]+(bar)?".startsWith("(bar)?", 6), true
assertThrows (->
  "[a-z]+(bar)?".startsWith /(bar)?/
  return
), TypeError
assertThrows (->
  "[a-z]+/(bar)?/".startsWith /(bar)?/
  return
), TypeError

# http://mathiasbynens.be/notes/javascript-unicode#poo-test
string = "Iñtërnâtiônàlizætiøn☃💩"
assertEquals string.startsWith(""), true
assertEquals string.startsWith("ñtër"), false
assertEquals string.startsWith("ñtër", 1), true
assertEquals string.startsWith("àlizæ"), false
assertEquals string.startsWith("àlizæ", 11), true
assertEquals string.startsWith("øn☃💩"), false
assertEquals string.startsWith("øn☃💩", 18), true
assertEquals string.startsWith("☃"), false
assertEquals string.startsWith("☃", 20), true
assertEquals string.startsWith("💩"), false
assertEquals string.startsWith("💩", 21), true
assertThrows (->
  String::startsWith.call `undefined`
  return
), TypeError
assertThrows (->
  String::startsWith.call `undefined`, "b"
  return
), TypeError
assertThrows (->
  String::startsWith.call `undefined`, "b", 4
  return
), TypeError
assertThrows (->
  String::startsWith.call null
  return
), TypeError
assertThrows (->
  String::startsWith.call null, "b"
  return
), TypeError
assertThrows (->
  String::startsWith.call null, "b", 4
  return
), TypeError
assertEquals String::startsWith.call(42, "2"), false
assertEquals String::startsWith.call(42, "4"), true
assertEquals String::startsWith.call(42, "b", 4), false
assertEquals String::startsWith.call(42, "2", 1), true
assertEquals String::startsWith.call(42, "2", 4), false
assertEquals String::startsWith.call(
  toString: ->
    "abc"
, "b", 0), false
assertEquals String::startsWith.call(
  toString: ->
    "abc"
, "b", 1), true
assertEquals String::startsWith.call(
  toString: ->
    "abc"
, "b", 2), false
assertThrows (->
  String::startsWith.call
    toString: ->
      throw RangeError()return
  , /./
  return
), RangeError
assertThrows (->
  String::startsWith.call
    toString: ->
      "abc"
  , /./
  return
), TypeError
assertThrows (->
  String::startsWith.apply `undefined`
  return
), TypeError
assertThrows (->
  String::startsWith.apply `undefined`, ["b"]
  return
), TypeError
assertThrows (->
  String::startsWith.apply `undefined`, [
    "b"
    4
  ]
  return
), TypeError
assertThrows (->
  String::startsWith.apply null
  return
), TypeError
assertThrows (->
  String::startsWith.apply null, ["b"]
  return
), TypeError
assertThrows (->
  String::startsWith.apply null, [
    "b"
    4
  ]
  return
), TypeError
assertEquals String::startsWith.apply(42, ["2"]), false
assertEquals String::startsWith.apply(42, ["4"]), true
assertEquals String::startsWith.apply(42, [
  "b"
  4
]), false
assertEquals String::startsWith.apply(42, [
  "2"
  1
]), true
assertEquals String::startsWith.apply(42, [
  "2"
  4
]), false
assertEquals String::startsWith.apply(
  toString: ->
    "abc"
, [
  "b"
  0
]), false
assertEquals String::startsWith.apply(
  toString: ->
    "abc"
, [
  "b"
  1
]), true
assertEquals String::startsWith.apply(
  toString: ->
    "abc"
, [
  "b"
  2
]), false
assertThrows (->
  String::startsWith.apply
    toString: ->
      throw RangeError()return
  , [/./]
  return
), RangeError
assertThrows (->
  String::startsWith.apply
    toString: ->
      "abc"
  , [/./]
  return
), TypeError
