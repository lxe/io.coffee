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
# 'AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# A test for keyed call ICs with a mix of smi and string keys.
testOne = (receiver, key, result) ->
  i = 0

  while i isnt 10
    assertEquals result, receiver[key]()
    i++
  return
testMany = (receiver, keys, results) ->
  i = 0

  while i isnt 10
    k = 0

    while k isnt keys.length
      assertEquals results[k], receiver[keys[k]]()
      k++
    i++
  return
TypeOfThis = ->
  typeof this

# Use a non-symbol key to force inline cache to generic case.
zero = ->
  0
one = ->
  1
two = ->
  2

# Use a non-symbol key to force inline cache to generic case.
testException = (receiver, keys, exceptions) ->
  i = 0

  while i isnt 10
    k = 0

    while k isnt keys.length
      thrown = false
      try
        result = receiver[keys[k]]()
      catch e
        thrown = true
      assertEquals exceptions[k], thrown
      k++
    i++
  return
toStringNonSymbol = "to"
toStringNonSymbol += "String"
Number::square = ->
  this * this

Number::power4 = ->
  @square().square()

Number::type = TypeOfThis
String::type = TypeOfThis
Boolean::type = TypeOfThis
testOne 0, toStringNonSymbol, "0"
testOne 1, "toString", "1"
testOne "1", "toString", "1"
testOne 1.0, "toString", "1"
testOne 1, "type", "object"
testOne 2.3, "type", "object"
testOne "x", "type", "object"
testOne true, "type", "object"
testOne false, "type", "object"
testOne 2, "square", 4
testOne 2, "power4", 16
fixed_array = [
  zero
  one
  two
]
dict_array = [
  zero
  one
  two
]
dict_array[100000] = 1
fast_prop =
  zero: zero
  one: one
  two: two

normal_prop =
  zero: zero
  one: one
  two: two

normal_prop.x = 0
delete normal_prop.x

first3num = [
  0
  1
  2
]
first3str = [
  "zero"
  "one"
  "two"
]
testMany "123", [
  toStringNonSymbol
  "charAt"
  "charCodeAt"
], [
  "123"
  "1"
  49
]
testMany fixed_array, first3num, first3num
testMany dict_array, first3num, first3num
testMany fast_prop, first3str, first3num
testMany normal_prop, first3str, first3num
testException [ # hole
  zero
  one
], [
  0
  1
  2
], [
  false
  false
  true
]
