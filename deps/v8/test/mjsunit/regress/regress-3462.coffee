# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
TestFunctionPrototypeSetter = ->
  f = ->

  o = __proto__: f
  o:: = 42
  assertEquals 42, o::
  assertTrue o.hasOwnProperty("prototype")
  return
TestFunctionPrototypeSetterOnValue = ->
  f = ->

  fp = f::
  Number::__proto__ = f
  n = 42
  o = {}
  n:: = o
  assertEquals fp, n::
  assertEquals fp, f::
  assertFalse Number::hasOwnProperty("prototype")
  return
TestArrayLengthSetter = ->
  a = [1]
  o = __proto__: a
  o.length = 2
  assertEquals 2, o.length
  assertEquals 1, a.length
  assertTrue o.hasOwnProperty("length")
  return
TestArrayLengthSetterOnValue = ->
  Number::__proto__ = [1]
  n = 42
  n.length = 2
  assertEquals 1, n.length
  assertFalse Number::hasOwnProperty("length")
  return
TestFunctionPrototypeSetter()
TestFunctionPrototypeSetterOnValue()
TestArrayLengthSetter()
TestArrayLengthSetterOnValue()
