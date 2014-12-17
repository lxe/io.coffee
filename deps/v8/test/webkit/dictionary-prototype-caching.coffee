# Copyright 2013 the V8 project authors. All rights reserved.
# Copyright (C) 2005, 2006, 2007, 2008, 2009 Apple Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
protoTest = (o) ->
  o.protoProp

# Prototype lookup caching will attempt to convert proto back to an ordinary structure
protoTest2 = (o) ->
  o.b
protoTest3 = (o) ->
  o.b
testFunction = (o) ->
  o.test
description "Test to ensure correct behaviour of prototype caching with dictionary prototypes"
proto =
  protoProp: "PASS"
  propToRemove: "foo"

o = __proto__: proto
delete proto.propToRemove

protoTest o
protoTest o
protoTest o
shouldBe "protoTest(o)", "'PASS'"
delete proto.protoProp

proto.fakeProtoProp = "FAIL"
shouldBeUndefined "protoTest(o)"
proto =
  a: 1
  b: "meh"
  c: 2

o = __proto__: proto
delete proto.b

proto.d = 3
protoTest2 o
protoTest2 o
protoTest2 o
protoKeys = []
for i of proto
  protoKeys.push proto[i]
shouldBe "protoKeys", "[1,2,3]"
proto =
  a: 1
  b: "meh"
  c: 2

o = __proto__: proto
delete proto.b

protoTest2 o
protoTest2 o
protoTest2 o
proto.d = 3
protoKeys = []
for i of proto
  protoKeys.push proto[i]
shouldBe "protoKeys", "[1,2,3]"
proto = test: true
subclass1 = __proto__: proto
subclass2 = __proto__: proto
i = 0

while i < 500
  subclass2["a" + i] = "a" + i
  i++
testFunction subclass1
shouldBeTrue "testFunction(subclass1)"
shouldBeTrue "testFunction(subclass2)"
proto.test = false
subclass2.test = true
shouldBeTrue "testFunction(subclass2)"
