# Copyright 2008 the V8 project authors. All rights reserved.
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
TestChains = ->
  F = ->
  A = {}
  B = {}
  C = {}
  B.__proto__ = A
  C.__proto__ = B
  F:: = A
  assertTrue C instanceof F
  assertTrue B instanceof F
  assertFalse A instanceof F
  F:: = B
  assertTrue C instanceof F
  assertFalse B instanceof F
  assertFalse A instanceof F
  F:: = C
  assertFalse C instanceof F
  assertFalse B instanceof F
  assertFalse A instanceof F
  return
TestExceptions = ->
  F = ->
  
  # Make sure to throw an exception if the function prototype
  # isn't a proper JavaScript object.
  G = ->
  items = [
    1
    new Number(42)
    true
    "string"
    new String("hest")
    {
      {}
    }
    []
    F
    new F()
    Object
    String
  ]
  exceptions = 0
  instanceofs = 0
  i = 0

  while i < items.length
    j = 0

    while j < items.length
      try
        instanceofs++  if items[i] instanceof items[j]
      catch e
        assertTrue e instanceof TypeError
        exceptions++
      j++
    i++
  assertEquals 10, instanceofs
  assertEquals 88, exceptions
  G:: = `undefined`
  assertThrows "({} instanceof G)"
  return
assertTrue {} instanceof Object
assertTrue [] instanceof Object
assertFalse {} instanceof Array
assertTrue [] instanceof Array
TestChains()
TestExceptions()
