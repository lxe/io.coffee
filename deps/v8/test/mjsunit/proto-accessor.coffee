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

# Fake Symbol if undefined, allowing test to run in non-Harmony mode as well.
TestNoPoisonPill = ->
  assertEquals "function", typeof desc.get
  assertEquals "function", typeof desc.set
  assertDoesNotThrow "desc.get.call({})"
  assertDoesNotThrow "desc.set.call({}, {})"
  obj = {}
  obj2 = {}
  desc.set.call obj, obj2
  assertEquals obj.__proto__, obj2
  assertEquals desc.get.call(obj), obj2
  return
TestRedefineObjectPrototypeProtoGetter = ->
  Object.defineProperty Object::, "__proto__",
    get: ->
      42

  assertEquals {}.__proto__, 42
  assertEquals desc.get.call({}), Object::
  desc2 = Object.getOwnPropertyDescriptor(Object::, "__proto__")
  assertEquals desc2.get.call({}), 42
  assertEquals desc2.set.call({}), `undefined`
  Object.defineProperty Object::, "__proto__",
    set: (x) ->

  desc3 = Object.getOwnPropertyDescriptor(Object::, "__proto__")
  assertEquals desc3.get.call({}), 42
  assertEquals desc3.set.call({}), `undefined`
  return
TestRedefineObjectPrototypeProtoSetter = ->
  Object.defineProperty Object::, "__proto__",
    set: `undefined`

  assertThrows (->
    "use strict"
    o = {}
    p = {}
    o.__proto__ = p
    return
  ), TypeError
  return
TestGetProtoOfValues = ->
  assertEquals getProto.call(1), Number::
  assertEquals getProto.call(true), Boolean::
  assertEquals getProto.call(false), Boolean::
  assertEquals getProto.call("s"), String::
  assertEquals getProto.call(Symbol()), Symbol::
  assertThrows (->
    getProto.call null
    return
  ), TypeError
  assertThrows (->
    getProto.call `undefined`
    return
  ), TypeError
  return
TestSetProtoOfValues = ->
  proto = {}
  i = 0

  while i < values.length
    assertEquals setProto.call(values[i], proto), `undefined`
    i++
  assertThrows (->
    setProto.call null, proto
    return
  ), TypeError
  assertThrows (->
    setProto.call `undefined`, proto
    return
  ), TypeError
  return
TestSetProtoToValue = ->
  object = {}
  proto = {}
  setProto.call object, proto
  valuesWithUndefined = values.concat(`undefined`)
  i = 0

  while i < valuesWithUndefined.length
    assertEquals setProto.call(object, valuesWithUndefined[i]), `undefined`
    assertEquals getProto.call(object), proto
    i++
  
  # null is the only valid value that can be used as a [[Prototype]].
  assertEquals setProto.call(object, null), `undefined`
  assertEquals getProto.call(object), null
  return
TestDeleteProto = ->
  assertTrue delete Object::__proto__

  o = {}
  p = {}
  o.__proto__ = p
  assertEquals Object.getPrototypeOf(o), Object::
  desc4 = Object.getOwnPropertyDescriptor(o, "__proto__")
  assertTrue desc4.configurable
  assertTrue desc4.enumerable
  assertTrue desc4.writable
  assertEquals desc4.value, p
  return
@Symbol = (if typeof Symbol isnt "undefined" then Symbol else String)
desc = Object.getOwnPropertyDescriptor(Object::, "__proto__")
getProto = desc.get
setProto = desc.set
TestNoPoisonPill()
TestRedefineObjectPrototypeProtoGetter()
TestRedefineObjectPrototypeProtoSetter()
TestGetProtoOfValues()
values = [
  1
  true
  false
  "s"
  Symbol()
]
TestSetProtoOfValues()
TestSetProtoToValue()
TestDeleteProto()
