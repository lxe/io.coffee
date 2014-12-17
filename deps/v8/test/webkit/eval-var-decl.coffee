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

# Check that the correct this value is passed to a function called having been caught from a throw, where the catch block contains an eval (bug#).
checkThis = ->
  "use strict"
  this is `undefined`
testEvalInCatch = ->
  try
    throw checkThis
  catch e
    eval ""
    return e()
  false
description "This test case checks whether variables cause properties to be defined even before reaching the declaration statement in various cases."
shouldBeTrue "this.hasOwnProperty(\"foo\")"
foo = 3
delete bar

shouldBeTrue "this.hasOwnProperty(\"bar\")"
bar = 3
firstEvalResult = eval("var result = this.hasOwnProperty(\"y\"); var y = 3; result")
shouldBeTrue "firstEvalResult"
secondEvalResult = eval("delete x; var result = this.hasOwnProperty(\"x\"); var x = 3; result")
shouldBeFalse "secondEvalResult"
thirdEvalResult = false
try
  thirdEvalResult = (->
    x = false
    try
      throw ""
    catch e
      eval "var x = true;"
    x
  )()
catch e
  thirdEvalResult = "Threw exception!"
shouldBeTrue "thirdEvalResult"
shouldBeTrue "testEvalInCatch()"
