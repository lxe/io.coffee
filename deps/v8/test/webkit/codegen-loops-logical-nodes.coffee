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
while_or_eq = ->
  a = 0
  return true  while a is 0 or a is 0
  false
while_or_neq = ->
  a = 0
  return true  while a isnt 1 or a isnt 1
  false
while_or_less = ->
  a = 0
  return true  while a < 1 or a < 1
  false
while_or_lesseq = ->
  a = 0
  return true  while a <= 1 or a <= 1
  false
while_and_eq = ->
  a = 0
  return true  while a is 0 and a is 0
  false
while_and_neq = ->
  a = 0
  return true  while a isnt 1 and a isnt 1
  false
while_and_less = ->
  a = 0
  return true  while a < 1 and a < 1
  false
while_and_lesseq = ->
  a = 0
  return true  while a <= 1 and a <= 1
  false
for_or_eq = ->
  a = 0

  while a is 0 or a is 0
    return true
  false
for_or_neq = ->
  a = 0

  while a isnt 1 or a isnt 1
    return true
  false
for_or_less = ->
  a = 0

  while a < 1 or a < 1
    return true
  false
for_or_lesseq = ->
  a = 0

  while a <= 1 or a <= 1
    return true
  false
for_and_eq = ->
  a = 0

  while a is 0 and a is 0
    return true
  false
for_and_neq = ->
  a = 0

  while a isnt 1 and a isnt 1
    return true
  false
for_and_less = ->
  a = 0

  while a < 1 and a < 1
    return true
  false
for_and_lesseq = ->
  a = 0

  while a <= 1 and a <= 1
    return true
  false
dowhile_or_eq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless a is 0 or a is 0
  false
dowhile_or_neq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless a isnt 1 or a isnt 1
  false
dowhile_or_less = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless a < 1 or a < 1
  false
dowhile_or_lesseq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless a <= 1 or a <= 1
  false
dowhile_and_eq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless a is 0 and a is 0
  false
dowhile_and_neq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless a isnt 1 and a isnt 1
  false
dowhile_and_less = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless a < 1 and a < 1
  false
dowhile_and_lesseq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless a <= 1 and a <= 1
  false
while_not_or_eq = ->
  a = 0
  return true  until (a is 0 or a is 0)
  false
while_not_or_neq = ->
  a = 0
  return true  until (a isnt 1 or a isnt 1)
  false
while_not_or_less = ->
  a = 0
  return true  until (a < 1 or a < 1)
  false
while_not_or_lesseq = ->
  a = 0
  return true  until (a <= 1 or a <= 1)
  false
while_not_and_eq = ->
  a = 0
  return true  until (a is 0 and a is 0)
  false
while_not_and_neq = ->
  a = 0
  return true  until (a isnt 1 and a isnt 1)
  false
while_not_and_less = ->
  a = 0
  return true  until (a < 1 and a < 1)
  false
while_not_and_lesseq = ->
  a = 0
  return true  until (a <= 1 and a <= 1)
  false
for_not_or_eq = ->
  a = 0

  while not (a is 0 or a is 0)
    return true
  false
for_not_or_neq = ->
  a = 0

  while not (a isnt 1 or a isnt 1)
    return true
  false
for_not_or_less = ->
  a = 0

  while not (a < 1 or a < 1)
    return true
  false
for_not_or_lesseq = ->
  a = 0

  while not (a <= 1 or a <= 1)
    return true
  false
for_not_and_eq = ->
  a = 0

  while not (a is 0 and a is 0)
    return true
  false
for_not_and_neq = ->
  a = 0

  while not (a isnt 1 and a isnt 1)
    return true
  false
for_not_and_less = ->
  a = 0

  while not (a < 1 and a < 1)
    return true
  false
for_not_and_lesseq = ->
  a = 0

  while not (a <= 1 and a <= 1)
    return true
  false
dowhile_not_or_eq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless not (a is 0 or a is 0)
  false
dowhile_not_or_neq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless not (a isnt 1 or a isnt 1)
  false
dowhile_not_or_less = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless not (a < 1 or a < 1)
  false
dowhile_not_or_lesseq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless not (a <= 1 or a <= 1)
  false
dowhile_not_and_eq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless not (a is 0 and a is 0)
  false
dowhile_not_and_neq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless not (a isnt 1 and a isnt 1)
  false
dowhile_not_and_less = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless not (a < 1 and a < 1)
  false
dowhile_not_and_lesseq = ->
  a = 0
  i = 0
  loop
    return true  if i > 0
    i++
    break unless not (a <= 1 and a <= 1)
  false
float_while_or_eq = ->
  a = 0.1
  return true  while a is 0.1 or a is 0.1
  false
float_while_or_neq = ->
  a = 0.1
  return true  while a isnt 1.1 or a isnt 1.1
  false
float_while_or_less = ->
  a = 0.1
  return true  while a < 1.1 or a < 1.1
  false
float_while_or_lesseq = ->
  a = 0.1
  return true  while a <= 1.1 or a <= 1.1
  false
float_while_and_eq = ->
  a = 0.1
  return true  while a is 0.1 and a is 0.1
  false
float_while_and_neq = ->
  a = 0.1
  return true  while a isnt 1.1 and a isnt 1.1
  false
float_while_and_less = ->
  a = 0.1
  return true  while a < 1.1 and a < 1.1
  false
float_while_and_lesseq = ->
  a = 0.1
  return true  while a <= 1.1 and a <= 1.1
  false
float_for_or_eq = ->
  a = 0.1

  while a is 0.1 or a is 0.1
    return true
  false
float_for_or_neq = ->
  a = 0.1

  while a isnt 1.1 or a isnt 1.1
    return true
  false
float_for_or_less = ->
  a = 0.1

  while a < 1.1 or a < 1.1
    return true
  false
float_for_or_lesseq = ->
  a = 0.1

  while a <= 1.1 or a <= 1.1
    return true
  false
float_for_and_eq = ->
  a = 0.1

  while a is 0.1 and a is 0.1
    return true
  false
float_for_and_neq = ->
  a = 0.1

  while a isnt 1.1 and a isnt 1.1
    return true
  false
float_for_and_less = ->
  a = 0.1

  while a < 1.1 and a < 1.1
    return true
  false
float_for_and_lesseq = ->
  a = 0.1

  while a <= 1.1 and a <= 1.1
    return true
  false
float_dowhile_or_eq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless a is 0.1 or a is 0.1
  false
float_dowhile_or_neq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless a isnt 1.1 or a isnt 1.1
  false
float_dowhile_or_less = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless a < 1.1 or a < 1.1
  false
float_dowhile_or_lesseq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless a <= 1.1 or a <= 1.1
  false
float_dowhile_and_eq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless a is 0.1 and a is 0.1
  false
float_dowhile_and_neq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless a isnt 1.1 and a isnt 1.1
  false
float_dowhile_and_less = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless a < 1.1 and a < 1.1
  false
float_dowhile_and_lesseq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless a <= 1.1 and a <= 1.1
  false
float_while_not_or_eq = ->
  a = 0.1
  return true  until (a is 0.1 or a is 0.1)
  false
float_while_not_or_neq = ->
  a = 0.1
  return true  until (a isnt 1.1 or a isnt 1.1)
  false
float_while_not_or_less = ->
  a = 0.1
  return true  until (a < 1.1 or a < 1.1)
  false
float_while_not_or_lesseq = ->
  a = 0.1
  return true  until (a <= 1.1 or a <= 1.1)
  false
float_while_not_and_eq = ->
  a = 0.1
  return true  until (a is 0.1 and a is 0.1)
  false
float_while_not_and_neq = ->
  a = 0.1
  return true  until (a isnt 1.1 and a isnt 1.1)
  false
float_while_not_and_less = ->
  a = 0.1
  return true  until (a < 1.1 and a < 1.1)
  false
float_while_not_and_lesseq = ->
  a = 0.1
  return true  until (a <= 1.1 and a <= 1.1)
  false
float_for_not_or_eq = ->
  a = 0.1

  while not (a is 0.1 or a is 0.1)
    return true
  false
float_for_not_or_neq = ->
  a = 0.1

  while not (a isnt 1.1 or a isnt 1.1)
    return true
  false
float_for_not_or_less = ->
  a = 0.1

  while not (a < 1.1 or a < 1.1)
    return true
  false
float_for_not_or_lesseq = ->
  a = 0.1

  while not (a <= 1.1 or a <= 1.1)
    return true
  false
float_for_not_and_eq = ->
  a = 0.1

  while not (a is 0.1 and a is 0.1)
    return true
  false
float_for_not_and_neq = ->
  a = 0.1

  while not (a isnt 1.1 and a isnt 1.1)
    return true
  false
float_for_not_and_less = ->
  a = 0.1

  while not (a < 1.1 and a < 1.1)
    return true
  false
float_for_not_and_lesseq = ->
  a = 0.1

  while not (a <= 1.1 and a <= 1.1)
    return true
  false
float_dowhile_not_or_eq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless not (a is 0.1 or a is 0.1)
  false
float_dowhile_not_or_neq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless not (a isnt 1.1 or a isnt 1.1)
  false
float_dowhile_not_or_less = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless not (a < 1.1 or a < 1.1)
  false
float_dowhile_not_or_lesseq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless not (a <= 1.1 or a <= 1.1)
  false
float_dowhile_not_and_eq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless not (a is 0.1 and a is 0.1)
  false
float_dowhile_not_and_neq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless not (a isnt 1.1 and a isnt 1.1)
  false
float_dowhile_not_and_less = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless not (a < 1.1 and a < 1.1)
  false
float_dowhile_not_and_lesseq = ->
  a = 0.1
  i = 0.1
  loop
    return true  if i > 0.1
    i++
    break unless not (a <= 1.1 and a <= 1.1)
  false
description "Tests loop codegen when the condition is a logical node."
shouldBeTrue "while_or_eq()"
shouldBeTrue "while_or_neq()"
shouldBeTrue "while_or_less()"
shouldBeTrue "while_or_lesseq()"
shouldBeTrue "while_and_eq()"
shouldBeTrue "while_and_neq()"
shouldBeTrue "while_and_less()"
shouldBeTrue "while_and_lesseq()"
shouldBeTrue "for_or_eq()"
shouldBeTrue "for_or_neq()"
shouldBeTrue "for_or_less()"
shouldBeTrue "for_or_lesseq()"
shouldBeTrue "for_and_eq()"
shouldBeTrue "for_and_neq()"
shouldBeTrue "for_and_less()"
shouldBeTrue "for_and_lesseq()"
shouldBeTrue "dowhile_or_eq()"
shouldBeTrue "dowhile_or_neq()"
shouldBeTrue "dowhile_or_less()"
shouldBeTrue "dowhile_or_lesseq()"
shouldBeTrue "dowhile_and_eq()"
shouldBeTrue "dowhile_and_neq()"
shouldBeTrue "dowhile_and_less()"
shouldBeTrue "dowhile_and_lesseq()"
shouldBeFalse "while_not_or_eq()"
shouldBeFalse "while_not_or_neq()"
shouldBeFalse "while_not_or_less()"
shouldBeFalse "while_not_or_lesseq()"
shouldBeFalse "while_not_and_eq()"
shouldBeFalse "while_not_and_neq()"
shouldBeFalse "while_not_and_less()"
shouldBeFalse "while_not_and_lesseq()"
shouldBeFalse "for_not_or_eq()"
shouldBeFalse "for_not_or_neq()"
shouldBeFalse "for_not_or_less()"
shouldBeFalse "for_not_or_lesseq()"
shouldBeFalse "for_not_and_eq()"
shouldBeFalse "for_not_and_neq()"
shouldBeFalse "for_not_and_less()"
shouldBeFalse "for_not_and_lesseq()"
shouldBeFalse "dowhile_not_or_eq()"
shouldBeFalse "dowhile_not_or_neq()"
shouldBeFalse "dowhile_not_or_less()"
shouldBeFalse "dowhile_not_or_lesseq()"
shouldBeFalse "dowhile_not_and_eq()"
shouldBeFalse "dowhile_not_and_neq()"
shouldBeFalse "dowhile_not_and_less()"
shouldBeFalse "dowhile_not_and_lesseq()"
shouldBeTrue "float_while_or_eq()"
shouldBeTrue "float_while_or_neq()"
shouldBeTrue "float_while_or_less()"
shouldBeTrue "float_while_or_lesseq()"
shouldBeTrue "float_while_and_eq()"
shouldBeTrue "float_while_and_neq()"
shouldBeTrue "float_while_and_less()"
shouldBeTrue "float_while_and_lesseq()"
shouldBeTrue "float_for_or_eq()"
shouldBeTrue "float_for_or_neq()"
shouldBeTrue "float_for_or_less()"
shouldBeTrue "float_for_or_lesseq()"
shouldBeTrue "float_for_and_eq()"
shouldBeTrue "float_for_and_neq()"
shouldBeTrue "float_for_and_less()"
shouldBeTrue "float_for_and_lesseq()"
shouldBeTrue "float_dowhile_or_eq()"
shouldBeTrue "float_dowhile_or_neq()"
shouldBeTrue "float_dowhile_or_less()"
shouldBeTrue "float_dowhile_or_lesseq()"
shouldBeTrue "float_dowhile_and_eq()"
shouldBeTrue "float_dowhile_and_neq()"
shouldBeTrue "float_dowhile_and_less()"
shouldBeTrue "float_dowhile_and_lesseq()"
shouldBeFalse "float_while_not_or_eq()"
shouldBeFalse "float_while_not_or_neq()"
shouldBeFalse "float_while_not_or_less()"
shouldBeFalse "float_while_not_or_lesseq()"
shouldBeFalse "float_while_not_and_eq()"
shouldBeFalse "float_while_not_and_neq()"
shouldBeFalse "float_while_not_and_less()"
shouldBeFalse "float_while_not_and_lesseq()"
shouldBeFalse "float_for_not_or_eq()"
shouldBeFalse "float_for_not_or_neq()"
shouldBeFalse "float_for_not_or_less()"
shouldBeFalse "float_for_not_or_lesseq()"
shouldBeFalse "float_for_not_and_eq()"
shouldBeFalse "float_for_not_and_neq()"
shouldBeFalse "float_for_not_and_less()"
shouldBeFalse "float_for_not_and_lesseq()"
shouldBeFalse "float_dowhile_not_or_eq()"
shouldBeFalse "float_dowhile_not_or_neq()"
shouldBeFalse "float_dowhile_not_or_less()"
shouldBeFalse "float_dowhile_not_or_lesseq()"
shouldBeFalse "float_dowhile_not_and_eq()"
shouldBeFalse "float_dowhile_not_and_neq()"
shouldBeFalse "float_dowhile_not_and_less()"
