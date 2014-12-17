# Copyright 2013 the V8 project authors. All rights reserved.
# Copyright (C) 2005, 2006, 2007, 2008, 2009 Apple Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
removeLink = (text) ->
  text.replace(/<a[^>]*>/g, "").replace /<\/a>/g, ""
description = (msg) ->
  print removeLink(msg)
  print "\nOn success, you will see a series of \"PASS\" messages, followed by \"TEST COMPLETE\".\n"
  print()
  return
debug = (msg) ->
  print msg
  return
escapeString = (text) ->
  text.replace /\0/g, ""
testPassed = (msg) ->
  print "PASS", escapeString(msg)
  return
testFailed = (msg) ->
  print "FAIL", escapeString(msg)
  return
areArraysEqual = (_a, _b) ->
  return false  unless Object::toString.call(_a) is Object::toString.call([])
  return false  if _a.length isnt _b.length
  i = 0

  while i < _a.length
    return false  if _a[i] isnt _b[i]
    i++
  true
isMinusZero = (n) ->
  
  # the only way to tell 0 from -0 in JS is the fact that 1/-0 is
  # -Infinity instead of Infinity
  n is 0 and 1 / n < 0
isResultCorrect = (_actual, _expected) ->
  return _actual is _expected and (1 / _actual) is (1 / _expected)  if _expected is 0
  return true  if _actual is _expected
  return typeof (_actual) is "number" and isNaN(_actual)  if typeof (_expected) is "number" and isNaN(_expected)
  return areArraysEqual(_actual, _expected)  if Object::toString.call(_expected) is Object::toString.call([])
  false
stringify = (v) ->
  if v is 0 and 1 / v < 0
    "-0"
  else
    "" + v
shouldBe = (_a, _b) ->
  debug "WARN: shouldBe() expects string arguments"  if typeof _a isnt "string" or typeof _b isnt "string"
  exception = undefined
  _av = undefined
  try
    _av = eval(_a)
  catch e
    exception = e
  _bv = eval(_b)
  if exception
    testFailed _a + " should be " + _bv + ". Threw exception " + exception
  else if isResultCorrect(_av, _bv)
    testPassed _a + " is " + _b
  else if typeof (_av) is typeof (_bv)
    testFailed _a + " should be " + _bv + ". Was " + stringify(_av) + "."
  else
    testFailed _a + " should be " + _bv + " (of type " + typeof _bv + "). Was " + _av + " (of type " + typeof _av + ")."
  return
shouldBeTrue = (_a) ->
  shouldBe _a, "true"
  return
shouldBeFalse = (_a) ->
  shouldBe _a, "false"
  return
shouldBeNaN = (_a) ->
  shouldBe _a, "NaN"
  return
shouldBeNull = (_a) ->
  shouldBe _a, "null"
  return
shouldBeEqualToString = (a, b) ->
  debug "WARN: shouldBeEqualToString() expects string arguments"  if typeof a isnt "string" or typeof b isnt "string"
  unevaledString = JSON.stringify(b)
  shouldBe a, unevaledString
  return
shouldBeUndefined = (_a) ->
  exception = undefined
  _av = undefined
  try
    _av = eval(_a)
  catch e
    exception = e
  if exception
    testFailed _a + " should be undefined. Threw exception " + exception
  else if typeof _av is "undefined"
    testPassed _a + " is undefined."
  else
    testFailed _a + " should be undefined. Was " + _av
  return
shouldThrow = (_a, _e) ->
  exception = undefined
  _av = undefined
  try
    _av = eval(_a)
  catch e
    exception = e
  _ev = undefined
  _ev = eval(_e)  if _e
  if exception
    if typeof _e is "undefined" or exception is _ev
      testPassed _a + " threw exception " + exception + "."
    else
      testFailed _a + " should throw " + ((if typeof _e is "undefined" then "an exception" else _ev)) + ". Threw exception " + exception + "."
  else if typeof _av is "undefined"
    testFailed _a + " should throw " + ((if typeof _e is "undefined" then "an exception" else _ev)) + ". Was undefined."
  else
    testFailed _a + " should throw " + ((if typeof _e is "undefined" then "an exception" else _ev)) + ". Was " + _av + "."
  return
isSuccessfullyParsed = ->
  successfullyParsed = true
  shouldBeTrue "successfullyParsed"
  debug "\nTEST COMPLETE\n"
  return

# It's possible for an async test to call finishJSTest() before js-test-post.js
# has been parsed.
finishJSTest = ->
  wasFinishJSTestCalled = true
  return  unless wasPostTestScriptParsed
  isSuccessfullyParsed()
  return
wasPostTestScriptParsed = false
