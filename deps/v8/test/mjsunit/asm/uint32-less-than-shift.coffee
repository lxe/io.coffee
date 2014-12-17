# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  foo1 = (i1) ->
    i1 = i1 | 0
    i10 = i1 >> 5
    if i10 >>> 0 < 5
      return 1
    else
      return 0
    0
  foo2 = (i1) ->
    i1 = i1 | 0
    i10 = i1 / 32 | 0
    if i10 >>> 0 < 5
      return 1
    else
      return 0
    0
  foo3 = (i1) ->
    i1 = i1 | 0
    i10 = (i1 + 32 | 0) / 32 | 0
    if i10 >>> 0 < 5
      return 1
    else
      return 0
    0
  "use asm"
  foo1: foo1
  foo2: foo2
  foo3: foo3
m = Module(this, {}, `undefined`)
i = 0

while i < 4 * 32
  assertEquals 1, m.foo1(i)
  assertEquals 1, m.foo2(i)
  assertEquals 1, m.foo3(i)
  i++
i = 4 * 32

while i < 5 * 32
  assertEquals 1, m.foo1(i)
  assertEquals 1, m.foo2(i)
  assertEquals 0, m.foo3(i)
  i++
i = 5 * 32

while i < 10 * 32
  assertEquals 0, m.foo1(i)
  assertEquals 0, m.foo2(i)
  assertEquals 0, m.foo3(i)
  i++
