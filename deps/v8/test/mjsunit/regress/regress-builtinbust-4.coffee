# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
boomer = ->
  0
o =
  __proto__: Array::
  0: "x"

Object.defineProperty o, "length",
  get: boomer
  set: boomer

Object.seal o
assertDoesNotThrow ->
  o.push 1
  return

assertEquals 0, o.length
assertEquals 1, o[0]
assertDoesNotThrow ->
  o.unshift 2
  return

assertEquals 0, o.length
assertEquals 2, o[0]
