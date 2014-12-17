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
update = (test) ->
  test.newProperty = true
  return
description "Test to ensure that we handle caching of prototype chains containing dictionaries."
Test = ->

methodCount = 65
i = 0

while i < methodCount
  Test::["myMethod" + i] = ->
  i++
test1 = new Test()
for k of test1
  continue
Test::myAdditionalMethod = ->

test2 = new Test()
j = k
foundNewPrototypeProperty = false
for k of test2
  foundNewPrototypeProperty = true  if "myAdditionalMethod" is k
shouldBeTrue "foundNewPrototypeProperty"
Test = ->

i = 0

while i < methodCount
  Test::["myMethod" + i] = ->
  i++
test1 = new Test()
for k of test1
  continue
delete (Test::)[k]

test2 = new Test()
j = k
foundRemovedPrototypeProperty = false
for k of test2
  foundRemovedPrototypeProperty = true  if j is k
shouldBeFalse "foundRemovedPrototypeProperty"
Test = ->

i = 0

while i < methodCount
  Test::["myMethod" + i] = ->
  i++
test1 = new Test()
update test1
test2 = new Test()
update test2
test3 = new Test()
update test3
calledNewPrototypeSetter = false
Test::__defineSetter__ "newProperty", ->
  calledNewPrototypeSetter = true
  return

test4 = new Test()
update test4
shouldBeTrue "calledNewPrototypeSetter"
test4 = __proto__:
  prop: "on prototype"

i = 0

while i < 200
  test4[i] = [i]
  i++
test5 = __proto__:
  __proto__:
    prop: "on prototype's prototype"

i = 0

while i < 200
  test5[i] = [i]
  i++
getTestProperty = (o) ->
  o.prop

getTestProperty test4
getTestProperty test4
shouldBe "getTestProperty(test4)", "\"on prototype\""
test4.prop = "on self"
shouldBe "getTestProperty(test4)", "\"on self\""
getTestProperty = (o) ->
  o.prop

getTestProperty test5
getTestProperty test5
shouldBe "getTestProperty(test5)", "\"on prototype's prototype\""
test5.prop = "on self"
shouldBe "getTestProperty(test5)", "\"on self\""
