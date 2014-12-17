# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  load = (i) ->
    i = i | 0
    i = MEM16[i >> 1] | 0
    i
  loadm1 = ->
    MEM16[-1] | 0
  store = (i, v) ->
    i = i | 0
    v = v | 0
    MEM16[i >> 1] = v
    return
  storem1 = (v) ->
    v = v | 0
    MEM16[-1] = v
    return
  "use asm"
  MEM16 = new stdlib.Int16Array(heap)
  load: load
  loadm1: loadm1
  store: store
  storem1: storem1
m = Module(this, {}, new ArrayBuffer(2))
m.store -1000, 4
assertEquals 0, m.load(-1000)
assertEquals 0, m.loadm1()
m.storem1 1
assertEquals 0, m.loadm1()
m.store 0, 32767
i = 1

while i < 64
  m.store i * 2 * 32 * 1024, i
  ++i
assertEquals 32767, m.load(0)
i = 1

while i < 64
  assertEquals 0, m.load(i * 2 * 32 * 1024)
  ++i
