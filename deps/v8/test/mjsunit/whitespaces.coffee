# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# WhiteSpace defined in ECMA-262 5.1, 7.2
# Tab                  TAB
# Vertical Tab         VT
# Form Feed            FF
# Space                SP
# No-break space       NBSP
# Byte Order Mark      BOM

# LineTerminator defined in ECMA-262 5.1, 7.3
# Line Feed            LF
# Carriage Return      CR
# Line Separator       LS
# Paragraph Separator  PS

# Unicode 6.3.0 whitespaces (category 'Zs')
# Ogham Space Mark
# Mongolian Vowel Separator
# EN QUAD
# EM QUAD
# EN SPACE
# EM SPACE
# THREE-PER-EM SPACE
# FOUR-PER-EM SPACE
# SIX-PER-EM SPACE
# FIGURE SPACE
# PUNCTUATION SPACE
# THIN SPACE
# HAIR SPACE
# LINE SEPARATOR
# PARAGRAPH SEPARATOR
# NARROW NO-BREAK SPACE
# MEDIUM MATHEMATICAL SPACE
# IDEOGRAPHIC SPACE

# Add single twobyte char to force twobyte representation.
# Interestingly, snowman is not "white" space :)
is_whitespace = (c) ->
  whitespaces.indexOf(c.charCodeAt(0)) > -1
test_regexp = (str) ->
  pos_match = str.match(/\s/)
  neg_match = str.match(/\S/)
  test_char = str[0]
  postfix = str[1]
  if is_whitespace(test_char)
    assertEquals test_char, pos_match[0]
    assertEquals postfix, neg_match[0]
  else
    assertEquals test_char, neg_match[0]
    assertNull pos_match
  return
test_trim = (c, infix) ->
  str = c + c + c + infix + c
  if is_whitespace(c)
    assertEquals infix, str.trim()
  else
    assertEquals str, str.trim()
  return
test_parseInt = (c, postfix) ->
  
  # Skip if prefix is a digit.
  return  if c >= "0" and c <= "9"
  str = c + c + "123" + postfix
  if is_whitespace(c)
    assertEquals 123, parseInt(str)
  else
    assertEquals NaN, parseInt(str)
  return
test_eval = (c, content) ->
  return  unless is_whitespace(c)
  str = c + c + "'" + content + "'" + c + c
  assertEquals content, eval(str)
  return
test_stringtonumber = (c, postfix) ->
  
  # Skip if prefix is a digit.
  return  if c >= "0" and c <= "9"
  result = 1 + Number(c + "123" + c + postfix)
  if is_whitespace(c)
    assertEquals 124, result
  else
    assertEquals NaN, result
  return
whitespaces = [
  0x0009
  0x000b
  0x000c
  0x0020
  0x00a0
  0xfeff
  0x000a
  0x000d
  0x2028
  0x2029
  0x1680
  0x180e
  0x2000
  0x2001
  0x2002
  0x2003
  0x2004
  0x2005
  0x2006
  0x2007
  0x2008
  0x2009
  0x200a
  0x2028
  0x2029
  0x202f
  0x205f
  0x3000
]
twobyte = "☃"
onebyte = "~"
twobytespace = " "
onebytespace = " "
i = 0

while i < 0x10000
  c = String.fromCharCode(i)
  test_regexp c + onebyte
  test_regexp c + twobyte
  test_trim c, onebyte + "trim"
  test_trim c, twobyte + "trim"
  test_parseInt c, onebyte
  test_parseInt c, twobyte
  test_eval c, onebyte
  test_eval c, twobyte
  test_stringtonumber c, onebytespace
  test_stringtonumber c, twobytespace
  i++
