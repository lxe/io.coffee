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

# This file only tests very simple descriptors that always have
# configurable, enumerable, and writable set to true.
# A range of more elaborate tests are performed in
# object-define-property.js

# Flags: --stress-runs=5
get = ->
  x
set = (x) ->
  @x = x
  return

# String objects.

# Support for additional attributes on string objects.

# Test that elements in the prototype chain is not returned.

# Test elements on global proxy object.
el_getter = ->
  239
el_setter = ->
obj = x: 1
obj.__defineGetter__ "accessor", get
obj.__defineSetter__ "accessor", set
a = new Array()
a[1] = 42
obj[1] = 42
descIsData = Object.getOwnPropertyDescriptor(obj, "x")
assertTrue descIsData.enumerable
assertTrue descIsData.writable
assertTrue descIsData.configurable
descIsAccessor = Object.getOwnPropertyDescriptor(obj, "accessor")
assertTrue descIsAccessor.enumerable
assertTrue descIsAccessor.configurable
assertTrue descIsAccessor.get is get
assertTrue descIsAccessor.set is set
descIsNotData = Object.getOwnPropertyDescriptor(obj, "not-x")
assertTrue not descIsNotData?
descIsNotAccessor = Object.getOwnPropertyDescriptor(obj, "not-accessor")
assertTrue not descIsNotAccessor?
descArray = Object.getOwnPropertyDescriptor(a, "1")
assertTrue descArray.enumerable
assertTrue descArray.configurable
assertTrue descArray.writable
assertEquals descArray.value, 42
descObjectElement = Object.getOwnPropertyDescriptor(obj, "1")
assertTrue descObjectElement.enumerable
assertTrue descObjectElement.configurable
assertTrue descObjectElement.writable
assertEquals descObjectElement.value, 42
a = new String("foobar")
i = 0

while i < a.length
  descStringObject = Object.getOwnPropertyDescriptor(a, i)
  assertTrue descStringObject.enumerable
  assertFalse descStringObject.configurable
  assertFalse descStringObject.writable
  assertEquals descStringObject.value, a.substring(i, i + 1)
  i++
a.x = 42
a[10] = "foo"
descStringProperty = Object.getOwnPropertyDescriptor(a, "x")
assertTrue descStringProperty.enumerable
assertTrue descStringProperty.configurable
assertTrue descStringProperty.writable
assertEquals descStringProperty.value, 42
descStringElement = Object.getOwnPropertyDescriptor(a, "10")
assertTrue descStringElement.enumerable
assertTrue descStringElement.configurable
assertTrue descStringElement.writable
assertEquals descStringElement.value, "foo"
proto = {}
proto[10] = 42
objWithProto = new Array()
objWithProto:: = proto
objWithProto[0] = "bar"
descWithProto = Object.getOwnPropertyDescriptor(objWithProto, "10")
assertEquals `undefined`, descWithProto
global = (->
  this
)()
global[42] = 42
Object.defineProperty global, "239",
  get: el_getter
  set: el_setter

descRegularElement = Object.getOwnPropertyDescriptor(global, "42")
assertEquals 42, descRegularElement.value
descAccessorElement = Object.getOwnPropertyDescriptor(global, "239")
assertEquals el_getter, descAccessorElement.get
assertEquals el_setter, descAccessorElement.set
