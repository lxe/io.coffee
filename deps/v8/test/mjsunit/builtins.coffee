# Copyright 2011 the V8 project authors. All rights reserved.
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

# Flags: --expose-natives-as=builtins

# Checks that all function properties of the builtin object that are actually
# constructors (recognized by having properties on their .prototype object),
# have only unconfigurable properties on the prototype, and the methods
# are also non-writable.
isFunction = (obj) ->
  typeof obj is "function"
isV8Native = (name) ->
  name is "GeneratorFunctionPrototype" or name is "SetIterator" or name is "MapIterator" or name is "ArrayIterator" or name is "StringIterator"
checkConstructor = (func, name) ->
  
  # A constructor is a function with a prototype and properties on the
  # prototype object besides "constructor";
  return  if name.charAt(0) is "$"
  return  unless typeof func:: is "object"
  propNames = Object.getOwnPropertyNames(func::)
  
  # Not a constructor.
  return  if propNames.length is 0 or (propNames.length is 1 and propNames[0] is "constructor")
  proto_desc = Object.getOwnPropertyDescriptor(func, "prototype")
  assertTrue proto_desc.hasOwnProperty("value"), name
  assertFalse proto_desc.writable, name
  assertFalse proto_desc.configurable, name
  prototype = proto_desc.value
  assertEquals (if isV8Native(name) then Object:: else null), Object.getPrototypeOf(prototype), name
  i = 0

  while i < propNames.length
    propName = propNames[i]
    continue  if propName is "constructor"
    continue  if isV8Native(name)
    testName = name + "-" + propName
    propDesc = Object.getOwnPropertyDescriptor(prototype, propName)
    assertTrue propDesc.hasOwnProperty("value"), testName
    assertFalse propDesc.configurable, testName
    assertFalse propDesc.writable, testName  if isFunction(propDesc.value)
    i++
  return
names = Object.getOwnPropertyNames(builtins)
i = 0

while i < names.length
  name = names[i]
  desc = Object.getOwnPropertyDescriptor(builtins, name)
  assertTrue desc.hasOwnProperty("value")
  value = desc.value
  checkConstructor value, name  if isFunction(value)
  i++
