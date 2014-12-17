# Copyright 2012 the V8 project authors. All rights reserved.
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

# Tests that the --fast-math implementation of Math.exp() has
# reasonable precision.
exp = (x) ->
  Math.exp x
assertAlmostEquals = (expected, actual, x) ->
  return  if expected is 0 and actual is 0 # OK
  return  if expected is Number.POSITIVE_INFINITY and actual is Number.POSITIVE_INFINITY # OK
  relative_diff = Math.abs(expected / actual - 1)
  assertTrue relative_diff < 1e-12, "relative difference of " + relative_diff + " for input " + x
  return
first_call_result = exp(Math.PI)
second_call_result = exp(Math.PI)
increment = Math.PI / 35 # Roughly 0.1, but we want to try many
# different mantissae.
x = -708

while x < 710
  ex = exp(x)
  reference = Math.pow(Math.E, x)
  assertAlmostEquals reference, ex, x
  if ex > 0 and isFinite(ex)
    back = Math.log(ex)
    assertAlmostEquals x, back, x + " (backwards)"
  x += increment

# Make sure optimizing the function does not alter the result.
last_call_result = exp(Math.PI)
assertEquals first_call_result, second_call_result
assertEquals first_call_result, last_call_result
