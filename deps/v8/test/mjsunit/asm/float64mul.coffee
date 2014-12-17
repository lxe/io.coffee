# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  f1 = (i) ->
    i = +i
    +(i * -1)
  f2 = (i) ->
    i = +i
    +(-1 * i)
  "use asm"
  f1: f1
  f2: f2
m = Module(this, {}, new ArrayBuffer(64 * 1024))
assertEquals NaN, m.f1(NaN)
assertEquals NaN, m.f2(NaN)
assertEquals Infinity, 1 / m.f1(-0)
assertEquals Infinity, 1 / m.f2(-0)
assertEquals Infinity, m.f1(-Infinity)
assertEquals Infinity, m.f2(-Infinity)
assertEquals -Infinity, 1 / m.f1(0)
assertEquals -Infinity, 1 / m.f2(0)
assertEquals -Infinity, m.f1(Infinity)
assertEquals -Infinity, m.f2(Infinity)
i = -2147483648

while i < 2147483648
  assertEquals -i, m.f1(i)
  assertEquals -i, m.f2(i)
  i += 3999777
