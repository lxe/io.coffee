# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  load = (i) ->
    i = i | 0
    i = +MEM32[i >> 2]
    i
  store = (i, v) ->
    i = i | 0
    v = +v
    MEM32[i >> 2] = v
    return
  "use asm"
  MEM32 = new stdlib.Float32Array(heap)
  load: load
  store: store
m = Module(this, {}, new ArrayBuffer(4))
m.store 0, 42.0
i = 1

while i < 64
  m.store i * 4 * 32 * 1024, i
  ++i
assertEquals 42.0, m.load(0)
i = 1

while i < 64
  assertEquals NaN, m.load(i * 4 * 32 * 1024)
  ++i
