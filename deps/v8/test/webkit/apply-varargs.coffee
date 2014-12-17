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

# Regression test for <rdar://problem/10763509>
callee = (a1, a2, a3, a4, a5, a6, a7, a8) ->
  
  # We expect that the unused actual parameters will be filled
  # with undefined.
  return "Arg1 is wrong"  if a1 isnt `undefined`
  return "Arg2 is wrong"  if a2 isnt `undefined`
  return "Arg3 is wrong"  if a3 isnt `undefined`
  return "Arg4 is wrong"  if a4 isnt `undefined`
  return "Arg5 is wrong"  if a5 isnt `undefined`
  return "Arg6 is wrong"  if a6 isnt `undefined`
  return "Arg7 is wrong"  if a7 isnt `undefined`
  return "Arg8 is wrong"  if a8 isnt `undefined`
  `undefined`
dummy = (a1, a2, a3, a4, a5, a6, a7, a8) ->
BaseObj = ->
caller = (testArgCount) ->
  baseObj = new BaseObj()
  allArgs = [
    0
    "String"
    callee
    true
    null
    2.5
    [
      1
      2
      3
    ]
    {
      a: 1
      b: 2
    }
  ]
  argCounts = [
    8
    testArgCount
  ]
  argCountIndex = 0
  while argCountIndex < argCounts.length
    argCount = argCounts[argCountIndex]
    varArgs = []
    i = 0
    while i < argCount
      varArgs[i] = `undefined`
      i++
    numCalls = 0
    while numCalls < 10
      
      # Run multiple times so that the JIT kicks in
      dummy.apply baseObj, allArgs
      result = callee.apply(baseObj, varArgs)
      return result  if result?
      numCalls++
    argCountIndex++
  `undefined`
description "Test that we properly fill in missing args with \"undefined\" in JIT code."
shouldBe "caller(0)", "undefined"
shouldBe "caller(1)", "undefined"
shouldBe "caller(2)", "undefined"
shouldBe "caller(3)", "undefined"
shouldBe "caller(4)", "undefined"
shouldBe "caller(5)", "undefined"
shouldBe "caller(6)", "undefined"
shouldBe "caller(7)", "undefined"
shouldBe "caller(8)", "undefined"
successfullyParsed = true
