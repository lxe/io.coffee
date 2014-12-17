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
gc = ->
  if @GCController
    GCController.collect()
  else # Allocate a sufficient number of objects to force a GC.
    i = 0

    while i < 10000
      {}
      ++i
  return
eatRegisters = (param) ->
  return  if param > 10
  eatRegisters param + 1
  return
test1 = (a, b, b, b, b, b, b) ->
  ->
    a[0]
test2 = (a, a, a, a, a, a, b) ->
  ->
    b[0]
description "Tests to ensure that activations are built correctly in the face of duplicate parameter names and do not cause crashes."
test1Closure = test1(["success"])
extra = test1("success")
eatRegisters 0
gc()
shouldBe "test1Closure()", "\"success\""
test2Closure = test2("success", "success", "success", "success", "success", "success", ["success"])
extra = test2("success", "success", "success", "success", "success", "success", ["success"])
eatRegisters 0
gc()
shouldBe "test2Closure()", "\"success\""
