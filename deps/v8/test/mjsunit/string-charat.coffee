# Copyright 2008 the V8 project authors. All rights reserved.
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
getTwoByteString = ->
  "ሴt"
getCons = ->
  "testtesttesttest" + getTwoByteString()
basicTest = (s, len) ->
  assertEquals "t", s().charAt()
  assertEquals "t", s().charAt("string")
  assertEquals "t", s().charAt(null)
  assertEquals "t", s().charAt(undefined)
  assertEquals "t", s().charAt(false)
  assertEquals "e", s().charAt(true)
  assertEquals "", s().charAt(-1)
  assertEquals "", s().charAt(len)
  assertEquals "", s().charAt(slowIndexOutOfRange)
  assertEquals "", s().charAt(1 / 0)
  assertEquals "", s().charAt(-1 / 0)
  assertEquals "t", s().charAt(0)
  assertEquals "t", s().charAt(-0.0)
  assertEquals "t", s().charAt(-0.1)
  assertEquals "t", s().charAt(0.4)
  assertEquals "e", s().charAt(slowIndex1)
  assertEquals "s", s().charAt(slowIndex2)
  assertEquals "t", s().charAt(3)
  assertEquals "t", s().charAt(3.4)
  assertEquals "t", s().charAt(NaN)
  assertEquals 116, s().charCodeAt()
  assertEquals 116, s().charCodeAt("string")
  assertEquals 116, s().charCodeAt(null)
  assertEquals 116, s().charCodeAt(undefined)
  assertEquals 116, s().charCodeAt(false)
  assertEquals 101, s().charCodeAt(true)
  assertEquals 116, s().charCodeAt(0)
  assertEquals 116, s().charCodeAt(-0.0)
  assertEquals 116, s().charCodeAt(-0.1)
  assertEquals 116, s().charCodeAt(0.4)
  assertEquals 101, s().charCodeAt(slowIndex1)
  assertEquals 115, s().charCodeAt(slowIndex2)
  assertEquals 116, s().charCodeAt(3)
  assertEquals 116, s().charCodeAt(3.4)
  assertEquals 116, s().charCodeAt(NaN)
  assertTrue isNaN(s().charCodeAt(-1))
  assertTrue isNaN(s().charCodeAt(len))
  assertTrue isNaN(s().charCodeAt(slowIndexOutOfRange))
  assertTrue isNaN(s().charCodeAt(1 / 0))
  assertTrue isNaN(s().charCodeAt(-1 / 0))
  return

# Make sure enough of the one-char string cache is filled.

# Now test chars.

# Test stealing String.prototype.{charAt,charCodeAt}.
stealTest = ->
  assertEquals "0", o.charAt(0)
  assertEquals "1", o.charAt(1)
  assertEquals "1", o.charAt(1.4)
  assertEquals "1", o.charAt(slowIndex1)
  assertEquals "2", o.charAt(2)
  assertEquals "2", o.charAt(slowIndex2)
  assertEquals 48, o.charCodeAt(0)
  assertEquals 49, o.charCodeAt(1)
  assertEquals 49, o.charCodeAt(1.4)
  assertEquals 49, o.charCodeAt(slowIndex1)
  assertEquals 50, o.charCodeAt(2)
  assertEquals 50, o.charCodeAt(slowIndex2)
  assertEquals "", o.charAt(-1)
  assertEquals "", o.charAt(-1.4)
  assertEquals "", o.charAt(10)
  assertEquals "", o.charAt(slowIndexOutOfRange)
  assertTrue isNaN(o.charCodeAt(-1))
  assertTrue isNaN(o.charCodeAt(-1.4))
  assertTrue isNaN(o.charCodeAt(10))
  assertTrue isNaN(o.charCodeAt(slowIndexOutOfRange))
  return

# Test custom string IC-s.
testBadToString_charAt = ->
  goodToString = o.toString
  hasCaught = false
  numCalls = 0
  result = undefined
  try
    i = 0

    while i < 20
      o.toString = o.valueOf = badToString  if i is 10
      result = o.charAt(1)
      numCalls++
      i++
  catch e
    hasCaught = true
  finally
    o.toString = goodToString
  assertTrue hasCaught
  assertEquals "1", result
  assertEquals 10, numCalls
  return
testBadToString_charCodeAt = ->
  goodToString = o.toString
  hasCaught = false
  numCalls = 0
  result = undefined
  try
    i = 0

    while i < 20
      o.toString = o.valueOf = badToString  if i is 10
      result = o.charCodeAt(1)
      numCalls++
      i++
  catch e
    hasCaught = true
  finally
    o.toString = goodToString
  assertTrue hasCaught
  assertEquals 49, result
  assertEquals 10, numCalls
  return
testBadIndex_charAt = ->
  index = 1
  hasCaught = false
  numCalls = 0
  result = undefined
  try
    i = 0

    while i < 20
      index = badIndex  if i is 10
      result = o.charAt(index)
      numCalls++
      i++
  catch e
    hasCaught = true
  assertTrue hasCaught
  assertEquals "1", result
  assertEquals 10, numCalls
  return
testBadIndex_charCodeAt = ->
  index = 1
  hasCaught = false
  numCalls = 0
  result = undefined
  try
    i = 0

    while i < 20
      index = badIndex  if i is 10
      result = o.charCodeAt(index)
      numCalls++
      i++
  catch e
    hasCaught = true
  assertTrue hasCaught
  assertEquals 49, result
  assertEquals 10, numCalls
  return
testPrototypeChange_charAt = ->
  result = undefined
  oldResult = undefined
  i = 0

  while i < 20
    if i is 10
      oldResult = result
      String::charAt = ->
        "%"
    result = s.charAt(1)
    i++
  assertEquals "%", result
  assertEquals "e", oldResult
  delete String::charAt # Restore the default.

  return
testPrototypeChange_charCodeAt = ->
  result = undefined
  oldResult = undefined
  i = 0

  while i < 20
    if i is 10
      oldResult = result
      String::charCodeAt = ->
        42
    result = s.charCodeAt(1)
    i++
  assertEquals 42, result
  assertEquals 101, oldResult
  delete String::charCodeAt # Restore the default.

  return
s = "test"
slowIndex1 = valueOf: ->
  1

slowIndex2 = toString: ->
  "2"

slowIndexOutOfRange = valueOf: ->
  -1

basicTest (->
  s
), s.length
basicTest getCons, getCons().length
alpha = ["@"]
i = 1

while i < 128
  c = String.fromCharCode(i)
  alpha[i] = c.charAt(0)
  i++
alphaStr = alpha.join("")
i = 1

while i < 128
  assertEquals alpha[i], alphaStr.charAt(i)
  assertEquals String.fromCharCode(i), alphaStr.charAt(i)
  i++
o =
  charAt: String::charAt
  charCodeAt: String::charCodeAt
  toString: ->
    "012"

  valueOf: ->
    "should not be called"

stealTest()
i = 0

while i < 20
  basicTest (->
    s
  ), s.length
  basicTest getCons, getCons().length
  stealTest()
  i++
badToString = ->
  []

testBadToString_charAt()
testBadToString_charCodeAt()
badIndex =
  toString: badToString
  valueOf: badToString

testBadIndex_charAt()
testBadIndex_charCodeAt()
testPrototypeChange_charAt()
testPrototypeChange_charCodeAt()
