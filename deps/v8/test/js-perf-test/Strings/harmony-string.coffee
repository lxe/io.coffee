# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
RepeatSetup = ->
  result = `undefined`
  return
Repeat = ->
  result = stringRepeatSource.repeat(500)
  return
RepeatTearDown = ->
  expected = ""
  i = 0

  while i < 1000
    expected += stringRepeatSource
    i++
  result is expected
WithSetup = ->
  str = "abc".repeat(500)
  substr = "abc".repeat(200)
  result = `undefined`
  return
WithTearDown = ->
  !!result
StartsWith = ->
  result = str.startsWith(substr)
  return
EndsWith = ->
  result = str.endsWith(substr)
  return
ContainsSetup = ->
  str = "def".repeat(100) + "abc".repeat(100) + "qqq".repeat(100)
  substr = "abc".repeat(100)
  return
Contains = ->
  result = str.contains(substr)
  return
FromCodePointSetup = ->
  result = new Array(MAX_CODE_POINT + 1)
  return
FromCodePoint = ->
  i = 0

  while i <= MAX_CODE_POINT
    result[i] = String.fromCodePoint(i)
    i++
  return
FromCodePointTearDown = ->
  i = 0

  while i <= MAX_CODE_POINT
    return false  if i isnt result[i].codePointAt(0)
    i++
  true
CodePointAtSetup = ->
  allCodePoints = new Array(MAX_CODE_POINT + 1)
  i = 0

  while i <= MAX_CODE_POINT
    allCodePoints = String.fromCodePoint(i)
    i++
  result = `undefined`
  return
CodePointAt = ->
  result = 0
  i = 0

  while i <= MAX_CODE_POINT
    result += allCodePoints.codePointAt(i)
    i++
  return
CodePointAtTearDown = ->
  result is MAX_CODE_POINT * (MAX_CODE_POINT + 1) / 2
new BenchmarkSuite("StringFunctions", [1000], [
  new Benchmark("StringRepeat", false, false, 0, Repeat, RepeatSetup, RepeatTearDown)
  new Benchmark("StringStartsWith", false, false, 0, StartsWith, WithSetup, WithTearDown)
  new Benchmark("StringEndsWith", false, false, 0, EndsWith, WithSetup, WithTearDown)
  new Benchmark("StringContains", false, false, 0, Contains, ContainsSetup, WithTearDown)
  new Benchmark("StringFromCodePoint", false, false, 0, FromCodePoint, FromCodePointSetup, FromCodePointTearDown)
  new Benchmark("StringCodePointAt", false, false, 0, CodePointAt, CodePointAtSetup, CodePointAtTearDown)
])
result = undefined
stringRepeatSource = "abc"
str = undefined
substr = undefined
MAX_CODE_POINT = 0xfffff
allCodePoints = undefined
