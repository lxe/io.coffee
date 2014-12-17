# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Word32And = (rhs) ->
  name = "and_0x" + Number(rhs).toString(16)
  m = eval("function Module(stdlib, foreign, heap) {\n" + " \"use asm\";\n" + " function " + name + "(lhs) {\n" + "  return (lhs | 0) & 0x" + Number(rhs).toString(16) + ";\n" + " }\n" + " return { f: " + name + "}\n" + "}; Module")
  m(stdlib, foreign, heap).f
stdlib = {}
foreign = {}
heap = new ArrayBuffer(64 * 1024)
masks = [
  0xffffffff
  0xf0f0f0f0
  0x80ffffff
  0x07f77f0f
  0xdeadbeef
  0x0fffff00
  0x0ff0
  0xff
  0x00
]
for i of masks
  rhs = masks[i]
  and_ = Word32And(rhs)
  lhs = -2147483648

  while lhs < 2147483648
    assertEquals lhs & rhs, and_(lhs)
    lhs += 3999773
