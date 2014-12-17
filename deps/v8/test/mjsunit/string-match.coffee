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

###*
@fileoverview Test String.prototype.match
###
testMatch = (name, input, regexp, result, captures, from, to) ->
  matchResult = input.match(regexp)
  assertEquals result, matchResult, name + "-match"
  match = input.substring(from, to)
  preMatch = input.substring(0, from)
  postMatch = input.substring(to)
  lastParen = (if captures.length > 0 then captures[captures.length - 1] else "")
  if regexp.global
    
    # Returns array of matched strings.
    lastMatch = matchResult[matchResult.length - 1]
    assertEquals match, lastMatch, name + "-match-string_g"
  else
    
    # Returns array of match and captures.
    assertEquals match, matchResult[0], name + "-match-string"
    assertEquals captures.length + 1, matchResult.length, name + "-cap-return"
    i = 1

    while i < matchResult.length
      assertEquals captures[i - 1], matchResult[i], name + "-cap-return-" + i
      i++
  assertEquals match, RegExp["$&"], name + "-$&"
  assertEquals match, RegExp.lastMatch, name + "-lastMatch"
  assertEquals `undefined`, RegExp.$0, name + "-nocapture-10"
  i = 1

  while i <= 9
    if i <= captures.length
      assertEquals captures[i - 1], RegExp["$" + i], name + "-capture-" + i
    else
      assertEquals "", RegExp["$" + i], name + "-nocapture-" + i
    i++
  assertEquals `undefined`, RegExp.$10, name + "-nocapture-10"
  assertEquals input, RegExp.input, name + "-input"
  assertEquals input, RegExp.$_, name + "-$_"
  assertEquals preMatch, RegExp["$`"], name + "-$`"
  assertEquals preMatch, RegExp.leftContext, name + "-leftContex"
  assertEquals postMatch, RegExp["$'"], name + "-$'"
  assertEquals postMatch, RegExp.rightContext, name + "-rightContex"
  assertEquals lastParen, RegExp["$+"], name + "-$+"
  assertEquals lastParen, RegExp.lastParen, name + "-lastParen"
  return
stringSample = "A man, a plan, a canal: Panama"
stringSample2 = "Argle bargle glop glyf!"
stringSample3 = "abcdefghijxxxxxxxxxx"

# Non-capturing, non-global regexp.
re_nog = /\w+/
testMatch "Nonglobal", stringSample, re_nog, ["A"], [], 0, 1
re_nog.lastIndex = 2
testMatch "Nonglobal-ignore-lastIndex", stringSample, re_nog, ["A"], [], 0, 1

# Capturing non-global regexp.
re_multicap = /(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)/
testMatch "Capture-Nonglobal", stringSample3, re_multicap, [
  "abcdefghij"
  "a"
  "b"
  "c"
  "d"
  "e"
  "f"
  "g"
  "h"
  "i"
  "j"
], [
  "a"
  "b"
  "c"
  "d"
  "e"
  "f"
  "g"
  "h"
  "i"
  "j"
], 0, 10

# Global regexp (also check that capture from before are cleared)
re = /\w+/g
testMatch "Global", stringSample2, re, [
  "Argle"
  "bargle"
  "glop"
  "glyf"
], [], 18, 22
re.lastIndex = 10
testMatch "Global-ignore-lastIndex", stringSample2, re, [
  "Argle"
  "bargle"
  "glop"
  "glyf"
], [], 18, 22

# Capturing global regexp
re_cap = /\w(\w*)/g
testMatch "Capture-Global", stringSample, re_cap, [
  "A"
  "man"
  "a"
  "plan"
  "a"
  "canal"
  "Panama"
], ["anama"], 24, 30

# Atom, non-global
re_atom = /an/
testMatch "Atom", stringSample, re_atom, ["an"], [], 3, 5

# Atom, global
re_atomg = /an/g
testMatch "Global-Atom", stringSample, re_atomg, [
  "an"
  "an"
  "an"
  "an"
], [], 25, 27
