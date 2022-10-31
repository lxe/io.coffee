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
f1 = ->
  for j of []
    continue
  return
description "This test checks for a couple of specific ways that bugs in toString() round trips have changed the meanings of functions with var declarations inside for loops."
f2 = ->
  j = 1

  while j < 10
    ++j
  return

f3 = ->
  j = 1
  while j < 10
    ++j
  return

f4 = ->
  j = undefined

  loop

  return

unevalf = (x) ->
  "(" + x.toString() + ")"

shouldBe "unevalf(eval(unevalf(f1)))", "unevalf(f1)"
shouldBe "unevalf(eval(unevalf(f2)))", "unevalf(f2)"
shouldBe "unevalf(eval(unevalf(f3)))", "unevalf(f3)"
shouldBe "unevalf(eval(unevalf(f4)))", "unevalf(f4)"
shouldBe "unevalf(f2) != unevalf(f3)", "true"