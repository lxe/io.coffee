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
makeTest = (start, end, expression, relationship, override, invert) ->
  func = (content) ->
    f = new Function(content)
    f.toString = ->
      content

    f
  resultValue = eval(relationship + expression + 0) or !!override
  resultValue = not resultValue  if invert
  expr = start + expression + end
  result = []
  result.push [
    new func("return " + expr + ";")
    resultValue
  ]
  result.push [
    new func("if (" + expr + ") return true; return false;")
    resultValue
  ]
  result.push [
    new func("var k = 0; while (" + expr + ") if (k++) return true; return false;")
    resultValue
  ]
  result.push [
    new func("var k = 0; for (; " + expr + "; ) if (k++) return true; return false;")
    resultValue
  ]
  result
doTest = (lhs, rhs, relationship) ->
  expressionParts = [
    [
      "("
      ")"
    ]
    [
      "("
      ") || 1"
      true
    ]
    [
      "("
      ") && 1"
    ]
    [
      "("
      ") || 1"
      true
    ]
    [
      "1 || ("
      ")"
      true
    ]
    [
      "1 && ("
      ")"
    ]
  ]
  expressions = []
  tests = []
  i = 0

  while i < expressionParts.length
    start = expressionParts[i][0] + lhs
    end = String(rhs) + expressionParts[i][1]
    tests.push.apply tests, makeTest(start, end, "==", relationship, expressionParts[i][2])
    tests.push.apply tests, makeTest(start, end, "!=", relationship, expressionParts[i][2])
    tests.push.apply tests, makeTest(start, end, "===", relationship, expressionParts[i][2])
    tests.push.apply tests, makeTest(start, end, "!==", relationship, expressionParts[i][2])
    i++
  i = 0

  while i < tests.length
    if (r = tests[i][0]()) is tests[i][1]
      testPassed tests[i][0] + " is " + tests[i][1]
    else
      testFailed tests[i][0] + " is " + r + " and should be " + tests[i][1] + "."
    i++
  return
description "test that comparison operators work correctly."
letterA = "a"
letterB = "b"
One = 1
Zero = 0
doTest "\"a\"", "\"b\"", -1
doTest "\"a\"", "\"a\"", 0
doTest "\"b\"", "\"a\"", 1
doTest "letterA", "\"b\"", -1
doTest "letterA", "\"a\"", 0
doTest "\"b\"", "\"a\"", 1
doTest "letterA", "\"b\"", -1
doTest "letterA", "letterA", 0
doTest "\"b\"", "letterA", 1
doTest "\"a\"", "\"b\"", -1
doTest "\"a\"", "letterA", 0
doTest "\"b\"", "letterA", 1
doTest "\"a\"", "0", NaN
doTest "0", "\"a\"", NaN
doTest "letterA", "0", NaN
doTest "letterA", "\"a\"", 0
doTest "0", "\"a\"", NaN
doTest "letterA", "letterA", 0
doTest "0", "letterA", NaN
doTest "\"a\"", "letterA", 0
doTest "0", "letterA", NaN
doTest "0", "1", -1
doTest "0", "0", 0
doTest "1", "0", 1
doTest "Zero", "1", -1
doTest "Zero", "0", 0
doTest "1", "Zero", 1
doTest "0", "One", -1
doTest "One", "0", 1
