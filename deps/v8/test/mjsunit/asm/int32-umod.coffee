# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  f1 = (i) ->
    i = i >>> 0
    i % 3
  f2 = (i) ->
    i = i >>> 0
    i % 11
  f3 = (i) ->
    i = i >>> 0
    i % 1024
  f4 = (i) ->
    i = i >>> 0
    i % 3333337
  "use asm"
  f1: f1
  f2: f2
  f3: f3
  f4: f4
m = Module(this, {}, new ArrayBuffer(1024))
i = 0

while i < 4294967296
  assertEquals i % 3, m.f1(i)
  assertEquals i % 11, m.f2(i)
  assertEquals i % 1024, m.f3(i)
  assertEquals i % 3333337, m.f4(i)
  i += 3999777
