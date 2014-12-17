# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
toSurrogatePair = (c) ->
  String.fromCharCode(((c - 0x10000) >>> 10) & 0x3ff | 0xd800) + String.fromCharCode(c & 0x3ff | 0xdc00)
testIdStart = (c, is_id_start) ->
  source = "var " + toSurrogatePair(c)
  print source
  if is_id_start
    assertDoesNotThrow source
  else
    assertThrows source
  return
testIdPart = (c, is_id_start) ->
  source = "var v" + toSurrogatePair(c)
  print source
  if is_id_start
    assertDoesNotThrow source
  else
    assertThrows source
  return
[
  0x10403
  0x1043c
  0x16f9c
  0x10048
  0x1014d
].forEach (c) ->
  testIdStart c, true
  testIdPart c, true
  return

[
  0x101fd
  0x11002
  0x104a9
].forEach (c) ->
  testIdStart c, false
  testIdPart c, true
  return

[
  0x10111
  0x1f4a9
].forEach (c) ->
  testIdStart c, false
  testIdPart c, false
  return

