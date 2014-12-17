# Copyright 2010 the V8 project authors. All rights reserved.
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
MaxLT = (x, y) ->
  return y  if x < y
  x
MaxLE = (x, y) ->
  return y  if x <= y
  x
MaxGE = (x, y) ->
  return x  if x >= y
  y
MaxGT = (x, y) ->
  return x  if x > y
  y

# First test primitive values.
TestPrimitive = (max, x, y) ->
  assertEquals max, MaxLT(x, y), "MaxLT - primitive"
  assertEquals max, MaxLE(x, y), "MaxLE - primitive"
  assertEquals max, MaxGE(x, y), "MaxGE - primitive"
  assertEquals max, MaxGT(x, y), "MaxGT - primitive"
  return

# Test non-primitive values and watch for valueOf call order.
TestNonPrimitive = (order, f) ->
  result = ""
  x = valueOf: ->
    result += "x"
    return

  y = valueOf: ->
    result += "y"
    return

  f x, y
  assertEquals order, result
  return

# Test compare in case of aliased registers.
CmpX = (x) ->
  42  if x is x
CmpXY = (x) ->
  y = x
  42  if x is y

# Test compare against null.
CmpNullValue = (x) ->
  not x?
CmpNullTest = (x) ->
  return 42  unless x?
  0
CmpNullEffect = ->
  not (g1 = 42)?
  return
TestPrimitive 1, 0, 1
TestPrimitive 1, 1, 0
TestPrimitive 4, 3, 4
TestPrimitive 4, 4, 3
TestPrimitive 0, -1, 0
TestPrimitive 0, 0, -1
TestPrimitive -2, -2, -3
TestPrimitive -2, -3, -2
TestPrimitive 1, 0.1, 1
TestPrimitive 1, 1, 0.1
TestPrimitive 4, 3.1, 4
TestPrimitive 4, 4, 3.1
TestPrimitive 0, -1.1, 0
TestPrimitive 0, 0, -1.1
TestPrimitive -2, -2, -3.1
TestPrimitive -2, -3.1, -2
TestNonPrimitive "xy", MaxLT
TestNonPrimitive "xy", MaxLE
TestNonPrimitive "xy", MaxGE
TestNonPrimitive "xy", MaxGT
assertEquals 42, CmpX(0)
assertEquals 42, CmpXY(0)
assertEquals false, CmpNullValue(42)
assertEquals 42, CmpNullTest(null)
g1 = 0
CmpNullEffect()
assertEquals 42, g1
