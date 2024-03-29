# Copyright 2013 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# TODO(3468): we rely on a precise Math.exp.
# Flags: --no-fast-math
test_id = (fun, rev, value) ->
  assertEqualsDelta 1, rev(fun(value)) / value, 1e-7
  return
[
  Math.sinh
  Math.cosh
  Math.tanh
  Math.asinh
  Math.acosh
  Math.atanh
].forEach (fun) ->
  assertTrue isNaN(fun(NaN))
  assertTrue isNaN(fun("abc"))
  assertTrue isNaN(fun({}))
  assertEquals fun(0), fun([])
  assertTrue isNaN(fun([
    1
    1
  ]))
  assertEquals fun(1.11), fun(toString: ->
    "1.11"
  )
  assertEquals fun(-3.1), fun(toString: ->
    -3.1
  )
  assertEquals fun(-1.1), fun(valueOf: ->
    "-1.1"
  )
  assertEquals fun(3.11), fun(valueOf: ->
    3.11
  )
  return

[
  Math.PI
  2
  5
  1e-5
  0.3
].forEach (x) ->
  test_id Math.sinh, Math.asinh, x
  test_id Math.sinh, Math.asinh, -x
  test_id Math.cosh, Math.acosh, x
  test_id Math.tanh, Math.atanh, x
  test_id Math.tanh, Math.atanh, -x
  return

[
  Math.sinh
  Math.asinh
  Math.tanh
  Math.atanh
].forEach (fun) ->
  assertEquals "-Infinity", String(1 / fun(-0))
  assertEquals "Infinity", String(1 / fun(0))
  return

[
  Math.sinh
  Math.asinh
].forEach (fun) ->
  assertEquals "-Infinity", String(fun(-Infinity))
  assertEquals "Infinity", String(fun(Infinity))
  assertEquals "-Infinity", String(fun("-Infinity"))
  assertEquals "Infinity", String(fun("Infinity"))
  return

assertEquals Infinity, Math.cosh(-Infinity)
assertEquals Infinity, Math.cosh(Infinity)
assertEquals Infinity, Math.cosh("-Infinity")
assertEquals Infinity, Math.cosh("Infinity")
assertEquals -Infinity, Math.atanh(-1)
assertEquals Infinity, Math.atanh(1)

# Math.atanh(x) is NaN for |x| > 1 and NaN
[
  1.000000000001
  Math.PI
  10000000
  2
  Infinity
  NaN
].forEach (x) ->
  assertTrue isNaN(Math.atanh(-x))
  assertTrue isNaN(Math.atanh(x))
  return

assertEquals 0, Math.sinh(0)
assertEquals -Infinity, 1 / Math.sinh(-0)
assertEquals 1, Math.tanh(Infinity)
assertEquals -1, Math.tanh(-Infinity)
assertEquals 1, Math.cosh(0)
assertEquals 1, Math.cosh(-0)
assertEquals 0, Math.acosh(1)
assertEquals "Infinity", String(Math.acosh(Infinity))

# Math.acosh(x) is NaN for x < 1
[
  0.99999999999
  0.2
  -1000
  0
  -0
].forEach (x) ->
  assertTrue isNaN(Math.acosh(x))
  return


# Some random samples.
assertEqualsDelta 74.20321057778875, Math.sinh(5), 1e-12
assertEqualsDelta -74.20321057778875, Math.sinh(-5), 1e-12
assertEqualsDelta 1.1276259652063807, Math.cosh(0.5), 1e-12
assertEqualsDelta 74.20994852478785, Math.cosh(5), 1e-12
assertEqualsDelta 1.1276259652063807, Math.cosh(-0.5), 1e-12
assertEqualsDelta 74.20994852478785, Math.cosh(-5), 1e-12
assertEqualsDelta 0.4621171572600, Math.tanh(0.5), 1e-12
assertEqualsDelta 0.9999092042625, Math.tanh(5), 1e-12
assertEqualsDelta -0.4621171572600, Math.tanh(-0.5), 1e-12
assertEqualsDelta -0.9999092042625, Math.tanh(-5), 1e-12
assertEqualsDelta 0.4812118250596, Math.asinh(0.5), 1e-12
assertEqualsDelta 2.3124383412727, Math.asinh(5), 1e-12
assertEqualsDelta -0.4812118250596, Math.asinh(-0.5), 1e-12
assertEqualsDelta -2.3124383412727, Math.asinh(-5), 1e-12
assertEqualsDelta 0.9624236501192, Math.acosh(1.5), 1e-12
assertEqualsDelta 2.2924316695612, Math.acosh(5), 1e-12
assertEqualsDelta 0.4435682543851, Math.acosh(1.1), 1e-12
assertEqualsDelta 1.3169578969248, Math.acosh(2), 1e-12
assertEqualsDelta 0.5493061443341, Math.atanh(0.5), 1e-12
assertEqualsDelta 0.1003353477311, Math.atanh(0.1), 1e-12
assertEqualsDelta -0.5493061443341, Math.atanh(-0.5), 1e-12
assertEqualsDelta -0.1003353477311, Math.atanh(-0.1), 1e-12
[
  0
  1e-50
  1e-10
  1e10
  1e50
  1e100
  1e150
].forEach (x) ->
  assertEqualsDelta Math.asinh(x), -Math.asinh(-x), 1e-12
  return

[
  1 - (1e-16)
  0
  1e-10
  1e-50
].forEach (x) ->
  assertEqualsDelta Math.atanh(x), -Math.atanh(-x), 1e-12
  return


# Implementation-specific tests for sinh.
# Case |x| < 2^-28
assertEquals Math.pow(2, -29), Math.sinh(Math.pow(2, -29))
assertEquals -Math.pow(2, -29), Math.sinh(-Math.pow(2, -29))

# Case |x| < 1
assertEquals 0.5210953054937474, Math.sinh(0.5)
assertEquals -0.5210953054937474, Math.sinh(-0.5)

# sinh(10*log(2)) = 1048575/2048, case |x| < 22
assertEquals 1048575 / 2048, Math.sinh(10 * Math.LN2)
assertEquals -1048575 / 2048, Math.sinh(-10 * Math.LN2)

# Case |x| < 22
assertEquals 11013.232874703393, Math.sinh(10)
assertEquals -11013.232874703393, Math.sinh(-10)

# Case |x| in [22, log(maxdouble)]
assertEquals 2.1474836479999983e9, Math.sinh(32 * Math.LN2)
assertEquals -2.1474836479999983e9, Math.sinh(-32 * Math.LN2)

# Case |x| in [22, log(maxdouble)]
assertEquals 1.3440585709080678e43, Math.sinh(100)
assertEquals -1.3440585709080678e43, Math.sinh(-100)

# No overflow, case |x| in [log(maxdouble), threshold]
assertEquals 1.7976931348621744e308, Math.sinh(710.4758600739439)
assertEquals -1.7976931348621744e308, Math.sinh(-710.4758600739439)

# Overflow, case |x| > threshold
assertEquals Infinity, Math.sinh(710.475860073944)
assertEquals -Infinity, Math.sinh(-710.475860073944)
assertEquals Infinity, Math.sinh(1000)
assertEquals -Infinity, Math.sinh(-1000)

# Implementation-specific tests for cosh.
# Case |x| < 2^-55
assertEquals 1, Math.cosh(Math.pow(2, -56))
assertEquals 1, Math.cosh(-Math.pow(2, -56))

# Case |x| < 1/2*log(2). cosh(Math.LN2/4) = (sqrt(2)+1)/2^(5/4)
assertEquals 1.0150517651282178, Math.cosh(Math.LN2 / 4)
assertEquals 1.0150517651282178, Math.cosh(-Math.LN2 / 4)

# Case 1/2*log(2) < |x| < 22. cosh(10*Math.LN2) = 1048577/2048
assertEquals 512.00048828125, Math.cosh(10 * Math.LN2)
assertEquals 512.00048828125, Math.cosh(-10 * Math.LN2)

# Case 22 <= |x| < log(maxdouble)
assertEquals 2.1474836479999983e9, Math.cosh(32 * Math.LN2)
assertEquals 2.1474836479999983e9, Math.cosh(-32 * Math.LN2)

# Case log(maxdouble) <= |x| <= overflowthreshold
assertEquals 1.7976931348621744e308, Math.cosh(710.4758600739439)
assertEquals 1.7976931348621744e308, Math.cosh(-710.4758600739439)

# Overflow.
assertEquals Infinity, Math.cosh(710.475860073944)
assertEquals Infinity, Math.cosh(-710.475860073944)
