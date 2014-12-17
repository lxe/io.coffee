# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  load = (i) ->
    i = i | 0
    i = MEM32[i >> 2] | 0
    i
  store = (i, v) ->
    i = i | 0
    v = v | 0
    MEM32[i >> 2] = v
    return
  "use asm"
  MEM32 = new stdlib.Int32Array(heap)
  load: load
  store: store
m = Module(this, {}, new ArrayBuffer(1024))
m.store 0, 0x12345678
m.store 4, -1
m.store 8, -1
i = 0

while i < 4
  assertEquals 0x12345678, m.load(i)
  ++i
i = 4

while i < 12
  assertEquals -1, m.load(i)
  ++i
j = 4

while j < 8
  m.store j, 0x11223344
  i = 0

  while i < 4
    assertEquals 0x12345678, m.load(i)
    ++i
  i = 4

  while i < 8
    assertEquals 0x11223344, m.load(i)
    ++i
  i = 8

  while i < 12
    assertEquals -1, m.load(i)
    ++i
  ++j
