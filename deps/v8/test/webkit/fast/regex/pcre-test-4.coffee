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
description "A chunk of our port of PCRE's test suite, adapted to be more applicable to JavaScript."
regex0 = /a.b/
input0 = "acb"
results = ["acb"]
shouldBe "regex0.exec(input0);", "results"
input1 = "ab"
results = ["ab"]
shouldBe "regex0.exec(input1);", "results"
input2 = "aĀb"
results = ["aĀb"]
shouldBe "regex0.exec(input2);", "results"

# Failers
input3 = "a\nb"
results = null
shouldBe "regex0.exec(input3);", "results"
regex1 = /a(.{3})b/
input0 = "a䀀xyb"
results = [
  "a䀀xyb"
  "䀀xy"
]
shouldBe "regex1.exec(input0);", "results"
input1 = "a䀀yb"
results = [
  "a䀀yb"
  "䀀y"
]
shouldBe "regex1.exec(input1);", "results"
input2 = "a䀀Āyb"
results = [
  "a䀀Āyb"
  "䀀Āy"
]
shouldBe "regex1.exec(input2);", "results"

# Failers
input3 = "a䀀b"
results = null
shouldBe "regex1.exec(input3);", "results"
input4 = "ac\ncb"
results = null
shouldBe "regex1.exec(input4);", "results"
regex2 = /a(.*?)(.)/
input0 = "aÀb"
results = [
  "aÀ"
  ""
  "À"
]
shouldBe "regex2.exec(input0);", "results"
regex3 = /a(.*?)(.)/
input0 = "aĀb"
results = [
  "aĀ"
  ""
  "Ā"
]
shouldBe "regex3.exec(input0);", "results"
regex4 = /a(.*)(.)/
input0 = "aÀb"
results = [
  "aÀb"
  "À"
  "b"
]
shouldBe "regex4.exec(input0);", "results"
regex5 = /a(.*)(.)/
input0 = "aĀb"
results = [
  "aĀb"
  "Ā"
  "b"
]
shouldBe "regex5.exec(input0);", "results"
regex6 = /a(.)(.)/
input0 = "aÀbcd"
results = [
  "aÀ"
  "À"
  ""
]
shouldBe "regex6.exec(input0);", "results"
regex7 = /a(.)(.)/
input0 = "aɀbcd"
results = [
  "aɀb"
  "ɀ"
  "b"
]
shouldBe "regex7.exec(input0);", "results"
regex8 = /a(.?)(.)/
input0 = "aÀbcd"
results = [
  "aÀ"
  "À"
  ""
]
shouldBe "regex8.exec(input0);", "results"
regex9 = /a(.?)(.)/
input0 = "aɀbcd"
results = [
  "aɀb"
  "ɀ"
  "b"
]
shouldBe "regex9.exec(input0);", "results"
regex10 = /a(.??)(.)/
input0 = "aÀbcd"
results = [
  "aÀ"
  ""
  "À"
]
shouldBe "regex10.exec(input0);", "results"
regex11 = /a(.??)(.)/
input0 = "aɀbcd"
results = [
  "aɀ"
  ""
  "ɀ"
]
shouldBe "regex11.exec(input0);", "results"
regex12 = /a(.{3})b/
input0 = "aሴxyb"
results = [
  "aሴxyb"
  "ሴxy"
]
shouldBe "regex12.exec(input0);", "results"
input1 = "aሴ䌡yb"
results = [
  "aሴ䌡yb"
  "ሴ䌡y"
]
shouldBe "regex12.exec(input1);", "results"
input2 = "aሴ䌡㐒b"
results = [
  "aሴ䌡㐒b"
  "ሴ䌡㐒"
]
shouldBe "regex12.exec(input2);", "results"

# Failers
input3 = "aሴb"
results = null
shouldBe "regex12.exec(input3);", "results"
input4 = "ac\ncb"
results = null
shouldBe "regex12.exec(input4);", "results"
regex13 = /a(.{3,})b/
input0 = "aሴxyb"
results = [
  "aሴxyb"
  "ሴxy"
]
shouldBe "regex13.exec(input0);", "results"
input1 = "aሴ䌡yb"
results = [
  "aሴ䌡yb"
  "ሴ䌡y"
]
shouldBe "regex13.exec(input1);", "results"
input2 = "aሴ䌡㐒b"
results = [
  "aሴ䌡㐒b"
  "ሴ䌡㐒"
]
shouldBe "regex13.exec(input2);", "results"
input3 = "axxxxbcdefghijb"
results = [
  "axxxxbcdefghijb"
  "xxxxbcdefghij"
]
shouldBe "regex13.exec(input3);", "results"
input4 = "aሴ䌡㐒㐡b"
results = [
  "aሴ䌡㐒㐡b"
  "ሴ䌡㐒㐡"
]
shouldBe "regex13.exec(input4);", "results"

# Failers
input5 = "aሴb"
results = null
shouldBe "regex13.exec(input5);", "results"
regex14 = /a(.{3,}?)b/
input0 = "aሴxyb"
results = [
  "aሴxyb"
  "ሴxy"
]
shouldBe "regex14.exec(input0);", "results"
input1 = "aሴ䌡yb"
results = [
  "aሴ䌡yb"
  "ሴ䌡y"
]
shouldBe "regex14.exec(input1);", "results"
input2 = "aሴ䌡㐒b"
results = [
  "aሴ䌡㐒b"
  "ሴ䌡㐒"
]
shouldBe "regex14.exec(input2);", "results"
input3 = "axxxxbcdefghijb"
results = [
  "axxxxb"
  "xxxx"
]
shouldBe "regex14.exec(input3);", "results"
input4 = "aሴ䌡㐒㐡b"
results = [
  "aሴ䌡㐒㐡b"
  "ሴ䌡㐒㐡"
]
shouldBe "regex14.exec(input4);", "results"

# Failers
input5 = "aሴb"
results = null
shouldBe "regex14.exec(input5);", "results"
regex15 = /a(.{3,5})b/
input0 = "aሴxyb"
results = [
  "aሴxyb"
  "ሴxy"
]
shouldBe "regex15.exec(input0);", "results"
input1 = "aሴ䌡yb"
results = [
  "aሴ䌡yb"
  "ሴ䌡y"
]
shouldBe "regex15.exec(input1);", "results"
input2 = "aሴ䌡㐒b"
results = [
  "aሴ䌡㐒b"
  "ሴ䌡㐒"
]
shouldBe "regex15.exec(input2);", "results"
input3 = "axxxxbcdefghijb"
results = [
  "axxxxb"
  "xxxx"
]
shouldBe "regex15.exec(input3);", "results"
input4 = "aሴ䌡㐒㐡b"
results = [
  "aሴ䌡㐒㐡b"
  "ሴ䌡㐒㐡"
]
shouldBe "regex15.exec(input4);", "results"
input5 = "axbxxbcdefghijb"
results = [
  "axbxxb"
  "xbxx"
]
shouldBe "regex15.exec(input5);", "results"
input6 = "axxxxxbcdefghijb"
results = [
  "axxxxxb"
  "xxxxx"
]
shouldBe "regex15.exec(input6);", "results"

# Failers
input7 = "aሴb"
results = null
shouldBe "regex15.exec(input7);", "results"
input8 = "axxxxxxbcdefghijb"
results = null
shouldBe "regex15.exec(input8);", "results"
regex16 = /a(.{3,5}?)b/
input0 = "aሴxyb"
results = [
  "aሴxyb"
  "ሴxy"
]
shouldBe "regex16.exec(input0);", "results"
input1 = "aሴ䌡yb"
results = [
  "aሴ䌡yb"
  "ሴ䌡y"
]
shouldBe "regex16.exec(input1);", "results"
input2 = "aሴ䌡㐒b"
results = [
  "aሴ䌡㐒b"
  "ሴ䌡㐒"
]
shouldBe "regex16.exec(input2);", "results"
input3 = "axxxxbcdefghijb"
results = [
  "axxxxb"
  "xxxx"
]
shouldBe "regex16.exec(input3);", "results"
input4 = "aሴ䌡㐒㐡b"
results = [
  "aሴ䌡㐒㐡b"
  "ሴ䌡㐒㐡"
]
shouldBe "regex16.exec(input4);", "results"
input5 = "axbxxbcdefghijb"
results = [
  "axbxxb"
  "xbxx"
]
shouldBe "regex16.exec(input5);", "results"
input6 = "axxxxxbcdefghijb"
results = [
  "axxxxxb"
  "xxxxx"
]
shouldBe "regex16.exec(input6);", "results"

# Failers
input7 = "aሴb"
results = null
shouldBe "regex16.exec(input7);", "results"
input8 = "axxxxxxbcdefghijb"
results = null
shouldBe "regex16.exec(input8);", "results"
regex17 = /^[a\u00c0]/

# Failers
input0 = "Ā"
results = null
shouldBe "regex17.exec(input0);", "results"
regex21 = /(?:\u0100){3}b/
input0 = "ĀĀĀb"
results = ["ĀĀĀb"]
shouldBe "regex21.exec(input0);", "results"

# Failers
input1 = "ĀĀb"
results = null
shouldBe "regex21.exec(input1);", "results"
regex22 = /\u00ab/
input0 = "«"
results = ["«"]
shouldBe "regex22.exec(input0);", "results"
input1 = "Â«"
results = ["«"]
shouldBe "regex22.exec(input1);", "results"

# Failers
input2 = "\u0000{ab}"
results = null
shouldBe "regex22.exec(input2);", "results"
regex30 = /^[^a]{2}/
input0 = "Ābc"
results = ["Āb"]
shouldBe "regex30.exec(input0);", "results"
regex31 = /^[^a]{2,}/
input0 = "ĀbcAa"
results = ["ĀbcA"]
shouldBe "regex31.exec(input0);", "results"
regex32 = /^[^a]{2,}?/
input0 = "Ābca"
results = ["Āb"]
shouldBe "regex32.exec(input0);", "results"
regex33 = /^[^a]{2}/i
input0 = "Ābc"
results = ["Āb"]
shouldBe "regex33.exec(input0);", "results"
regex34 = /^[^a]{2,}/i
input0 = "ĀbcAa"
results = ["Ābc"]
shouldBe "regex34.exec(input0);", "results"
regex35 = /^[^a]{2,}?/i
input0 = "Ābca"
results = ["Āb"]
shouldBe "regex35.exec(input0);", "results"
regex36 = /\u0100{0,0}/
input0 = "abcd"
results = [""]
shouldBe "regex36.exec(input0);", "results"
regex37 = /\u0100?/
input0 = "abcd"
results = [""]
shouldBe "regex37.exec(input0);", "results"
input1 = "ĀĀ"
results = ["Ā"]
shouldBe "regex37.exec(input1);", "results"
regex38 = /\u0100{0,3}/
input0 = "ĀĀ"
results = ["ĀĀ"]
shouldBe "regex38.exec(input0);", "results"
input1 = "ĀĀĀĀ"
results = ["ĀĀĀ"]
shouldBe "regex38.exec(input1);", "results"
regex39 = /\u0100*/
input0 = "abce"
results = [""]
shouldBe "regex39.exec(input0);", "results"
input1 = "ĀĀĀĀ"
results = ["ĀĀĀĀ"]
shouldBe "regex39.exec(input1);", "results"
regex40 = /\u0100{1,1}/
input0 = "abcdĀĀĀĀ"
results = ["Ā"]
shouldBe "regex40.exec(input0);", "results"
regex41 = /\u0100{1,3}/
input0 = "abcdĀĀĀĀ"
results = ["ĀĀĀ"]
shouldBe "regex41.exec(input0);", "results"
regex42 = /\u0100+/
input0 = "abcdĀĀĀĀ"
results = ["ĀĀĀĀ"]
shouldBe "regex42.exec(input0);", "results"
regex43 = /\u0100{3}/
input0 = "abcdĀĀĀXX"
results = ["ĀĀĀ"]
shouldBe "regex43.exec(input0);", "results"
regex44 = /\u0100{3,5}/
input0 = "abcdĀĀĀĀĀĀĀXX"
results = ["ĀĀĀĀĀ"]
shouldBe "regex44.exec(input0);", "results"
regex45 = /\u0100{3,}/
input0 = "abcdĀĀĀĀĀĀĀXX"
results = ["ĀĀĀĀĀĀĀ"]
shouldBe "regex45.exec(input0);", "results"
regex47 = /\D*/
input0 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
results = ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
shouldBe "regex47.exec(input0);", "results"
regex48 = /\D*/
input0 = "ĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀ"
results = ["ĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀĀ"]
shouldBe "regex48.exec(input0);", "results"
regex49 = /\D/
input0 = "1X2"
results = ["X"]
shouldBe "regex49.exec(input0);", "results"
input1 = "1Ā2"
results = ["Ā"]
shouldBe "regex49.exec(input1);", "results"
regex50 = />\S/
input0 = "> >X Y"
results = [">X"]
shouldBe "regex50.exec(input0);", "results"
input1 = "> >Ā Y"
results = [">Ā"]
shouldBe "regex50.exec(input1);", "results"
regex51 = /\d/
input0 = "Ā3"
results = ["3"]
shouldBe "regex51.exec(input0);", "results"
regex52 = /\s/
input0 = "Ā X"
results = [" "]
shouldBe "regex52.exec(input0);", "results"
regex53 = /\D+/
input0 = "12abcd34"
results = ["abcd"]
shouldBe "regex53.exec(input0);", "results"

# Failers
input1 = "1234"
results = null
shouldBe "regex53.exec(input1);", "results"
regex54 = /\D{2,3}/
input0 = "12abcd34"
results = ["abc"]
shouldBe "regex54.exec(input0);", "results"
input1 = "12ab34"
results = ["ab"]
shouldBe "regex54.exec(input1);", "results"

# Failers
input2 = "1234"
results = null
shouldBe "regex54.exec(input2);", "results"
input3 = "12a34"
results = null
shouldBe "regex54.exec(input3);", "results"
regex55 = /\D{2,3}?/
input0 = "12abcd34"
results = ["ab"]
shouldBe "regex55.exec(input0);", "results"
input1 = "12ab34"
results = ["ab"]
shouldBe "regex55.exec(input1);", "results"

# Failers
input2 = "1234"
results = null
shouldBe "regex55.exec(input2);", "results"
input3 = "12a34"
results = null
shouldBe "regex55.exec(input3);", "results"
regex56 = /\d+/
input0 = "12abcd34"
results = ["12"]
shouldBe "regex56.exec(input0);", "results"
regex57 = /\d{2,3}/
input0 = "12abcd34"
results = ["12"]
shouldBe "regex57.exec(input0);", "results"
input1 = "1234abcd"
results = ["123"]
shouldBe "regex57.exec(input1);", "results"

# Failers
input2 = "1.4"
results = null
shouldBe "regex57.exec(input2);", "results"
regex58 = /\d{2,3}?/
input0 = "12abcd34"
results = ["12"]
shouldBe "regex58.exec(input0);", "results"
input1 = "1234abcd"
results = ["12"]
shouldBe "regex58.exec(input1);", "results"

# Failers
input2 = "1.4"
results = null
shouldBe "regex58.exec(input2);", "results"
regex59 = /\S+/
input0 = "12abcd34"
results = ["12abcd34"]
shouldBe "regex59.exec(input0);", "results"

# Failers
input1 = "    "
results = null
shouldBe "regex59.exec(input1);", "results"
regex60 = /\S{2,3}/
input0 = "12abcd34"
results = ["12a"]
shouldBe "regex60.exec(input0);", "results"
input1 = "1234abcd"
results = ["123"]
shouldBe "regex60.exec(input1);", "results"

# Failers
input2 = "    "
results = null
shouldBe "regex60.exec(input2);", "results"
regex61 = /\S{2,3}?/
input0 = "12abcd34"
results = ["12"]
shouldBe "regex61.exec(input0);", "results"
input1 = "1234abcd"
results = ["12"]
shouldBe "regex61.exec(input1);", "results"

# Failers
input2 = "    "
results = null
shouldBe "regex61.exec(input2);", "results"
regex62 = />\s+</
input0 = "12>      <34"
results = [">      <"]
shouldBe "regex62.exec(input0);", "results"
regex63 = />\s{2,3}</
input0 = "ab>  <cd"
results = [">  <"]
shouldBe "regex63.exec(input0);", "results"
input1 = "ab>   <ce"
results = [">   <"]
shouldBe "regex63.exec(input1);", "results"

# Failers
input2 = "ab>    <cd"
results = null
shouldBe "regex63.exec(input2);", "results"
regex64 = />\s{2,3}?</
input0 = "ab>  <cd"
results = [">  <"]
shouldBe "regex64.exec(input0);", "results"
input1 = "ab>   <ce"
results = [">   <"]
shouldBe "regex64.exec(input1);", "results"

# Failers
input2 = "ab>    <cd"
results = null
shouldBe "regex64.exec(input2);", "results"
regex65 = /\w+/
input0 = "12      34"
results = ["12"]
shouldBe "regex65.exec(input0);", "results"

# Failers
input1 = "+++=*!"
results = null
shouldBe "regex65.exec(input1);", "results"
regex66 = /\w{2,3}/
input0 = "ab  cd"
results = ["ab"]
shouldBe "regex66.exec(input0);", "results"
input1 = "abcd ce"
results = ["abc"]
shouldBe "regex66.exec(input1);", "results"

# Failers
input2 = "a.b.c"
results = null
shouldBe "regex66.exec(input2);", "results"
regex67 = /\w{2,3}?/
input0 = "ab  cd"
results = ["ab"]
shouldBe "regex67.exec(input0);", "results"
input1 = "abcd ce"
results = ["ab"]
shouldBe "regex67.exec(input1);", "results"

# Failers
input2 = "a.b.c"
results = null
shouldBe "regex67.exec(input2);", "results"
regex68 = /\W+/
input0 = "12====34"
results = ["===="]
shouldBe "regex68.exec(input0);", "results"

# Failers
input1 = "abcd"
results = null
shouldBe "regex68.exec(input1);", "results"
regex69 = /\W{2,3}/
input0 = "ab====cd"
results = ["==="]
shouldBe "regex69.exec(input0);", "results"
input1 = "ab==cd"
results = ["=="]
shouldBe "regex69.exec(input1);", "results"

# Failers
input2 = "a.b.c"
results = null
shouldBe "regex69.exec(input2);", "results"
regex70 = /\W{2,3}?/
input0 = "ab====cd"
results = ["=="]
shouldBe "regex70.exec(input0);", "results"
input1 = "ab==cd"
results = ["=="]
shouldBe "regex70.exec(input1);", "results"

# Failers
input2 = "a.b.c"
results = null
shouldBe "regex70.exec(input2);", "results"
regex71 = /[\u0100]/
input0 = "Ā"
results = ["Ā"]
shouldBe "regex71.exec(input0);", "results"
input1 = "ZĀ"
results = ["Ā"]
shouldBe "regex71.exec(input1);", "results"
input2 = "ĀZ"
results = ["Ā"]
shouldBe "regex71.exec(input2);", "results"
regex72 = /[Z\u0100]/
input0 = "ZĀ"
results = ["Z"]
shouldBe "regex72.exec(input0);", "results"
input1 = "Ā"
results = ["Ā"]
shouldBe "regex72.exec(input1);", "results"
input2 = "ĀZ"
results = ["Ā"]
shouldBe "regex72.exec(input2);", "results"
regex73 = /[\u0100\u0200]/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex73.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex73.exec(input1);", "results"
regex74 = /[\u0100-\u0200]/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex74.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex74.exec(input1);", "results"
input2 = "abđcd"
results = ["đ"]
shouldBe "regex74.exec(input2);", "results"
regex75 = /[z-\u0200]/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex75.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex75.exec(input1);", "results"
input2 = "abđcd"
results = ["đ"]
shouldBe "regex75.exec(input2);", "results"
input3 = "abzcd"
results = ["z"]
shouldBe "regex75.exec(input3);", "results"
input4 = "ab|cd"
results = ["|"]
shouldBe "regex75.exec(input4);", "results"
regex76 = /[Q\u0100\u0200]/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex76.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex76.exec(input1);", "results"
input2 = "Q?"
results = ["Q"]
shouldBe "regex76.exec(input2);", "results"
regex77 = /[Q\u0100-\u0200]/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex77.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex77.exec(input1);", "results"
input2 = "abđcd"
results = ["đ"]
shouldBe "regex77.exec(input2);", "results"
input3 = "Q?"
results = ["Q"]
shouldBe "regex77.exec(input3);", "results"
regex78 = /[Qz-\u0200]/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex78.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex78.exec(input1);", "results"
input2 = "abđcd"
results = ["đ"]
shouldBe "regex78.exec(input2);", "results"
input3 = "abzcd"
results = ["z"]
shouldBe "regex78.exec(input3);", "results"
input4 = "ab|cd"
results = ["|"]
shouldBe "regex78.exec(input4);", "results"
input5 = "Q?"
results = ["Q"]
shouldBe "regex78.exec(input5);", "results"
regex79 = /[\u0100\u0200]{1,3}/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex79.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex79.exec(input1);", "results"
input2 = "abȀĀȀĀcd"
results = ["ȀĀȀ"]
shouldBe "regex79.exec(input2);", "results"
regex80 = /[\u0100\u0200]{1,3}?/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex80.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex80.exec(input1);", "results"
input2 = "abȀĀȀĀcd"
results = ["Ȁ"]
shouldBe "regex80.exec(input2);", "results"
regex81 = /[Q\u0100\u0200]{1,3}/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex81.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex81.exec(input1);", "results"
input2 = "abȀĀȀĀcd"
results = ["ȀĀȀ"]
shouldBe "regex81.exec(input2);", "results"
regex82 = /[Q\u0100\u0200]{1,3}?/
input0 = "abĀcd"
results = ["Ā"]
shouldBe "regex82.exec(input0);", "results"
input1 = "abȀcd"
results = ["Ȁ"]
shouldBe "regex82.exec(input1);", "results"
input2 = "abȀĀȀĀcd"
results = ["Ȁ"]
shouldBe "regex82.exec(input2);", "results"
regex86 = /[^\u0100\u0200]X/
input0 = "AX"
results = ["AX"]
shouldBe "regex86.exec(input0);", "results"
input1 = "ŐX"
results = ["ŐX"]
shouldBe "regex86.exec(input1);", "results"
input2 = "ԀX"
results = ["ԀX"]
shouldBe "regex86.exec(input2);", "results"

# Failers
input3 = "ĀX"
results = null
shouldBe "regex86.exec(input3);", "results"
input4 = "ȀX"
results = null
shouldBe "regex86.exec(input4);", "results"
regex87 = /[^Q\u0100\u0200]X/
input0 = "AX"
results = ["AX"]
shouldBe "regex87.exec(input0);", "results"
input1 = "ŐX"
results = ["ŐX"]
shouldBe "regex87.exec(input1);", "results"
input2 = "ԀX"
results = ["ԀX"]
shouldBe "regex87.exec(input2);", "results"

# Failers
input3 = "ĀX"
results = null
shouldBe "regex87.exec(input3);", "results"
input4 = "ȀX"
results = null
shouldBe "regex87.exec(input4);", "results"
input5 = "QX"
results = null
shouldBe "regex87.exec(input5);", "results"
regex88 = /[^\u0100-\u0200]X/
input0 = "AX"
results = ["AX"]
shouldBe "regex88.exec(input0);", "results"
input1 = "ԀX"
results = ["ԀX"]
shouldBe "regex88.exec(input1);", "results"

# Failers
input2 = "ĀX"
results = null
shouldBe "regex88.exec(input2);", "results"
input3 = "ŐX"
results = null
shouldBe "regex88.exec(input3);", "results"
input4 = "ȀX"
results = null
shouldBe "regex88.exec(input4);", "results"
regex91 = /[z-\u0100]/i
input0 = "z"
results = ["z"]
shouldBe "regex91.exec(input0);", "results"
input1 = "Z"
results = ["Z"]
shouldBe "regex91.exec(input1);", "results"
input2 = "Ā"
results = ["Ā"]
shouldBe "regex91.exec(input2);", "results"

# Failers
input3 = "Ă"
results = null
shouldBe "regex91.exec(input3);", "results"
input4 = "y"
results = null
shouldBe "regex91.exec(input4);", "results"
regex92 = /[\xFF]/
input0 = ">ÿ<"
results = ["ÿ"]
shouldBe "regex92.exec(input0);", "results"
regex93 = /[\xff]/
input0 = ">ÿ<"
results = ["ÿ"]
shouldBe "regex93.exec(input0);", "results"
regex94 = /[^\xFF]/
input0 = "XYZ"
results = ["X"]
shouldBe "regex94.exec(input0);", "results"
regex95 = /[^\xff]/
input0 = "XYZ"
results = ["X"]
shouldBe "regex95.exec(input0);", "results"
input1 = "ģ"
results = ["ģ"]
shouldBe "regex95.exec(input1);", "results"
regex96 = /^[ac]*b/
input0 = "xb"
results = null
shouldBe "regex96.exec(input0);", "results"
regex97 = /^[ac\u0100]*b/
input0 = "xb"
results = null
shouldBe "regex97.exec(input0);", "results"
regex98 = /^[^x]*b/i
input0 = "xb"
results = null
shouldBe "regex98.exec(input0);", "results"
regex99 = /^[^x]*b/
input0 = "xb"
results = null
shouldBe "regex99.exec(input0);", "results"
regex100 = /^\d*b/
input0 = "xb"
results = null
shouldBe "regex100.exec(input0);", "results"
regex102 = /^\u0085$/i
input0 = ""
results = [""]
shouldBe "regex102.exec(input0);", "results"
regex103 = /^\xe1\x88\xb4/
input0 = "á´"
results = ["á´"]
shouldBe "regex103.exec(input0);", "results"
regex104 = /^\xe1\x88\xb4/
input0 = "á´"
results = ["á´"]
shouldBe "regex104.exec(input0);", "results"
regex105 = /(.{1,5})/
input0 = "abcdefg"
results = [
  "abcde"
  "abcde"
]
shouldBe "regex105.exec(input0);", "results"
input1 = "ab"
results = [
  "ab"
  "ab"
]
shouldBe "regex105.exec(input1);", "results"
regex106 = /a*\u0100*\w/
input0 = "a"
results = ["a"]
shouldBe "regex106.exec(input0);", "results"
regex107 = /[\S\s]*/
input0 = "abc\n\rтестxyz"
results = ["abc\n\rтестxyz"]
shouldBe "regex107.exec(input0);", "results"
regexGlobal0 = /[^a]+/g
input0 = "bcd"
results = ["bcd"]
shouldBe "input0.match(regexGlobal0);", "results"
input1 = "ĀaYɖZ"
results = [
  "Ā"
  "YɖZ"
]
shouldBe "input1.match(regexGlobal0);", "results"
regexGlobal1 = /\S\S/g
input0 = "A£BC"
results = [
  "A£"
  "BC"
]
shouldBe "input0.match(regexGlobal1);", "results"
regexGlobal2 = /\S{2}/g
input0 = "A£BC"
results = [
  "A£"
  "BC"
]
shouldBe "input0.match(regexGlobal2);", "results"
regexGlobal3 = /\W\W/g
input0 = "+£=="
results = [
  "+£"
  "=="
]
shouldBe "input0.match(regexGlobal3);", "results"
regexGlobal4 = /\W{2}/g
input0 = "+£=="
results = [
  "+£"
  "=="
]
shouldBe "input0.match(regexGlobal4);", "results"
regexGlobal5 = /\S/g
input0 = "тест"
results = [
  "т"
  "е"
  "с"
  "т"
]
shouldBe "input0.match(regexGlobal5);", "results"
regexGlobal6 = /[\S]/g
input0 = "тест"
results = [
  "т"
  "е"
  "с"
  "т"
]
shouldBe "input0.match(regexGlobal6);", "results"
regexGlobal7 = /\D/g
input0 = "тест"
results = [
  "т"
  "е"
  "с"
  "т"
]
shouldBe "input0.match(regexGlobal7);", "results"
regexGlobal8 = /[\D]/g
input0 = "тест"
results = [
  "т"
  "е"
  "с"
  "т"
]
shouldBe "input0.match(regexGlobal8);", "results"
regexGlobal9 = /\W/g
input0 = "⑂␵⑁⑂"
results = [
  "⑂"
  "␵"
  "⑁"
  "⑂"
]
shouldBe "input0.match(regexGlobal9);", "results"
regexGlobal10 = /[\W]/g
input0 = "⑂␵⑁⑂"
results = [
  "⑂"
  "␵"
  "⑁"
  "⑂"
]
shouldBe "input0.match(regexGlobal10);", "results"
regexGlobal11 = /[\u041f\S]/g
input0 = "тест"
results = [
  "т"
  "е"
  "с"
  "т"
]
shouldBe "input0.match(regexGlobal11);", "results"
regexGlobal12 = /.[^\S]./g
input0 = "abc defтуxyz\npqr"
results = [
  "c d"
  "z\np"
]
shouldBe "input0.match(regexGlobal12);", "results"
regexGlobal13 = /.[^\S\n]./g
input0 = "abc defтуxyz\npqr"
results = ["c d"]
shouldBe "input0.match(regexGlobal13);", "results"
regexGlobal14 = /[\W]/g
input0 = "+⑂"
results = [
  "+"
  "⑂"
]
shouldBe "input0.match(regexGlobal14);", "results"
regexGlobal15 = /[^a-zA-Z]/g
input0 = "+⑂"
results = [
  "+"
  "⑂"
]
shouldBe "input0.match(regexGlobal15);", "results"
regexGlobal16 = /[^a-zA-Z]/g
input0 = "Aт"
results = ["т"]
shouldBe "input0.match(regexGlobal16);", "results"
regexGlobal17 = /[\S]/g
input0 = "Aт"
results = [
  "A"
  "т"
]
shouldBe "input0.match(regexGlobal17);", "results"
regexGlobal19 = /[\D]/g
input0 = "Aт"
results = [
  "A"
  "т"
]
shouldBe "input0.match(regexGlobal19);", "results"
regexGlobal21 = /[^a-z]/g
input0 = "AТ"
results = [
  "A"
  "Т"
]
shouldBe "input0.match(regexGlobal21);", "results"
regexGlobal24 = /[\S]/g
input0 = "Aт"
results = [
  "A"
  "т"
]
shouldBe "input0.match(regexGlobal24);", "results"
regexGlobal25 = /[^A-Z]/g
input0 = "aт"
results = [
  "a"
  "т"
]
shouldBe "input0.match(regexGlobal25);", "results"
regexGlobal26 = /[\W]/g
input0 = "+⑂"
results = [
  "+"
  "⑂"
]
shouldBe "input0.match(regexGlobal26);", "results"
regexGlobal27 = /[\D]/g
input0 = "Mт"
results = [
  "M"
  "т"
]
shouldBe "input0.match(regexGlobal27);", "results"
regexGlobal28 = /[^a]+/g
input0 = "bcd"
results = ["bcd"]
shouldBe "input0.match(regexGlobal28);", "results"
input1 = "ĀaYɖZ"
results = [
  "Ā"
  "YɖZ"
]
shouldBe "input1.match(regexGlobal28);", "results"
regexGlobal29 = /(a|)/g
input0 = "catac"
results = [
  ""
  "a"
  ""
  "a"
  ""
  ""
]
shouldBe "input0.match(regexGlobal29);", "results"
input1 = "aɖa"
results = [
  "a"
  ""
  "a"
  ""
]
shouldBe "input1.match(regexGlobal29);", "results"

# DISABLED:
# These tests use (?<) or (?>) constructs. These are not currently valid in ECMAScript,
# but these tests may be useful if similar constructs are introduced in the future.

#var regex18 = /(?<=aXb)cd/;
#var input0 = "aXbcd";
#var results = ["cd"];
#shouldBe('regex18.exec(input0);', 'results');
#
#var regex19 = /(?<=a\u0100b)cd/;
#var input0 = "a\u0100bcd";
#var results = ["cd"];
#shouldBe('regex19.exec(input0);', 'results');
#
#var regex20 = /(?<=a\u100000b)cd/;
#var input0 = "a\u100000bcd";
#var results = ["cd"];
#shouldBe('regex20.exec(input0);', 'results');
#
#var regex23 = /(?<=(.))X/;
#var input0 = "WXYZ";
#var results = ["X", "W"];
#shouldBe('regex23.exec(input0);', 'results');
#var input1 = "\u0256XYZ";
#var results = ["X", "\u0256"];
#shouldBe('regex23.exec(input1);', 'results');
#// Failers
#var input2 = "XYZ";
#var results = null;
#shouldBe('regex23.exec(input2);', 'results');
#
#var regex46 = /(?<=a\u0100{2}b)X/;
#var input0 = "Xyyya\u0100\u0100bXzzz";
#var results = ["X"];
#shouldBe('regex46.exec(input0);', 'results');
#
#var regex83 = /(?<=[\u0100\u0200])X/;
#var input0 = "abc\u0200X";
#var results = ["X"];
#shouldBe('regex83.exec(input0);', 'results');
#var input1 = "abc\u0100X";
#var results = ["X"];
#shouldBe('regex83.exec(input1);', 'results');
#// Failers
#var input2 = "X";
#var results = null;
#shouldBe('regex83.exec(input2);', 'results');
#
#var regex84 = /(?<=[Q\u0100\u0200])X/;
#var input0 = "abc\u0200X";
#var results = ["X"];
#shouldBe('regex84.exec(input0);', 'results');
#var input1 = "abc\u0100X";
#var results = ["X"];
#shouldBe('regex84.exec(input1);', 'results');
#var input2 = "abQX";
#var results = ["X"];
#shouldBe('regex84.exec(input2);', 'results');
#// Failers
#var input3 = "X";
#var results = null;
#shouldBe('regex84.exec(input3);', 'results');
#
#var regex85 = /(?<=[\u0100\u0200]{3})X/;
#var input0 = "abc\u0100\u0200\u0100X";
#var results = ["X"];
#shouldBe('regex85.exec(input0);', 'results');
#// Failers
#var input1 = "abc\u0200X";
#var results = null;
#shouldBe('regex85.exec(input1);', 'results');
#var input2 = "X";
#var results = null;
#shouldBe('regex85.exec(input2);', 'results');

# DISABLED:
# These tests use PCRE's \C token. This is not currently valid in ECMAScript,
# but these tests may be useful if similar constructs are introduced in the future.

#var regex24 = /X(\C{3})/;
#var input0 = "X\u1234";
#var results = ["X\u1234", "\u1234"];
#shouldBe('regex24.exec(input0);', 'results');
#
#var regex25 = /X(\C{4})/;
#var input0 = "X\u1234YZ";
#var results = ["X\u1234Y", "\u1234Y"];
#shouldBe('regex25.exec(input0);', 'results');
#
#var regex26 = /X\C*/;
#var input0 = "XYZabcdce";
#var results = ["XYZabcdce"];
#shouldBe('regex26.exec(input0);', 'results');
#
#var regex27 = /X\C*?/;
#var input0 = "XYZabcde";
#var results = ["X"];
#shouldBe('regex27.exec(input0);', 'results');
#
#var regex28 = /X\C{3,5}/;
#var input0 = "Xabcdefg";
#var results = ["Xabcde"];
#shouldBe('regex28.exec(input0);', 'results');
#var input1 = "X\u1234";
#var results = ["X\u1234"];
#shouldBe('regex28.exec(input1);', 'results');
#var input2 = "X\u1234YZ";
#var results = ["X\u1234YZ"];
#shouldBe('regex28.exec(input2);', 'results');
#var input3 = "X\u1234\u0512";
#var results = ["X\u1234\u0512"];
#shouldBe('regex28.exec(input3);', 'results');
#var input4 = "X\u1234\u0512YZ";
#var results = ["X\u1234\u0512"];
#shouldBe('regex28.exec(input4);', 'results');
#
#var regex29 = /X\C{3,5}?/;
#var input0 = "Xabcdefg";
#var results = ["Xabc"];
#shouldBe('regex29.exec(input0);', 'results');
#var input1 = "X\u1234";
#var results = ["X\u1234"];
#shouldBe('regex29.exec(input1);', 'results');
#var input2 = "X\u1234YZ";
#var results = ["X\u1234"];
#shouldBe('regex29.exec(input2);', 'results');
#var input3 = "X\u1234\u0512";
#var results = ["X\u1234"];
#shouldBe('regex29.exec(input3);', 'results');
#
#var regex89 = /a\Cb/;
#var input0 = "aXb";
#var results = ["aXb"];
#shouldBe('regex89.exec(input0);', 'results');
#var input1 = "a\nb";
#var results = ["a\x0ab"];
#shouldBe('regex89.exec(input1);', 'results');
#
#var regex90 = /a\Cb/;
#var input0 = "aXb";
#var results = ["aXb"];
#shouldBe('regex90.exec(input0);', 'results');
#var input1 = "a\nb";
#var results = ["a\u000ab"];
#shouldBe('regex90.exec(input1);', 'results');
#// Failers
#var input2 = "a\u0100b";
#var results = null;
#shouldBe('regex90.exec(input2);', 'results');
