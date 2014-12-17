# Copyright 2012 the V8 project authors. All rights reserved.
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

# Test that an optional capture is cleared between two matches.

# Test zero-length matches.

# Test zero-length matches that have non-zero-length sub-captures.

# Test multiple captures.

# Test multiple alternate captures.

# The same tests with UC16.

#Test that an optional capture is cleared between two matches.

# Test zero-length matches.

# Test zero-length matches that have non-zero-length sub-captures.

# Test multiple captures.

# Test multiple alternate captures.

# Test capture that is a real substring.

# Test zero-length matches that have non-zero-length sub-captures that do not
# start at the match start position.

# Create regexp that has a *lot* of captures.

# re_string = "(((...((a))...)))1"

# Atomic regexp.

# Small regexp (no capture);

# Small regexp (one capture).

# Large regexp (a lot of captures).
test_replace = (result_expectation, subject, regexp, replacement) ->
  i = 0

  while i < regexps.length
    
    # Overwrite last match info.
    "deadbeef".replace /(dead)beef/, "$1holeycow"
    
    # Conduct tests.
    assertEquals result_expectation, subject.replace(regexps[i], replacement)
    if subject.length is 0
      assertEquals "deadbeef", RegExp.lastMatch
      assertEquals "dead", RegExp["$1"]
    else
      assertEquals last_match_expectations[i], RegExp.lastMatch
      assertEquals first_capture_expectations[i], RegExp["$1"]
    i++
  return
test_match = (result_expectation, subject, regexp) ->
  i = 0

  while i < regexps.length
    
    # Overwrite last match info.
    "deadbeef".replace /(dead)beef/, "$1holeycow"
    
    # Conduct tests.
    unless result_expectation?
      assertNull subject.match(regexps[i])
    else
      assertArrayEquals result_expectation, subject.match(regexps[i])
    if subject.length is 0
      assertEquals "deadbeef", RegExp.lastMatch
      assertEquals "dead", RegExp["$1"]
    else
      assertEquals last_match_expectations[i], RegExp.lastMatch
      assertEquals first_capture_expectations[i], RegExp["$1"]
    i++
  return
str = "ABX X"
str = str.replace(/(\w)?X/g, (match, capture) ->
  assertTrue match.indexOf(capture) >= 0 or capture is `undefined`
  (if capture then capture.toLowerCase() else "-")
)
assertEquals "Ab -", str
str = "Als Gregor Samsa eines Morgens"
str = str.replace(/\b/g, (match, capture) ->
  "/"
)
assertEquals "/Als/ /Gregor/ /Samsa/ /eines/ /Morgens/", str
str = "It was a pleasure to burn."
str = str.replace(/(?=(\w+))\b/g, (match, capture) ->
  capture.length
)
assertEquals "2It 3was 1a 8pleasure 2to 4burn.", str
str = "Try not. Do, or do not. There is no try."
str = str.replace(/(not?)|(do)|(try)/g, (match, c1, c2, c3) ->
  assertTrue (c1 is `undefined` and c2 is `undefined`) or (c2 is `undefined` and c3 is `undefined`) or (c1 is `undefined` and c3 is `undefined`)
  return "-"  if c1
  return "+"  if c2
  "="  if c3
)
assertEquals "= -. +, or + -. There is - =.", str
str = "FOUR LEGS GOOD, TWO LEGS BAD!"
str = str.replace(/(FOUR|TWO) LEGS (GOOD|BAD)/g, (match, num_legs, likeability) ->
  assertTrue num_legs isnt `undefined`
  assertTrue likeability isnt `undefined`
  assertTrue likeability is "GOOD"  if num_legs is "FOUR"
  assertTrue likeability is "BAD"  if num_legs is "TWO"
  match.length - 10
)
assertEquals "4, 2!", str
str = "ABሴ ሴ"
str = str.replace(/(\w)?\u1234/g, (match, capture) ->
  assertTrue match.indexOf(capture) >= 0 or capture is `undefined`
  (if capture then capture.toLowerCase() else "-")
)
assertEquals "Ab -", str
str = "Als ☣♂ eines Morgens"
str = str.replace(/\b/g, (match, capture) ->
  "/"
)
assertEquals "/Als/ ☣♂ /eines/ /Morgens/", str
str = "It was a pleasure to 烧."
str = str.replace(/(?=(\w+))\b/g, (match, capture) ->
  capture.length
)
assertEquals "2It 3was 1a 8pleasure 2to 烧.", str
str = "Try not. D⚪, or d⚪ not. There is no try."
str = str.replace(/(not?)|(d\u26aa)|(try)/g, (match, c1, c2, c3) ->
  assertTrue (c1 is `undefined` and c2 is `undefined`) or (c2 is `undefined` and c3 is `undefined`) or (c1 is `undefined` and c3 is `undefined`)
  return "-"  if c1
  return "+"  if c2
  "="  if c3
)
assertEquals "= -. +, or + -. There is - =.", str
str = "FOUR 腿 GOOD, TWO 腿 BAD!"
str = str.replace(/(FOUR|TWO) \u817f (GOOD|BAD)/g, (match, num_legs, likeability) ->
  assertTrue num_legs isnt `undefined`
  assertTrue likeability isnt `undefined`
  assertTrue likeability is "GOOD"  if num_legs is "FOUR"
  assertTrue likeability is "BAD"  if num_legs is "TWO"
  match.length - 7
)
assertEquals "4, 2!", str
str = "Beasts of England, beasts of Ireland"
str = str.replace(/(.*)/g, (match) ->
  "~"
)
assertEquals "~~", str
str = "up up up up"
str = str.replace(/\b(?=u(p))/g, (match, capture) ->
  capture.length
)
assertEquals "1up 1up 1up 1up", str
re_string = "(a)"
i = 0

while i < 500
  re_string = "(" + re_string + ")"
  i++
re_string = re_string + "1"
regexps = new Array()
last_match_expectations = new Array()
first_capture_expectations = new Array()
regexps.push /a1/g
last_match_expectations.push "a1"
first_capture_expectations.push ""
regexps.push /\w1/g
last_match_expectations.push "a1"
first_capture_expectations.push ""
regexps.push /(a)1/g
last_match_expectations.push "a1"
first_capture_expectations.push "a"
regexps.push new RegExp(re_string, "g")
last_match_expectations.push "a1"
first_capture_expectations.push "a"

# Test for different number of matches.
m = 0

while m < 33
  
  # Create string that matches m times.
  
  # Test 1a: String.replace with string.
  
  # Test 1b: String.replace with function.
  f = ->
    "x"
  subject = ""
  test_1_expectation = ""
  test_2_expectation = ""
  test_3_expectation = (if (m is 0) then null else new Array())
  i = 0

  while i < m
    subject += "a11"
    test_1_expectation += "x1"
    test_2_expectation += "1"
    test_3_expectation.push "a1"
    i++
  test_replace test_1_expectation, subject, /a1/g, "x"
  test_replace test_1_expectation, subject, /a1/g, f
  
  # Test 2a: String.replace with empty string.
  test_replace test_2_expectation, subject, /a1/g, ""
  
  # Test 3a: String.match.
  test_match test_3_expectation, subject, /a1/g
  m++

# Test String hashing (compiling regular expression includes hashing).
crosscheck = ""
i = 0

while i < 12
  crosscheck += crosscheck
  i++
new RegExp(crosscheck)
subject = "ascii~only~string~here~"
replacement = ""
result = subject.replace(/~/g, replacement)
i = 0

while i < 5
  result += result
  i++
new RegExp(result)
