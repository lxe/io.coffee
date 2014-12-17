# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  load = (i) ->
    i = i | 0
    i = MEM8[i] | 0
    i
  store = (i, v) ->
    i = i | 0
    v = v | 0
    MEM8[i] = v
    return
  "use asm"
  MEM8 = new stdlib.Uint8Array(heap)
  load: load
  store: store
m = Module(this, {}, new ArrayBuffer(1))
m.store 0, 255
i = 1

while i < 64
  m.store i * 1 * 32 * 1024, i
  ++i
assertEquals 255, m.load(0)
i = 1

while i < 64
  assertEquals 0, m.load(i * 1 * 32 * 1024)
  ++i
