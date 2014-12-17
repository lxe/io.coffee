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
if_less_test = ->
  a = 0
  b = 2
  a is 1  if a = 1 < 2
if_else_less_test = ->
  a = 0
  b = 2
  if a = 1 < 2
    a is 1
  else
    false
conditional_less_test = ->
  a = 0
  b = 2
  (if (a = 1 < 2) then a is 1 else false)
logical_and_less_test = ->
  a = 0
  b = 2
  (a = 1 < 2) and a is 1
logical_or_less_test = ->
  a = 0
  b = 2
  result = (a = 1 < 2) or a is 1
  a is 1
do_while_less_test = ->
  a = 0
  count = 0
  loop
    return a is 1  if count is 1
    count++
    break unless a = 1 < 2
  return
while_less_test = ->
  a = 0
  return a is 1  while a = 1 < 2
  return
for_less_test = ->
  a = 0

  while a = 1 < 2
    return a is 1
  return
description "Tests whether peephole optimizations on bytecode properly deal with local registers."
shouldBeTrue "if_less_test()"
shouldBeTrue "if_else_less_test()"
shouldBeTrue "conditional_less_test()"
shouldBeTrue "logical_and_less_test()"
shouldBeTrue "logical_or_less_test()"
shouldBeTrue "do_while_less_test()"
shouldBeTrue "while_less_test()"
shouldBeTrue "for_less_test()"
