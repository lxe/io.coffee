# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Flags: --expose-debug-as debug
listener = (event, exec_state, event_data, data) ->
  try
    if event is Debug.DebugEvent.Break
      if breaks is 0
        exec_state.prepareStep Debug.StepAction.StepIn, 2
        breaks = 1
      else if breaks <= 3
        breaks++
        
        # Check whether we break at the expected line.
        print event_data.sourceLineText()
        assertTrue event_data.sourceLineText().indexOf("Expected to step") > 0
        exec_state.prepareStep Debug.StepAction.StepIn, 3
  catch e
    exception = true
  return
cb_set = (num) ->
  print "element " + num # Expected to step to this point.
  true
cb_map = (key, val) ->
  print "key " + key + ", value " + val # Expected to step to this point.
  true

# Test two levels of builtin callbacks:
# Array.forEach calls a callback function, which by itself uses
# Array.forEach with another callback function.
second_level_listener = (event, exec_state, event_data, data) ->
  try
    if event is Debug.DebugEvent.Break
      if breaks is 0
        exec_state.prepareStep Debug.StepAction.StepIn, 3
        breaks = 1
      else if breaks <= 16
        breaks++
        
        # Check whether we break at the expected line.
        assertTrue event_data.sourceLineText().indexOf("Expected to step") > 0
        
        # Step two steps further every four breaks to skip the
        # forEach call in the first level of recurision.
        step = (if (breaks % 4 is 1) then 6 else 3)
        exec_state.prepareStep Debug.StepAction.StepIn, step
  catch e
    exception = true
  return
cb_set_foreach = (num) ->
  s.forEach cb_set
  print "back to the first level of recursion."
  return
cb_map_foreach = (key, val) ->
  m.forEach cb_set
  print "back to the first level of recursion."
  return
Debug = debug.Debug
exception = false
s = new Set()
s.add 1
s.add 2
s.add 3
s.add 4
m = new Map()
m.set "foo", 1
m.set "bar", 2
m.set "baz", 3
m.set "bat", 4
Debug.setListener listener
breaks = 0
debugger
s.forEach cb_set
assertFalse exception
assertEquals 4, breaks
breaks = 0
debugger
m.forEach cb_map
assertFalse exception
assertEquals 4, breaks
Debug.setListener null
Debug.setListener second_level_listener
breaks = 0
debugger
s.forEach cb_set_foreach
assertFalse exception
assertEquals 17, breaks
breaks = 0
debugger
m.forEach cb_map_foreach
assertFalse exception
assertEquals 17, breaks
Debug.setListener null
