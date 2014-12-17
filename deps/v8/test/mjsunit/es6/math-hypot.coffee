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

# Check function length.

# Check that 0 is returned for no arguments.

# Check that Infinity is returned if any of the arguments is +/-Infinity.

# Check that NaN is returned if any argument is NaN and none is +/-Infinity/

# Check that +0 is returned if all arguments are +/-0.

# Check that we avoid overflows and underflows.

# Check that we sufficiently account for rounding errors when summing up.
# For this, we calculate a simple fractal square that recurses in the
# fourth quarter.

# Also shuffle the array.
random_sort = (a, b) ->
  c++
  (c & 3) - 1.5
assertTrue isNaN(Math.hypot({}))
assertTrue isNaN(Math.hypot(`undefined`, 1))
assertTrue isNaN(Math.hypot(1, `undefined`))
assertTrue isNaN(Math.hypot(Math.hypot, 1))
assertEquals 1, Math.hypot(1)
assertEquals Math.PI, Math.hypot(Math.PI)
assertEquals 5, Math.hypot(3, 4)
assertEquals 13, Math.hypot(3, 4, 12)
assertEquals 15, Math.hypot(" 2 ", "0x5",
  valueOf: ->
    "0xe"
)
assertEquals 17, Math.hypot(
  valueOf: ->
    1
,
  toString: ->
    12
,
  toString: ->
    "12"
)
assertEquals 2, Math.hypot.length
assertEquals 0, Math.hypot()
assertEquals "Infinity", String(Math.hypot(NaN, Infinity))
assertEquals "Infinity", String(Math.hypot(1, -Infinity, 2))
assertTrue isNaN(Math.hypot(1, 2, NaN))
assertTrue isNaN(Math.hypot(NaN, NaN, 4))
assertEquals "Infinity", String(1 / Math.hypot(-0))
assertEquals "Infinity", String(1 / Math.hypot(0))
assertEquals "Infinity", String(1 / Math.hypot(-0, -0))
assertEquals "Infinity", String(1 / Math.hypot(-0, 0))
assertEqualsDelta 5e300, Math.hypot(3e300, 4e300), 1e285
assertEqualsDelta 17e-300, Math.hypot(8e-300, 15e-300), 1e-315
assertEqualsDelta 19e300, Math.hypot(6e300, 6e300, 17e300), 1e285
fractals = []
edge_length = Math.E * 1e20
fractal_length = edge_length
while fractal_length >= 1
  fractal_length *= 0.5
  fractals.push fractal_length
  fractals.push fractal_length
  fractals.push fractal_length
fractals.push fractal_length
assertEqualsDelta edge_length, Math.hypot.apply(Math, fractals), 1e-15
fractals.reverse()
assertEqualsDelta edge_length, Math.hypot.apply(Math, fractals), 1e-15
c = 0
fractals.sort random_sort
assertEqualsDelta edge_length, Math.hypot.apply(Math, fractals), 1e-15
fractals.sort random_sort
assertEqualsDelta edge_length, Math.hypot.apply(Math, fractals), 1e-15
