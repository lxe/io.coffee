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
leftConstantRightSimple = (a) ->
  0.1 * (a * a)
leftConstantRightComplex = (a) ->
  0.1 * (a * a + a)
leftSimpleRightConstant = (a) ->
  (a * a) * 0.1
leftComplexRightConstant = (a) ->
  (a * a + a) * 0.1
leftThisRightSimple = (a) ->
  this * (a * a)
leftThisRightComplex = (a) ->
  this * (a * a + a)
leftSimpleRightThis = (a) ->
  (a * a) * this
leftComplexRightThis = (a) ->
  (a * a + a) * this
description "This test checks corner cases of the number cell reuse code. In particular, it checks for known cases where code generation for number cell reuse caused assertions to fail."
shouldBe "leftConstantRightSimple(2)", "0.4"
shouldBe "leftConstantRightComplex(1)", "0.2"
shouldBe "leftSimpleRightConstant(2)", "0.4"
shouldBe "leftComplexRightConstant(1)", "0.2"
shouldBeNaN "leftThisRightSimple(2)"
shouldBe "leftThisRightSimple.call(2, 2)", "8"
shouldBeNaN "leftThisRightComplex(2)"
shouldBe "leftThisRightComplex.call(2, 2)", "12"
shouldBeNaN "leftSimpleRightThis(2)"
shouldBe "leftSimpleRightThis.call(2, 2)", "8"
shouldBeNaN "leftComplexRightThis(2)"
shouldBe "leftComplexRightThis.call(2, 2)", "12"
