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
  loop
    break unless 0
  return
f2 = ->
  loop
    break unless 0
  return
f3 = ->
  loop
    break unless 0
  return
f4 = ->
  loop #empty
    break unless 0
  return
description "This test checks that toString() round-trip on a function that has do..while in JavaScript does not insert extra semicolon."
if typeof uneval is "undefined"
  uneval = (x) ->
    "(" + x.toString() + ")"
uf1 = uneval(f1)
ueuf1 = uneval(eval(uneval(f1)))
uf2 = uneval(f2)
ueuf2 = uneval(eval(uneval(f2)))
uf3 = uneval(f3)
ueuf3 = uneval(eval(uneval(f3)))
uf4 = uneval(f4)
ueuf4 = uneval(eval(uneval(f4)))
shouldBe "ueuf1", "uf1"
shouldBe "ueuf2", "uf2"
shouldBe "ueuf3", "uf3"
shouldBe "ueuf4", "uf4"
