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
foo = (array) ->
  result = 0
  i = 0

  while i < array.length
    result += array[i]
    ++i
  result
bar = (array) ->
  array[1] = 42
  return
description "Tests that passing the global object to an array access that will arrayify to NonArrayWithArrayStorage doesn't break things."
array = {}
array.length = 3
array[0] = 1
array[1] = 2
array[2] = 3
i = 0

while i < 200
  shouldBe "foo(array)", "6"
  otherArray = {}
  bar otherArray
  shouldBe "otherArray[1]", "42"
  ++i
i = 0

while i < 1000
  
  # Do strange things to ensure that the get_by_id on length goes polymorphic.
  array = {}
  array.x = 42  if i % 2
  array.length = 3
  array[0] = 1
  array[2] = 3
  array.__defineGetter__ 1, ->
    6

  shouldBe "foo(array)", "10"
  otherArray = {}
  otherArray.__defineSetter__ 0, (value) ->
    throw "error"return

  bar otherArray
  shouldBe "otherArray[1]", "42"
  ++i
w = this
w[0] = 1
w.length = 1
thingy = false
w.__defineSetter__ 1, (value) ->
  thingy = value
  return

shouldBe "foo(w)", "1"
shouldBe "thingy", "false"

# At this point we check to make sure that bar doesn't end up either creating array storage for
# the window proxy, or equally badly, storing to the already created array storage on the proxy
# (since foo() may have made the mistake of creating array storage). That's why we do the setter
# thingy, to detect that for index 1 we fall through the proxy to the real window object.
bar w
shouldBe "thingy", "42"
shouldBe "foo(w)", "1"
w.length = 2
shouldBe "foo(w)", "0/0"
