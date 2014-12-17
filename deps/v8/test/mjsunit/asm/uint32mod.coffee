# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Uint32Mod = (divisor) ->
  name = "mod_"
  name += divisor
  m = eval("function Module(stdlib, foreign, heap) {\n" + " \"use asm\";\n" + " function " + name + "(dividend) {\n" + "  return ((dividend >>> 0) % " + divisor + ") >>> 0;\n" + " }\n" + " return { f: " + name + "}\n" + "}; Module")
  m(stdlib, foreign, heap).f
stdlib = {}
foreign = {}
heap = new ArrayBuffer(64 * 1024)
divisors = [
  0
  1
  3
  4
  10
  42
  64
  100
  1024
  2147483647
  4294967295
]
for i of divisors
  divisor = divisors[i]
  mod = Uint32Mod(divisor)
  dividend = 0

  while dividend < 4294967296
    assertEquals (dividend % divisor) >>> 0, mod(dividend)
    dividend += 3999773
