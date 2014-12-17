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
oneMatch = (re) ->
  "abcd".replace re, ->

  assertEquals "abcd", RegExp.input
  assertEquals "a", RegExp.leftContext
  assertEquals "b", RegExp.lastMatch
  assertEquals "", RegExp.lastParen
  assertEquals `undefined`, RegExp.lastIndex
  assertEquals `undefined`, RegExp.index
  assertEquals "cd", RegExp.rightContext
  i = 1

  while i < 10
    assertEquals "", RegExp["$" + i]
    i++
  return
captureMatch = (re) ->
  "abcd".replace re, ->

  assertEquals "abcd", RegExp.input
  assertEquals "a", RegExp.leftContext
  assertEquals "bc", RegExp.lastMatch
  assertEquals "c", RegExp.lastParen
  assertEquals `undefined`, RegExp.lastIndex
  assertEquals `undefined`, RegExp.index
  assertEquals "d", RegExp.rightContext
  assertEquals "b", RegExp.$1
  assertEquals "c", RegExp.$2
  i = 3

  while i < 10
    assertEquals "", RegExp["$" + i]
    i++
  return
Override = ->
  
  # Set the internal lastMatchInfoOverride.  After calling this we do a normal
  # match and verify the override was cleared and that we record the new
  # captures.
  "abcdabcd".replace /(b)(c)/g, ->

  return
TestOverride = (input, expect, property, re_src) ->
  OverrideCase = (fn) ->
    Override()
    fn()
    assertEquals expect, RegExp[property]
    return
  re = new RegExp(re_src)
  re_g = new RegExp(re_src, "g")
  OverrideCase ->
    input.replace re, "x"

  OverrideCase ->
    input.replace re_g, "x"

  OverrideCase ->
    input.replace re, ""

  OverrideCase ->
    input.replace re_g, ""

  OverrideCase ->
    input.match re

  OverrideCase ->
    input.match re_g

  OverrideCase ->
    re.test input

  OverrideCase ->
    re_g.test input

  return
no_last_match = (fn) ->
  fn()
  assertEquals "hestfisk", RegExp.$1
  return

# Here's one that matches once, then tries to match again, but fails.
# Verify that the last match info is from the last match, not from the
# failure that came after.

# A test that initially does a zero width match, but later does a non-zero
# width match.

# We test FilterASCII using regexps that will backtrack forever.  Since
# a regexp with a non-ASCII character in it can never match an ASCII
# string we can test that the relevant node is removed by verifying that
# there is no hang.
NoHang = (re) ->
  "This is an ASCII string that could take forever".match re
  return
oneMatch /b/
oneMatch /b/g
"abcdabcd".replace /b/g, ->

assertEquals "abcdabcd", RegExp.input
assertEquals "abcda", RegExp.leftContext
assertEquals "b", RegExp.lastMatch
assertEquals "", RegExp.lastParen
assertEquals `undefined`, RegExp.lastIndex
assertEquals `undefined`, RegExp.index
assertEquals "cd", RegExp.rightContext
i = 1

while i < 10
  assertEquals "", RegExp["$" + i]
  i++
captureMatch /(b)(c)/
captureMatch /(b)(c)/g
"abcdabcd".replace /(b)(c)/g, ->

assertEquals "abcdabcd", RegExp.input
assertEquals "abcda", RegExp.leftContext
assertEquals "bc", RegExp.lastMatch
assertEquals "c", RegExp.lastParen
assertEquals `undefined`, RegExp.lastIndex
assertEquals `undefined`, RegExp.index
assertEquals "d", RegExp.rightContext
assertEquals "b", RegExp.$1
assertEquals "c", RegExp.$2
i = 3

while i < 10
  assertEquals "", RegExp["$" + i]
  i++
input = "bar.foo baz......"
re_str = "(ba.).*?f"
TestOverride input, "bar", "$1", re_str
input = "foo bar baz"
re_str = "bar"
TestOverride input, "bar", "$&", re_str
/(hestfisk)/.test "There's no such thing as a hestfisk!"
no_last_match ->
  "foo".replace "f", ""
  return

no_last_match ->
  "foo".replace "f", "f"
  return

no_last_match ->
  "foo".split "o"
  return

base = "In the music.  In the music.  "
cons = base + base + base + base
no_last_match ->
  cons.replace "x", "y"
  return

no_last_match ->
  cons.replace "e", "E"
  return

"bar.foo baz......".replace /(ba.).*?f/g, ->
  "x"

assertEquals "bar", RegExp.$1
a = "foo bar baz".replace(/^|bar/g, "")
assertEquals "foo  baz", a
a = "foo bar baz".replace(/^|bar/g, "*")
assertEquals "*foo * baz", a
NoHang /(((.*)*)*x)Ā/ # Continuation after loop is filtered, so is loop.
NoHang /(((.*)*)*Ā)foo/ # Body of loop filtered.
NoHang /Ā(((.*)*)*x)/ # Everything after a filtered character is filtered.
NoHang /(((.*)*)*x)Ā/ # Everything before a filtered character is filtered.
NoHang /[ćăĀ](((.*)*)*x)/ # Everything after a filtered class is filtered.
NoHang /(((.*)*)*x)[ćăĀ]/ # Everything before a filtered class is filtered.
NoHang /[^\x00-\xff](((.*)*)*x)/ # After negated class.
NoHang /(((.*)*)*x)[^\x00-\xff]/ # Before negated class.
NoHang /(?!(((.*)*)*x)Ā)foo/ # Negative lookahead is filtered.
NoHang /(?!(((.*)*)*x))Ā/ # Continuation branch of negative lookahead.
NoHang /(?=(((.*)*)*x)Ā)foo/ # Positive lookahead is filtered.
NoHang /(?=(((.*)*)*x))Ā/ # Continuation branch of positive lookahead.
NoHang /(?=Ā)(((.*)*)*x)/ # Positive lookahead also prunes continuation.
NoHang /(æ|ø|Ā)(((.*)*)*x)/ # All branches of alternation are filtered.
NoHang /(a|b|(((.*)*)*x))Ā/ # 1 out of 3 branches pruned.
NoHang /(a|(((.*)*)*x)ă|(((.*)*)*x)Ā)/ # 2 out of 3 branches pruned.
s = "Don't prune based on a repetition of length 0"
assertEquals null, s.match(/å{1,1}prune/)
assertEquals "prune", (s.match(/å{0,0}prune/)[0])

# Some very deep regexps where FilterASCII gives up in order not to make the
# stack overflow.
regex6 = /a*\u0100*\w/
input0 = "a"
regex6.exec input0
re = "Ā*\\w"
i = 0

while i < 200
  re = "a*" + re
  i++
regex7 = new RegExp(re)
regex7.exec input0
regex8 = new RegExp(re, "i")
regex8.exec input0
re = "[Ā]*\\w"
i = 0

while i < 200
  re = "a*" + re
  i++
regex9 = new RegExp(re)
regex9.exec input0
regex10 = new RegExp(re, "i")
regex10.exec input0
regex11 = /^(?:[^\u0000-\u0080]|[0-9a-z?,.!&\s#()])+$/i
regex11.exec input0
regex12 = /u(\xf0{8}?\D*?|( ? !)$h??(|)*?(||)+?\6((?:\W\B|--\d-*-|)?$){0, }?|^Y( ? !1)\d+)+a/
regex12.exec ""
