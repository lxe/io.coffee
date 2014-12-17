# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib, foreign, heap) ->
  foo = (i) ->
    MEM32[0] = (i >>> 0) / 2
    MEM32[0]
  "use asm"
  MEM32 = new stdlib.Float32Array(heap)
  foo: foo
foo = Module(this, {}, new ArrayBuffer(64 * 1024)).foo
assertEquals 0.5, foo(1)
