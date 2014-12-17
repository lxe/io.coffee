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

# Flags: --expose-gc
for_in_null = ->
  try
    for x of null
      return false
  catch e
    return false
  true
for_in_undefined = ->
  try
    for x of `undefined`
      return false
  catch e
    return false
  true
Accumulate = (x) ->
  accumulator = ""
  for i of x
    accumulator += i
  accumulator

# We do not assume that for-in enumerates elements in order.
for_in_string_prototype = ->
  B = ->
    @bar = 5
    this[7] = 4
    return
  x = new String("abc")
  x.foo = 19
  B:: = x
  y = new B()
  y.gub = 13
  elements = Accumulate(y)
  elements1 = Accumulate(y)
  
  # If for-in returns elements in a different order on multiple calls, this
  # assert will fail.  If that happens, consider if that behavior is OK.
  assertEquals elements, elements1, "For-in elements not the same both times."
  
  # We do not assume that for-in enumerates elements in order.
  assertTrue -1 isnt elements.indexOf("0")
  assertTrue -1 isnt elements.indexOf("1")
  assertTrue -1 isnt elements.indexOf("2")
  assertTrue -1 isnt elements.indexOf("7")
  assertTrue -1 isnt elements.indexOf("foo")
  assertTrue -1 isnt elements.indexOf("bar")
  assertTrue -1 isnt elements.indexOf("gub")
  assertEquals 13, elements.length
  elements = Accumulate(x)
  assertTrue -1 isnt elements.indexOf("0")
  assertTrue -1 isnt elements.indexOf("1")
  assertTrue -1 isnt elements.indexOf("2")
  assertTrue -1 isnt elements.indexOf("foo")
  assertEquals 6, elements.length
  return
i = 0

while i < 10
  assertTrue for_in_null()
  gc()
  ++i
j = 0

while j < 10
  assertTrue for_in_undefined()
  gc()
  ++j
assertEquals 10, i
assertEquals 10, j
i = 0

while i < 3
  elements = Accumulate("abcd")
  assertTrue -1 isnt elements.indexOf("0")
  assertTrue -1 isnt elements.indexOf("1")
  assertTrue -1 isnt elements.indexOf("2")
  assertTrue -1 isnt elements.indexOf("3")
  assertEquals 4, elements.length
  ++i
for_in_string_prototype()
for_in_string_prototype()
