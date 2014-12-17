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

# Simple case, has no canonical equivalents

# Test the sets of USC2 code points that have more than one canonically equivalent value.
ucs2CodePoint = (x) ->
  s = x.toString(16)
  s = 0 + s  while s.length < 4
  eval "\"\\u" + s + "\""
testSet = (set) ->
  for i of set
    for j of set
      shouldBeTrue "/" + ucs2CodePoint(set[i]) + "/i.test(\"" + ucs2CodePoint(set[j]) + "\")"
      shouldBeTrue "/[" + ucs2CodePoint(set[i] - 1) + "-" + ucs2CodePoint(set[i] + 1) + "]/i.test(\"" + ucs2CodePoint(set[j]) + "\")"
  return
description "https://bugs.webkit.org/show_bug.cgi?id=82063"
shouldBeTrue "/ΣΤΙΓΜΑΣ/i.test(\"στιγμας\")"
shouldBeTrue "/ΔΣΔ/i.test(\"δςδ\")"
shouldBeTrue "/ς/i.test(\"σ\")"
shouldBeTrue "/σ/i.test(\"ς\")"
shouldBeTrue "/἖/i.test(\"἖\")"
testSet [
  0x01c4
  0x01c5
  0x01c6
]
testSet [
  0x01c7
  0x01c8
  0x01c9
]
testSet [
  0x01ca
  0x01cb
  0x01cc
]
testSet [
  0x01f1
  0x01f2
  0x01f3
]
testSet [
  0x0392
  0x03b2
  0x03d0
]
testSet [
  0x0395
  0x03b5
  0x03f5
]
testSet [
  0x0398
  0x03b8
  0x03d1
]
testSet [
  0x0345
  0x0399
  0x03b9
  0x1fbe
]
testSet [
  0x039a
  0x03ba
  0x03f0
]
testSet [
  0x00b5
  0x039c
  0x03bc
]
testSet [
  0x03a0
  0x03c0
  0x03d6
]
testSet [
  0x03a1
  0x03c1
  0x03f1
]
testSet [
  0x03a3
  0x03c2
  0x03c3
]
testSet [
  0x03a6
  0x03c6
  0x03d5
]
testSet [
  0x1e60
  0x1e61
  0x1e9b
]

# Test a couple of lo/hi pairs
shouldBeTrue "/Ϗ/i.test(\"Ϗ\")"
shouldBeTrue "/ϗ/i.test(\"Ϗ\")"
shouldBeTrue "/Ϗ/i.test(\"ϗ\")"
shouldBeTrue "/ϗ/i.test(\"ϗ\")"
shouldBeTrue "/ἑ/i.test(\"ἑ\")"
shouldBeTrue "/Ἑ/i.test(\"ἑ\")"
shouldBeTrue "/ἑ/i.test(\"Ἑ\")"
shouldBeTrue "/Ἑ/i.test(\"Ἑ\")"

# Test an aligned alternating capitalization pair.
shouldBeFalse "/҉/i.test(\"Ҋ\")"
shouldBeTrue "/Ҋ/i.test(\"Ҋ\")"
shouldBeTrue "/ҋ/i.test(\"Ҋ\")"
shouldBeFalse "/Ҍ/i.test(\"Ҋ\")"
shouldBeFalse "/҉/i.test(\"ҋ\")"
shouldBeTrue "/Ҋ/i.test(\"ҋ\")"
shouldBeTrue "/ҋ/i.test(\"ҋ\")"
shouldBeFalse "/Ҍ/i.test(\"ҋ\")"
shouldBeTrue "/[҉-Ҋ]/i.test(\"ҋ\")"
shouldBeTrue "/[ҋ-Ҍ]/i.test(\"Ҋ\")"

# Test an unaligned alternating capitalization pair.
shouldBeFalse "/ӄ/i.test(\"Ӆ\")"
shouldBeTrue "/Ӆ/i.test(\"Ӆ\")"
shouldBeTrue "/ӆ/i.test(\"Ӆ\")"
shouldBeFalse "/Ӈ/i.test(\"Ӆ\")"
shouldBeFalse "/ӄ/i.test(\"ӆ\")"
shouldBeTrue "/Ӆ/i.test(\"ӆ\")"
shouldBeTrue "/ӆ/i.test(\"ӆ\")"
shouldBeFalse "/Ӈ/i.test(\"ӆ\")"
shouldBeTrue "/[ӄ-Ӆ]/i.test(\"ӆ\")"
shouldBeTrue "/[ӆ-Ӈ]/i.test(\"Ӆ\")"
successfullyParsed = true
