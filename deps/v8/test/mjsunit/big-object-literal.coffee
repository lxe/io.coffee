# Copyright 2009 the V8 project authors. All rights reserved.
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

# Test that we can make large object literals that work.
# Also test that we can attempt to make even larger object literals without
# crashing.
testLiteral = (size, array_in_middle) ->
  print size
  f = undefined
  
  # Build object-literal string.
  literal = "function f() { return "
  i = 0

  while i < size
    literal += "{a:"
    i++
  literal += (if array_in_middle then " [42.2]" else "{a:42.2}")
  i = 0

  while i < size
    literal += "}"
    literal += ", b:42, c:/asd/, x:'foo', y:[], z:new Object()"  if i < size - 1
    i++
  literal += "; }"
  
  # Create the object literal.
  eval literal
  x = f()
  
  # Check that the properties have the expected values.
  i = 0

  while i < size
    x = x.a
    i++
  if array_in_middle
    assertEquals(42.2, x[0])
    "x array in middle"

    x[0] = 41.2
  else
    assertEquals 42.2, x.a, "x object in middle"
    x.a = 41.2
  y = f()
  i = 0

  while i < size
    y = y.a
    i++
  if array_in_middle
    assertEquals 42.2, y[0], "y array in middle"
    y[0] = 41.2
  else
    assertEquals 42.2, y.a, "y object in middle"
    y.a = 41.2
  return

# The sizes to test.

# Run the test.
checkExpectedException = (e) ->
  assertInstanceof e, RangeError
  assertTrue e.message.indexOf("Maximum call stack size exceeded") >= 0
  return
testLiteralAndCatch = (size) ->
  big_enough = false
  try
    testLiteral size, false
  catch e
    checkExpectedException e
    big_enough = true
  try
    testLiteral size, true
  catch e
    checkExpectedException e
    big_enough = true
  big_enough
sizes = [
  1
  2
  100
  200
]
i = 0

while i < sizes.length
  testLiteral sizes[i], false
  testLiteral sizes[i], true
  i++

# Catch stack overflows.
testLiteralAndCatch(1000) or testLiteralAndCatch(20000) or testLiteralAndCatch(200000)
