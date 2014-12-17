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
description "Tests for the parseFloat function."
nonASCIINonSpaceCharacter = String.fromCharCode(0x13a0)
illegalUTF16Sequence = String.fromCharCode(0xd800)
tab = String.fromCharCode(9)
nbsp = String.fromCharCode(0xa0)
ff = String.fromCharCode(0xc)
vt = String.fromCharCode(0xb)
cr = String.fromCharCode(0xd)
lf = String.fromCharCode(0xa)
ls = String.fromCharCode(0x2028)
ps = String.fromCharCode(0x2029)
oghamSpaceMark = String.fromCharCode(0x1680)
mongolianVowelSeparator = String.fromCharCode(0x180e)
enQuad = String.fromCharCode(0x2000)
emQuad = String.fromCharCode(0x2001)
enSpace = String.fromCharCode(0x2002)
emSpace = String.fromCharCode(0x2003)
threePerEmSpace = String.fromCharCode(0x2004)
fourPerEmSpace = String.fromCharCode(0x2005)
sixPerEmSpace = String.fromCharCode(0x2006)
figureSpace = String.fromCharCode(0x2007)
punctuationSpace = String.fromCharCode(0x2008)
thinSpace = String.fromCharCode(0x2009)
hairSpace = String.fromCharCode(0x200a)
narrowNoBreakSpace = String.fromCharCode(0x202f)
mediumMathematicalSpace = String.fromCharCode(0x205f)
ideographicSpace = String.fromCharCode(0x3000)
shouldBe "parseFloat()", "NaN"
shouldBe "parseFloat('')", "NaN"
shouldBe "parseFloat(' ')", "NaN"
shouldBe "parseFloat(' 0')", "0"
shouldBe "parseFloat('0 ')", "0"
shouldBe "parseFloat('x0')", "NaN"
shouldBe "parseFloat('0x')", "0"
shouldBe "parseFloat(' 1')", "1"
shouldBe "parseFloat('1 ')", "1"
shouldBe "parseFloat('x1')", "NaN"
shouldBe "parseFloat('1x')", "1"
shouldBe "parseFloat(' 2.3')", "2.3"
shouldBe "parseFloat('2.3 ')", "2.3"
shouldBe "parseFloat('x2.3')", "NaN"
shouldBe "parseFloat('2.3x')", "2.3"
shouldBe "parseFloat('0x2')", "0"
shouldBe "parseFloat('1' + nonASCIINonSpaceCharacter)", "1"
shouldBe "parseFloat(nonASCIINonSpaceCharacter + '1')", "NaN"
shouldBe "parseFloat('1' + illegalUTF16Sequence)", "1"
shouldBe "parseFloat(illegalUTF16Sequence + '1')", "NaN"
shouldBe "parseFloat(tab + '1')", "1"
shouldBe "parseFloat(nbsp + '1')", "1"
shouldBe "parseFloat(ff + '1')", "1"
shouldBe "parseFloat(vt + '1')", "1"
shouldBe "parseFloat(cr + '1')", "1"
shouldBe "parseFloat(lf + '1')", "1"
shouldBe "parseFloat(ls + '1')", "1"
shouldBe "parseFloat(ps + '1')", "1"
shouldBe "parseFloat(oghamSpaceMark + '1')", "1"
shouldBe "parseFloat(mongolianVowelSeparator + '1')", "1"
shouldBe "parseFloat(enQuad + '1')", "1"
shouldBe "parseFloat(emQuad + '1')", "1"
shouldBe "parseFloat(enSpace + '1')", "1"
shouldBe "parseFloat(emSpace + '1')", "1"
shouldBe "parseFloat(threePerEmSpace + '1')", "1"
shouldBe "parseFloat(fourPerEmSpace + '1')", "1"
shouldBe "parseFloat(sixPerEmSpace + '1')", "1"
shouldBe "parseFloat(figureSpace + '1')", "1"
shouldBe "parseFloat(punctuationSpace + '1')", "1"
shouldBe "parseFloat(thinSpace + '1')", "1"
shouldBe "parseFloat(hairSpace + '1')", "1"
shouldBe "parseFloat(narrowNoBreakSpace + '1')", "1"
shouldBe "parseFloat(mediumMathematicalSpace + '1')", "1"
shouldBe "parseFloat(ideographicSpace + '1')", "1"
