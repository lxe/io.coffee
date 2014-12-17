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
description "This test checks String.trim(), String.trimLeft() and String.trimRight() methods."

#references to trim(), trimLeft() and trimRight() functions for testing Function's *.call() and *.apply() methods
trim = String::trim
trimLeft = String::trimLeft
trimRight = String::trimRight
testString = "foo bar"
trimString = ""
leftTrimString = ""
rightTrimString = ""
wsString = ""
whitespace = [
  {
    s: "\t"
    t: "HORIZONTAL TAB"
  }
  {
    s: "\n"
    t: "LINE FEED OR NEW LINE"
  }
  {
    s: "\u000b"
    t: "VERTICAL TAB"
  }
  {
    s: "\f"
    t: "FORMFEED"
  }
  {
    s: "\r"
    t: "CARRIAGE RETURN"
  }
  {
    s: " "
    t: "SPACE"
  }
  {
    s: " "
    t: "NO-BREAK SPACE"
  }
  {
    s: " "
    t: "EN QUAD"
  }
  {
    s: " "
    t: "EM QUAD"
  }
  {
    s: " "
    t: "EN SPACE"
  }
  {
    s: " "
    t: "EM SPACE"
  }
  {
    s: " "
    t: "THREE-PER-EM SPACE"
  }
  {
    s: " "
    t: "FOUR-PER-EM SPACE"
  }
  {
    s: " "
    t: "SIX-PER-EM SPACE"
  }
  {
    s: " "
    t: "FIGURE SPACE"
  }
  {
    s: " "
    t: "PUNCTUATION SPACE"
  }
  {
    s: " "
    t: "THIN SPACE"
  }
  {
    s: " "
    t: "HAIR SPACE"
  }
  {
    s: "　"
    t: "IDEOGRAPHIC SPACE"
  }
  {
    s: " "
    t: "LINE SEPARATOR"
  }
  {
    s: " "
    t: "PARAGRAPH SEPARATOR"
  }
  {
    s: "​"
    t: "ZERO WIDTH SPACE (category Cf)"
  }
]
i = 0

while i < whitespace.length
  shouldBe "whitespace[" + i + "].s.trim()", "''"
  shouldBe "whitespace[" + i + "].s.trimLeft()", "''"
  shouldBe "whitespace[" + i + "].s.trimRight()", "''"
  wsString += whitespace[i].s
  i++
trimString = wsString + testString + wsString
leftTrimString = testString + wsString #trimmed from the left
rightTrimString = wsString + testString #trimmed from the right
shouldBe "wsString.trim()", "''"
shouldBe "wsString.trimLeft()", "''"
shouldBe "wsString.trimRight()", "''"
shouldBe "trimString.trim()", "testString"
shouldBe "trimString.trimLeft()", "leftTrimString"
shouldBe "trimString.trimRight()", "rightTrimString"
shouldBe "leftTrimString.trim()", "testString"
shouldBe "leftTrimString.trimLeft()", "leftTrimString"
shouldBe "leftTrimString.trimRight()", "testString"
shouldBe "rightTrimString.trim()", "testString"
shouldBe "rightTrimString.trimLeft()", "testString"
shouldBe "rightTrimString.trimRight()", "rightTrimString"
testValues = [
  "0"
  "Infinity"
  "NaN"
  "true"
  "false"
  "({})"
  "({toString:function(){return 'wibble'}})"
  "['an','array']"
]
i = 0

while i < testValues.length
  shouldBe "trim.call(" + testValues[i] + ")", "'" + eval(testValues[i]) + "'"
  shouldBe "trimLeft.call(" + testValues[i] + ")", "'" + eval(testValues[i]) + "'"
  shouldBe "trimRight.call(" + testValues[i] + ")", "'" + eval(testValues[i]) + "'"
  i++
