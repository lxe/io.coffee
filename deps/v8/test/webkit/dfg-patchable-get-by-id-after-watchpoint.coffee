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
foo = (o, p) ->
  a = p.f
  b = o.f # Watchpoint.
  c = p.g # Patchable GetById.
  b a + c
O = ->
P1 = ->
P2 = ->
description "This tests that a patchable GetById right after a watchpoint has the appropriate nop padding."
O::f = (x) ->
  x + 1

o = new O()
P1::g = 42
P2::g = 24
p1 = new P1()
p2 = new P2()
p1.f = 1
p2.f = 2
i = 0

while i < 200
  p = (if (i % 2) then p1 else p2)
  expected = (if (i % 2) then 44 else 27)
  if i is 150
    
    # Cause first the watchpoint on o.f to fire, and then the GetById
    # to be reset.
    O::g = 57 # Fire the watchpoint.
    P1::h = 58 # Reset the GetById.
    P2::h = 59 # Not necessary, but what the heck - this resets the GetById even more.
  shouldBe "foo(o, p)", "" + expected
  ++i
