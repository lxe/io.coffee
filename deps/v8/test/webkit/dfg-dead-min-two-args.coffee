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
foo = (a, b) ->
  Math.min a.f, b.f
  100
bar = (a, b) ->
  Math.min a.f, b.f
  100
description "Tests that a dead use of Math.min(a,b) at least speculates that its arguments are indeed numbers."
x = f: 42
y = f: 43
ok = null
expected = 42
empty = ""
i = 0

while i < 200
  if i is 150
    x = f:
      valueOf: ->
        ok = i
        37

    expected = 37
  result = eval(empty + "foo(x, y)")
  shouldBe "ok", "" + i  if i >= 150
  shouldBe "result", "100"
  ++i
x = f: 42
y = f: 43
ok = null
expected = 42
i = 0

while i < 200
  if i is 150
    y = f:
      valueOf: ->
        ok = i
        37

    expected = 37
  result = eval(empty + "bar(x, y)")
  shouldBe "ok", "" + i  if i >= 150
  shouldBe "result", "100"
  ++i
