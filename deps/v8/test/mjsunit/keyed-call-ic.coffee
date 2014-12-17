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

# A test for keyed call ICs.
globalFunction1 = ->
  "function1"
globalFunction2 = ->
  "function2"
testGlobals = ->
  assertEquals "[object global]", this[toStringName]()
  assertEquals "[object global]", global[toStringName]()
  return
F = ->
testKeyTransitions = ->
  i = undefined
  key = undefined
  result = undefined
  message = undefined
  f = new F()
  
  # Custom call generators
  array = []
  i = 0
  while i isnt 10
    key = (if (i < 8) then "push" else "pop")
    array[key] i
    i++
  assertEquals 6, array.length
  i = 0
  while i isnt array.length
    assertEquals i, array[i]
    i++
  i = 0
  while i isnt 10
    key = (if (i < 3) then "pop" else "push")
    array[key] i
    i++
  assertEquals 10, array.length
  i = 0
  while i isnt array.length
    assertEquals i, array[i]
    i++
  string = "ABCDEFGHIJ"
  i = 0
  while i isnt 10
    key = ((if (i < 5) then "charAt" else "charCodeAt"))
    result = string[key](i)
    message = "'" + string + "'['" + key + "'](" + i + ")"
    if i < 5
      assertEquals string.charAt(i), result, message
    else
      assertEquals string.charCodeAt(i), result, message
    i++
  i = 0
  while i isnt 10
    key = ((if (i < 5) then "charCodeAt" else "charAt"))
    result = string[key](i)
    message = "'" + string + "'['" + key + "'](" + i + ")"
    if i < 5
      assertEquals string.charCodeAt(i), result, message
    else
      assertEquals string.charAt(i), result, message
    i++
  
  # Function is a constant property
  key = "one"
  i = 0
  while i isnt 10
    assertEquals key, f[key]()
    key = "two"  if i is 5 # the name change should case a miss
    i++
  
  # Function is a fast property
  f.field = ->
    "field"

  key = "field"
  i = 0
  while i isnt 10
    assertEquals key, f[key]()
    key = "two"  if i is 5 # the name change should case a miss
    i++
  
  # Calling on slow case object
  f.prop = 0
  delete f.prop # force the object to the slow case

  f.four = ->
    "four"

  f.five = ->
    "five"

  key = "four"
  i = 0
  while i isnt 10
    assertEquals key, f[key]()
    key = "five"  if i is 5
    i++
  
  # Calling on global object
  key = "globalFunction1"
  expect = "function1"
  i = 0
  while i isnt 10
    assertEquals expect, global[key]()
    if i is 5
      key = "globalFunction2"
      expect = "function2"
    i++
  return
testTypeTransitions = ->
  f = new F()
  s = ""
  m = "one"
  i = undefined
  s = ""
  i = 0
  while i isnt 10
    if i is 5
      F::one = ->
        "1"
    s += f[m]()
    i++
  assertEquals "oneoneoneoneone11111", s
  s = ""
  i = 0
  while i isnt 10
    if i is 5
      f.__proto__ = one: ->
        "I"
    s += f[m]()
    i++
  assertEquals "11111IIIII", s
  s = ""
  i = 0
  while i isnt 10
    if i is 5
      f.one = ->
        "ONE"
    s += f[m]()
    i++
  assertEquals "IIIIIONEONEONEONEONE", s
  m = "toString"
  s = ""
  obj = toString: ->
    "2"

  i = 0
  while i isnt 10
    obj = "TWO"  if i is 5
    s += obj[m]()
    i++
  assertEquals "22222TWOTWOTWOTWOTWO", s
  s = ""
  obj = toString: ->
    "ONE"

  m = "toString"
  i = 0
  while i isnt 10
    obj = 1  if i is 5
    s += obj[m]()
    i++
  assertEquals "ONEONEONEONEONE11111", s
  return
toStringName = "toString"
global = this
assertEquals "[object global]", this[toStringName]()
assertEquals "[object global]", global[toStringName]()
testGlobals()
F::one = ->
  "one"

F::two = ->
  "two"

F::three = ->
  "three"

keys = [
  "one"
  "one"
  "one"
  "one"
  "two"
  "two"
  "one"
  "three"
  "one"
  "two"
]
testKeyTransitions()
testTypeTransitions()
