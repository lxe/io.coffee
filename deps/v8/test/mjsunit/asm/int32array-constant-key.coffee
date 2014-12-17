# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  loadm4194304 = ->
    MEM32[-4194304]
  loadm0 = ->
    MEM32[-0]
  load0 = ->
    MEM32[0]
  load4 = ->
    MEM32[4]
  storem4194304 = (v) ->
    MEM32[-4194304] = v
    return
  storem0 = (v) ->
    MEM32[-0] = v
    return
  store0 = (v) ->
    MEM32[0] = v
    return
  store4 = (v) ->
    MEM32[4] = v
    return
  "use asm"
  MEM32 = new stdlib.Int32Array(heap)
  loadm4194304: loadm4194304
  storem4194304: storem4194304
  loadm0: loadm0
  storem0: storem0
  load0: load0
  store0: store0
  load4: load4
  store4: store4
m = Module(this, {}, new ArrayBuffer(4))
assertEquals `undefined`, m.loadm4194304()
assertEquals 0, m.loadm0()
assertEquals 0, m.load0()
assertEquals `undefined`, m.load4()
m.storem4194304 123456789
assertEquals `undefined`, m.loadm4194304()
assertEquals 0, m.loadm0()
assertEquals 0, m.load0()
assertEquals `undefined`, m.load4()
m.storem0 987654321
assertEquals `undefined`, m.loadm4194304()
assertEquals 987654321, m.loadm0()
assertEquals 987654321, m.load0()
assertEquals `undefined`, m.load4()
m.store0 0x12345678
assertEquals `undefined`, m.loadm4194304()
assertEquals 0x12345678, m.loadm0()
assertEquals 0x12345678, m.load0()
assertEquals `undefined`, m.load4()
m.store4 43
assertEquals `undefined`, m.loadm4194304()
assertEquals 0x12345678, m.loadm0()
assertEquals 0x12345678, m.load0()
assertEquals `undefined`, m.load4()
