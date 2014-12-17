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
forIn1 = ->
  result = []
  o = x: 1
  for p of o
    result.push p
  result
forIn2 = ->
  result = []
  o =
    x: 1
    __proto__: null

  for p of o
    result.push p
  result
forIn3 = (proto) ->
  result = []
  o =
    x: 1
    __proto__: proto

  for p of o
    result.push p
  result
forIn4 = (o) ->
  result = []
  for p of o
    result.push p
  result
forIn5 = (o) ->
  for i of o
    continue
  return
cacheClearing = ->
  j = 0

  while j < 10
    o =
      a: 1
      b: 2
      c: 3
      d: 4
      e: 5

    try
      for i of o
        delete o.a

        o = null
        throw ""
    finally
      continue
    j++
  return
description "This tests that for/in statements behave correctly when cached."
forIn1()
Object::y = 2
shouldBe "forIn1()", "['x', 'y']"
delete Object::y

forIn2()
shouldBe "forIn2()", "['x']"
forIn3 __proto__:
  y1: 2

forIn3 __proto__:
  y1: 2

shouldBe "forIn3({ __proto__: { y1: 2 } })", "['x', 'y1']"
forIn3
  y2: 2
  __proto__: null

forIn3
  y2: 2
  __proto__: null

shouldBe "forIn3({ y2 : 2, __proto__: null })", "['x', 'y2']"
forIn3 __proto__:
  __proto__:
    y3: 2

forIn3 __proto__:
  __proto__:
    y3: 2

shouldBe "forIn3({ __proto__: { __proto__: { y3 : 2 } } })", "['x', 'y3']"
objectWithArrayAsProto = {}
objectWithArrayAsProto.__proto__ = []
shouldBe "forIn4(objectWithArrayAsProto)", "[]"
objectWithArrayAsProto.__proto__[0] = 1
shouldBe "forIn4(objectWithArrayAsProto)", "['0']"
shouldBe "forIn5({get foo() { return 'called getter'} })", "['foo', 'called getter']"
shouldBe "forIn5({set foo(v) { } })", "['foo', undefined]"
shouldBe "forIn5({get foo() { return 'called getter'}, set foo(v) { }})", "['foo', 'called getter']"
cacheClearing()
