# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = (stdlib) ->
  
  # f: double -> float
  f = (a) ->
    a = +a
    fround a
  "use asm"
  fround = stdlib.Math.fround
  f: f
f = Module(Math: Math).f
assertTrue isNaN(f(NaN))
assertTrue isNaN(f(`undefined`))
assertTrue isNaN(f(->
))
assertEquals "Infinity", String(1 / f(0))
assertEquals "-Infinity", String(1 / f(-0))
assertEquals "Infinity", String(f(Infinity))
assertEquals "-Infinity", String(f(-Infinity))
assertEquals "Infinity", String(f(1e200))
assertEquals "-Infinity", String(f(-1e200))
assertEquals "Infinity", String(1 / f(1e-300))
assertEquals "-Infinity", String(1 / f(-1e-300))
assertEquals 0, f(0)
assertEquals 1, f(1)
assertEquals 1.5, f(1.5)
assertEquals 1.3370000123977661, f(1.337)
assertEquals -4.300000190734863, f(-4.3)
