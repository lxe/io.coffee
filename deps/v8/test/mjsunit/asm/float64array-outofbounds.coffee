# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  load = (i) ->
    i = i | 0
    i = +MEM64[i >> 3]
    i
  store = (i, v) ->
    i = i | 0
    v = +v
    MEM64[i >> 3] = v
    return
  "use asm"
  MEM64 = new stdlib.Float64Array(heap)
  load: load
  store: store
m = Module(this, {}, new ArrayBuffer(8))
m.store 0, 3.12
i = 1

while i < 64
  m.store i * 8 * 32 * 1024, i
  ++i
assertEquals 3.12, m.load(0)
i = 1

while i < 64
  assertEquals NaN, m.load(i * 8 * 32 * 1024)
  ++i
