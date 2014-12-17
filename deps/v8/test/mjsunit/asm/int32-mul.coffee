# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  f1 = (i) ->
    i = i | 0
    i * 3 | 0
  f2 = (i) ->
    i = i | 0
    i * 7 | 0
  f3 = (i) ->
    i = i | 0
    i * 1024 | 0
  f4 = (i) ->
    i = i | 0
    i * 3333339 | 0
  "use asm"
  f1: f1
  f2: f2
  f3: f3
  f4: f4
m = Module(this, {}, new ArrayBuffer(1024))
i = -2147483648

while i < 2147483648
  assertEquals i * 3 | 0, m.f1(i)
  assertEquals i * 7 | 0, m.f2(i)
  assertEquals i * 1024 | 0, m.f3(i)
  assertEquals i * 3333339 | 0, m.f4(i)
  i += 3999771
