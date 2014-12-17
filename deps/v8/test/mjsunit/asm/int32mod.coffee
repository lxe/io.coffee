# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Int32Mod = (divisor) ->
  name = "mod_"
  name += "minus_"  if divisor < 0
  name += Math.abs(divisor)
  m = eval("function Module(stdlib, foreign, heap) {\n" + " \"use asm\";\n" + " function " + name + "(dividend) {\n" + "  return ((dividend | 0) % " + divisor + ") | 0;\n" + " }\n" + " return { f: " + name + "}\n" + "}; Module")
  m(stdlib, foreign, heap).f
stdlib = {}
foreign = {}
heap = new ArrayBuffer(64 * 1024)
divisors = [
  -2147483648
  -32 * 1024
  -1000
  -16
  -7
  -2
  -1
  1
  3
  4
  10
  64
  100
  1024
  2147483647
]
for i of divisors
  divisor = divisors[i]
  mod = Int32Mod(divisor)
  dividend = -2147483648

  while dividend < 2147483648
    assertEquals (dividend % divisor) | 0, mod(dividend)
    dividend += 3999773
