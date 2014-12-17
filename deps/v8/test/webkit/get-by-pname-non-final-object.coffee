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
foo = (o) ->
  result = 0
  for n of o
    result += o[n]
  result
description "This tests that op_get_by_pname is compiled correctly for non-final objects."
o = new Date()
p = new Date()
q = new Date()
r = new Date()
s = new Date()
o.a = 1
o.b = 3
o.c = 7
p.a = 1
p.b = 2
p.c = 3
p.d = 4
q.a = 1
q.b = 2
q.c = 3
q.d = 4
q.e = 3457
r.a = 1
r.b = 2
r.c = 3
r.d = 4
r.e = 91
r.f = 12
s.a = 1
s.b = 2
s.c = 3
s.d = 4
s.e = 91
s.f = 12
s.g = 69
i = 0

while i < 100
  shouldBe "foo(o)", "11"
  shouldBe "foo(p)", "10"
  shouldBe "foo(q)", "3467"
  shouldBe "foo(r)", "113"
  shouldBe "foo(s)", "182"
  ++i
