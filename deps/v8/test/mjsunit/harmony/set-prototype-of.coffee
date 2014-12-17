# Copyright 2014 the V8 project authors. All rights reserved.
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
getObjects = ->
  func = ->
  [
    func
    new func()
    {
      x: 5
    }
    /regexp/
    ["array"]
    
    # new Error(),
    new Date()
    new Number(1)
    new Boolean(true)
    new String("str")
    Object(Symbol())
  ]
TestSetPrototypeOfCoercibleValues = ->
  i = 0

  while i < coercibleValues.length
    value = coercibleValues[i]
    assertThrows (->
      Object.getPrototypeOf value
      return
    ), TypeError
    assertEquals Object.setPrototypeOf(value, {}), value
    assertThrows (->
      Object.getPrototypeOf value
      return
    ), TypeError
    i++
  return
TestSetPrototypeOfNonCoercibleValues = ->
  i = 0

  while i < nonCoercibleValues.length
    value = nonCoercibleValues[i]
    assertThrows (->
      Object.setPrototypeOf value, {}
      return
    ), TypeError
    i++
  return
TestSetPrototypeToNonObject = (proto) ->
  objects = getObjects()
  i = 0

  while i < objects.length
    object = objects[i]
    j = 0

    while j < valuesWithoutNull.length
      proto = valuesWithoutNull[j]
      assertThrows (->
        Object.setPrototypeOf object, proto
        return
      ), TypeError
      j++
    i++
  return
TestSetPrototypeOf = (object, proto) ->
  assertEquals Object.setPrototypeOf(object, proto), object
  assertEquals Object.getPrototypeOf(object), proto
  return
TestSetPrototypeOfForObjects = ->
  objects1 = getObjects()
  objects2 = getObjects()
  i = 0

  while i < objects1.length
    j = 0

    while j < objects2.length
      TestSetPrototypeOf objects1[i], objects2[j]
      j++
    i++
  return
TestSetPrototypeToNull = ->
  objects = getObjects()
  i = 0

  while i < objects.length
    TestSetPrototypeOf objects[i], null
    i++
  return
TestSetPrototypeOfNonExtensibleObject = ->
  objects = getObjects()
  proto = {}
  i = 0

  while i < objects.length
    object = objects[i]
    Object.preventExtensions object
    assertThrows (->
      Object.setPrototypeOf object, proto
      return
    ), TypeError
    i++
  return
TestLookup = ->
  object = {}
  assertFalse "x" of object
  assertFalse "y" of object
  oldProto =
    x: "old x"
    y: "old y"

  Object.setPrototypeOf object, oldProto
  assertEquals object.x, "old x"
  assertEquals object.y, "old y"
  newProto = x: "new x"
  Object.setPrototypeOf object, newProto
  assertEquals object.x, "new x"
  assertFalse "y" of object
  return
coercibleValues = [
  1
  true
  "string"
  Symbol()
]
nonCoercibleValues = [
  `undefined`
  null
]
valuesWithoutNull = coercibleValues.concat(`undefined`)
TestSetPrototypeOfCoercibleValues()
TestSetPrototypeOfNonCoercibleValues()
TestSetPrototypeToNonObject()
TestSetPrototypeOfForObjects()
TestSetPrototypeToNull()
TestSetPrototypeOfNonExtensibleObject()
TestLookup()
