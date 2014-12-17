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
testDateFunctionWithValueNoRecoverNaN = (functionNameRoot, steps) ->
  date = new Date()
  setValue = date["get" + functionNameRoot]()
  date.setMilliseconds Number.NaN
  params = [
    ""
    ", 0"
    ", 0, 0"
    ", 0, 0, 0"
  ]
  setResult = (if (1 is steps) then date["set" + functionNameRoot](setValue) else ((if (2 is steps) then date["set" + functionNameRoot](setValue, 0) else ((if (3 is steps) then date["set" + functionNameRoot](setValue, 0, 0) else date["set" + functionNameRoot](setValue, 0, 0, 0))))))
  unless isNaN(setResult)
    testFailed "date(NaN).set" + functionNameRoot + "(" + setValue + params[steps - 1] + ") was " + setResult + " instead of NaN"
    return false
  getResult = date["get" + functionNameRoot]()
  unless isNaN(getResult)
    testFailed "date.get" + functionNameRoot + "() was " + getResult + " instead of NaN"
    return false
  testPassed "no recovering from NaN date using date.set" + functionNameRoot + "(arg0" + params[steps - 1] + ")"
  true
testDateFunctionWithValueRecoverTime = (functionNameRoot) ->
  date = new Date()
  setValue = date["get" + functionNameRoot]()
  date.setMilliseconds Number.NaN
  setResult = date["set" + functionNameRoot](setValue)
  unless setValue is setResult
    testFailed "date(NaN).set" + functionNameRoot + "(" + setValue + ") was " + setResult + " instead of " + setValue
    return false
  getResult = date["get" + functionNameRoot]()
  unless getResult is setValue
    testFailed "date.get" + functionNameRoot + "() was " + getResult + " instead of " + setValue
    return false
  testPassed "recover from NaN date using date.set" + functionNameRoot + "()"
  true
testDateFunctionWithValueRecoverFullYear = (functionNameRoot) ->
  result = true
  date = new Date()
  setValue = date["get" + functionNameRoot]()
  date.setMilliseconds Number.NaN
  setResult = date["set" + functionNameRoot](setValue)
  getResult = date["get" + functionNameRoot]()
  unless getResult is setValue
    testFailed "date.get" + functionNameRoot + "() was " + getResult + " instead of " + setValue
    result = false
  getResult = date.getMilliseconds()
  unless getResult is 0
    testFailed "date.getMilliseconds() was " + getResult + " instead of 0"
    result = false
  getResult = date.getSeconds()
  unless getResult is 0
    testFailed "date.getSeconds() was " + getResult + " instead of 0"
    result = false
  getResult = date.getMinutes()
  unless getResult is 0
    testFailed "date.getMinutes() was " + getResult + " instead of 0"
    result = false
  getResult = date.getHours()
  unless getResult is 0
    testFailed "date.getHours() was " + getResult + " instead of 0"
    result = false
  getResult = date.getDate()
  unless getResult is 1
    testFailed "date.getDate() was " + getResult + " instead of 1"
    result = false
  getResult = date.getMonth()
  unless getResult is 0
    testFailed "date.getMonth() was " + getResult + " instead of 0"
    result = false
  if result
    testPassed "recover from NaN date using date.setFullYear()"
  else
    testFailed "recover from NaN date using date.setFullYear()"
  result
testDateFunctionWithValueRecoverUTCFullYear = (functionNameRoot) ->
  result = true
  date = new Date()
  setValue = date["get" + functionNameRoot]()
  date.setMilliseconds Number.NaN
  setResult = date["set" + functionNameRoot](setValue)
  getResult = date["get" + functionNameRoot]()
  unless getResult is setValue
    testFailed "date.get" + functionNameRoot + "() was " + getResult + " instead of " + setValue
    result = false
  getResult = date.getUTCMilliseconds()
  unless getResult is 0
    testFailed "date.getUTCMilliseconds() was " + getResult + " instead of 0"
    result = false
  getResult = date.getUTCSeconds()
  unless getResult is 0
    testFailed "date.getUTCSeconds() was " + getResult + " instead of 0"
    result = false
  getResult = date.getUTCMinutes()
  unless getResult is 0
    testFailed "date.getUTCMinutes() was " + getResult + " instead of 0"
    result = false
  getResult = date.getUTCHours()
  unless getResult is 0
    testFailed "date.getUTCHours() was " + getResult + " instead of 0"
    result = false
  getResult = date.getUTCDate()
  unless getResult is 1
    testFailed "date.getUTCDate() was " + getResult + " instead of 1"
    result = false
  getResult = date.getUTCMonth()
  unless getResult is 0
    testFailed "date.getUTCMonth() was " + getResult + " instead of 0"
    result = false
  if result
    testPassed "recover from NaN date using date.setUTCFullYear()"
  else
    testFailed "recover from NaN date using date.setUTCFullYear()"
  result
testDateFunctionWithValueRecoverYear = (functionNameRoot) ->
  result = true
  is13Compatible = true
  date = new Date()
  setValue = date["get" + functionNameRoot]()
  fullYears = date.getFullYear() - 1900
  unless setValue is fullYears
    testFailed "date.get" + functionNameRoot + "() was " + setValue + " instead of " + fullYears
    is13Compatible = false
  else
    testPassed "date.getYear() is compatible to JavaScript 1.3 and later"
  date.setMilliseconds Number.NaN
  setResult = date["set" + functionNameRoot](setValue + 1900)
  getResult = date["get" + functionNameRoot]()
  unless getResult is setValue
    testFailed "date.get" + functionNameRoot + "() was " + getResult + " instead of " + setValue
    result = false
  getResult = date.getMilliseconds()
  unless getResult is 0
    testFailed "date.getMilliseconds() was " + getResult + " instead of 0"
    result = false
  getResult = date.getSeconds()
  unless getResult is 0
    testFailed "date.getSeconds() was " + getResult + " instead of 0"
    result = false
  getResult = date.getMinutes()
  unless getResult is 0
    testFailed "date.getMinutes() was " + getResult + " instead of 0"
    result = false
  getResult = date.getHours()
  unless getResult is 0
    testFailed "date.getHours() was " + getResult + " instead of 0"
    result = false
  getResult = date.getDate()
  unless getResult is 1
    testFailed "date.getDate() was " + getResult + " instead of 1"
    result = false
  getResult = date.getMonth()
  unless getResult is 0
    testFailed "date.getMonth() was " + getResult + " instead of 0"
    result = false
  if result
    testPassed "recover from NaN date using date.setUTCFullYear()"
  else
    testFailed "recover from NaN date using date.setUTCFullYear()"
  result and is13Compatible
makeIEHappy = (functionNameRoot, value) ->
  date = new Date()
  setResult = date["set" + functionNameRoot](value)
  unless isNaN(setResult)
    testFailed "date.set" + functionNameRoot + "() was " + setResult + " instead of NaN"
    return false
  getResult = date["get" + functionNameRoot]()
  unless isNaN(getResult)
    testFailed "date.get" + functionNameRoot + "() was " + getResult + " instead of NaN"
    return false
  true
testDateFunctionWithValueExpectingNaN1 = (functionNameRoot) ->
  result = true
  for idx0 of testValues
    continue
  if result
    testPassed "date.set" + functionNameRoot + "(arg0)"
    testPassed "date.set" + functionNameRoot + "()"
  result
testDateFunctionWithValueExpectingNaN2 = (functionNameRoot) ->
  result = true
  for idx0 of testValues
    continue
  testPassed "date.set" + functionNameRoot + "(arg0, arg1)"  if result
  result
testDateFunctionWithValueExpectingNaN3 = (functionNameRoot) ->
  result = true
  for idx0 of testValues
    continue
  testPassed "date.set" + functionNameRoot + "(arg0, arg1, arg2)"  if result
  result
testDateFunctionWithValueExpectingNaN4 = (functionNameRoot) ->
  result = true
  for idx0 of testValues
    continue
  testPassed "date.set" + functionNameRoot + "(arg0, arg1, arg2, arg3)"  if result
  result
testDateFunction = (functionNameRoot, functionParamNum) ->
  success = true
  switch functionParamNum
    when 4
      success &= testDateFunctionWithValueExpectingNaN4(functionNameRoot)
      success &= testDateFunctionWithValueNoRecoverNaN(functionNameRoot, 4)  if functionNameRoot isnt "Time" and functionNameRoot isnt "FullYear" and functionNameRoot isnt "UTCFullYear" and functionNameRoot isnt "Year"
    when 3
      success &= testDateFunctionWithValueExpectingNaN3(functionNameRoot)
      success &= testDateFunctionWithValueNoRecoverNaN(functionNameRoot, 3)  if functionNameRoot isnt "Time" and functionNameRoot isnt "FullYear" and functionNameRoot isnt "UTCFullYear" and functionNameRoot isnt "Year"
    when 2
      success &= testDateFunctionWithValueExpectingNaN2(functionNameRoot)
      success &= testDateFunctionWithValueNoRecoverNaN(functionNameRoot, 2)  if functionNameRoot isnt "Time" and functionNameRoot isnt "FullYear" and functionNameRoot isnt "UTCFullYear" and functionNameRoot isnt "Year"
    when 1
      success &= testDateFunctionWithValueExpectingNaN1(functionNameRoot)
      if functionNameRoot is "Time"
        success &= testDateFunctionWithValueRecoverTime(functionNameRoot)
      else if functionNameRoot is "FullYear"
        success &= testDateFunctionWithValueRecoverFullYear(functionNameRoot)
      else if functionNameRoot is "UTCFullYear"
        success &= testDateFunctionWithValueRecoverUTCFullYear(functionNameRoot)
      else if functionNameRoot is "Year"
        success &= testDateFunctionWithValueRecoverYear(functionNameRoot)
      else
        success &= testDateFunctionWithValueNoRecoverNaN(functionNameRoot, 1)
  testPassed "date.set" + functionNameRoot + " passed all tests"  if success
  return
description "This tests if the Date setters handle invalid parameters correctly resulting in a NaN date and if a recovery from such a NaN date is only possible by using the date.setTime() and date.set[[UTC]Full]Year() functions."
dateFunctionNameRoots = [
  "Time"
  "Milliseconds"
  "UTCMilliseconds"
  "Seconds"
  "UTCSeconds"
  "Minutes"
  "UTCMinutes"
  "Hours"
  "UTCHours"
  "Date"
  "UTCDate"
  "Month"
  "UTCMonth"
  "FullYear"
  "UTCFullYear"
  "Year"
]
dateFunctionParameterNum = [
  1
  1
  1
  2
  2
  3
  3
  4
  4
  1
  1
  2
  2
  3
  3
  1
]
testValues = [
  0
  Number.NaN
  Number.POSITIVE_INFINITY
  Number.NEGATIVE_INFINITY
]
for x of dateFunctionNameRoots
  testDateFunction dateFunctionNameRoots[x], dateFunctionParameterNum[x]
