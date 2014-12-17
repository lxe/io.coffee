# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-debug-as debug
sentinel = ->
outer = ->
  C = (C_ = ->
    CC = ->
      @x = 0
      return
    y = 1
    CC::f = CCf = ->
      @x += y
      @x

    CC
  )()
  c = new C(0)
  return

Debug = debug.Debug
script = Debug.findScript(sentinel)
line = 14
line_start = Debug.findScriptSourcePosition(script, line, 0)
line_end = Debug.findScriptSourcePosition(script, line + 1, 0) - 1
actual = Debug.setBreakPointByScriptIdAndPosition(script.id, line_start).actual_position

# Make sure the actual break position is within the line where we set
# the break point.
assertTrue line_start <= actual
assertTrue actual <= line_end
