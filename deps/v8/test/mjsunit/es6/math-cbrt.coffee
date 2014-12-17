# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
assertTrue isNaN(Math.cbrt(NaN))
assertTrue isNaN(Math.cbrt(->
))
assertTrue isNaN(Math.cbrt(toString: ->
  NaN
))
assertTrue isNaN(Math.cbrt(valueOf: ->
  "abc"
))
assertEquals "Infinity", String(1 / Math.cbrt(0))
assertEquals "-Infinity", String(1 / Math.cbrt(-0))
assertEquals "Infinity", String(Math.cbrt(Infinity))
assertEquals "-Infinity", String(Math.cbrt(-Infinity))
i = 1e-100

while i < 1e100
  assertEqualsDelta i, Math.cbrt(i * i * i), i * 1e-15
  i *= Math.PI
i = -1e-100

while i > -1e100
  assertEqualsDelta i, Math.cbrt(i * i * i), -i * 1e-15
  i *= Math.E

# Let's be exact at least for small integers.
i = 2

while i < 10000
  assertEquals i, Math.cbrt(i * i * i)
  i++
