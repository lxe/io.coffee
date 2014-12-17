# Copyright 2012 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-debug-as debug
sentinel = ->

# Used in Debug.setScriptBreakPointById.
assertLocation = (p, l, c) ->
  location = script.locationFromPosition(p, false)
  assertEquals l, location.line
  assertEquals c, location.column
  return
o = f: (x) ->
  a = x + 1
  o = 1
  return

Debug = debug.Debug
Debug.setListener ->

script = Debug.findScript(sentinel)
p = Debug.findScriptSourcePosition(script, 9, 0)
q = Debug.setBreakPointByScriptIdAndPosition(script.id, p).actual_position
r = Debug.setBreakPointByScriptIdAndPosition(script.id, q).actual_position
assertEquals q, r
assertLocation p, 9, 0
assertLocation q, 9, 4
assertLocation r, 9, 4
