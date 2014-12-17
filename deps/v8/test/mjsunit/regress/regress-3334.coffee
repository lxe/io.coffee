# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
foo = ->
bar = ->
Object.defineProperty foo, "prototype",
  value: 2

assertEquals 2, foo::
Object.defineProperty bar, "prototype",
  value: 2
  writable: false

assertEquals 2, bar::
assertThrows (->
  "use strict"
  bar:: = 10
  return
), TypeError
assertEquals false, Object.getOwnPropertyDescriptor(bar, "prototype").writable
