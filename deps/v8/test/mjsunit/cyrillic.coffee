# Copyright 2009 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Test Unicode character ranges in regexps.

# Cyrillic.
# A
# a
# YA
# ya
# CHE
# che
# Actually no characters are between the cases in Cyrillic.

# Greek.
# ALPHA
# alpha
# OMEGA
# omega
# SIGMA
# sigma
# Epsilon acute is between ALPHA-OMEGA and alpha-omega, ie it
# is between OMEGA and alpha.
Range = (from, to, flags) ->
  new RegExp("[" + from + "-" + to + "]", flags)
cyrillic =
  FIRST: "А"
  first: "а"
  LAST: "Я"
  last: "я"
  MIDDLE: "Ч"
  middle: "ч"
  BetweenCases: false

SIGMA = "Σ"
sigma = "σ"
alternative_sigma = "ς"
greek =
  FIRST: "Α"
  first: "α"
  LAST: "Ω"
  last: "ω"
  MIDDLE: SIGMA
  middle: sigma
  BetweenCases: "έ"


# Test Cyrillic and Greek separately.
lang = 0

while lang < 2
  chars = (if (lang is 0) then cyrillic else greek)
  i = 0

  while i < 2
    lc = (i is 0) # Lower case.
    first = (if lc then chars.first else chars.FIRST)
    middle = (if lc then chars.middle else chars.MIDDLE)
    last = (if lc then chars.last else chars.LAST)
    first_other_case = (if lc then chars.FIRST else chars.first)
    middle_other_case = (if lc then chars.MIDDLE else chars.middle)
    last_other_case = (if lc then chars.LAST else chars.last)
    assertTrue Range(first, last).test(first), 1
    assertTrue Range(first, last).test(middle), 2
    assertTrue Range(first, last).test(last), 3
    assertFalse Range(first, last).test(first_other_case), 4
    assertFalse Range(first, last).test(middle_other_case), 5
    assertFalse Range(first, last).test(last_other_case), 6
    assertTrue Range(first, last, "i").test(first), 7
    assertTrue Range(first, last, "i").test(middle), 8
    assertTrue Range(first, last, "i").test(last), 9
    assertTrue Range(first, last, "i").test(first_other_case), 10
    assertTrue Range(first, last, "i").test(middle_other_case), 11
    assertTrue Range(first, last, "i").test(last_other_case), 12
    if chars.BetweenCases
      assertFalse Range(first, last).test(chars.BetweenCases), 13
      assertFalse Range(first, last, "i").test(chars.BetweenCases), 14
    i++
  if chars.BetweenCases
    assertTrue Range(chars.FIRST, chars.last).test(chars.BetweenCases), 15
    assertTrue Range(chars.FIRST, chars.last, "i").test(chars.BetweenCases), 16
  lang++

# Test range that covers both greek and cyrillic characters.
for key of greek
  assertTrue Range(greek.FIRST, cyrillic.last).test(greek[key]), 17 + key
  assertTrue Range(greek.FIRST, cyrillic.last).test(cyrillic[key]), 18 + key  if cyrillic[key]
i = 0

while i < 2
  ignore_case = (i is 0)
  flag = (if ignore_case then "i" else "")
  assertTrue Range(greek.first, cyrillic.LAST, flag).test(greek.first), 19
  assertTrue Range(greek.first, cyrillic.LAST, flag).test(greek.middle), 20
  assertTrue Range(greek.first, cyrillic.LAST, flag).test(greek.last), 21
  assertTrue Range(greek.first, cyrillic.LAST, flag).test(cyrillic.FIRST), 22
  assertTrue Range(greek.first, cyrillic.LAST, flag).test(cyrillic.MIDDLE), 23
  assertTrue Range(greek.first, cyrillic.LAST, flag).test(cyrillic.LAST), 24
  
  # A range that covers the lower case greek letters and the upper case cyrillic
  # letters.
  assertEquals ignore_case, Range(greek.first, cyrillic.LAST, flag).test(greek.FIRST), 25
  assertEquals ignore_case, Range(greek.first, cyrillic.LAST, flag).test(greek.MIDDLE), 26
  assertEquals ignore_case, Range(greek.first, cyrillic.LAST, flag).test(greek.LAST), 27
  assertEquals ignore_case, Range(greek.first, cyrillic.LAST, flag).test(cyrillic.first), 28
  assertEquals ignore_case, Range(greek.first, cyrillic.LAST, flag).test(cyrillic.middle), 29
  assertEquals ignore_case, Range(greek.first, cyrillic.LAST, flag).test(cyrillic.last), 30
  i++

# Sigma is special because there are two lower case versions of the same upper
# case character.  JS requires that case independece means that you should
# convert everything to upper case, so the two sigma variants are equal to each
# other in a case independt comparison.
i = 0

while i < 2
  simple = (i isnt 0)
  name = (if simple then "" else "[]")
  regex = (if simple then SIGMA else "[" + SIGMA + "]")
  assertFalse new RegExp(regex).test(sigma), 31 + name
  assertFalse new RegExp(regex).test(alternative_sigma), 32 + name
  assertTrue new RegExp(regex).test(SIGMA), 33 + name
  assertTrue new RegExp(regex, "i").test(sigma), 34 + name
  
  # JSC and Tracemonkey fail this one.
  assertTrue new RegExp(regex, "i").test(alternative_sigma), 35 + name
  assertTrue new RegExp(regex, "i").test(SIGMA), 36 + name
  regex = (if simple then sigma else "[" + sigma + "]")
  assertTrue new RegExp(regex).test(sigma), 41 + name
  assertFalse new RegExp(regex).test(alternative_sigma), 42 + name
  assertFalse new RegExp(regex).test(SIGMA), 43 + name
  assertTrue new RegExp(regex, "i").test(sigma), 44 + name
  
  # JSC and Tracemonkey fail this one.
  assertTrue new RegExp(regex, "i").test(alternative_sigma), 45 + name
  assertTrue new RegExp(regex, "i").test(SIGMA), 46 + name
  regex = (if simple then alternative_sigma else "[" + alternative_sigma + "]")
  assertFalse new RegExp(regex).test(sigma), 51 + name
  assertTrue new RegExp(regex).test(alternative_sigma), 52 + name
  assertFalse new RegExp(regex).test(SIGMA), 53 + name
  
  # JSC and Tracemonkey fail this one.
  assertTrue new RegExp(regex, "i").test(sigma), 54 + name
  assertTrue new RegExp(regex, "i").test(alternative_sigma), 55 + name
  
  # JSC and Tracemonkey fail this one.
  assertTrue new RegExp(regex, "i").test(SIGMA), 56 + name
  i++
add_non_ascii_character_to_subject = 0

while add_non_ascii_character_to_subject < 2
  suffix = (if add_non_ascii_character_to_subject then "￾" else "")
  
  # A range that covers both ASCII and non-ASCII.
  i = 0

  while i < 2
    full = (i isnt 0)
    mixed = (if full then "[a-￿]" else "[a-" + cyrillic.LAST + "]")
    f = (if full then "f" else "c")
    j = 0

    while j < 2
      ignore_case = (j is 0)
      flag = (if ignore_case then "i" else "")
      re = new RegExp(mixed, flag)
      expected = ignore_case or (full and !!add_non_ascii_character_to_subject)
      assertEquals expected, re.test("A" + suffix), 58 + flag + f
      assertTrue re.test("a" + suffix), 59 + flag + f
      assertTrue re.test("~" + suffix), 60 + flag + f
      assertTrue re.test(cyrillic.MIDDLE), 61 + flag + f
      assertEquals ignore_case or full, re.test(cyrillic.middle), 62 + flag + f
      j++
    i++
  add_non_ascii_character_to_subject++
