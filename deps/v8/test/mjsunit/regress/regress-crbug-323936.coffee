# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-debug-as debug
listener = (event, exec_state, event_data, data) ->
  return  unless event is Debug.DebugEvent.Break
  try
    if step is 0
      assertEquals "error", exec_state.frame(0).evaluate("e").value()
      exec_state.frame(0).evaluate "e = 'foo'"
      exec_state.frame(0).evaluate "x = 'modified'"
    else
      assertEquals "argument", exec_state.frame(0).evaluate("e").value()
      exec_state.frame(0).evaluate "e = 'bar'"
    step++
  catch e
    print e + e.stack
    exception = e
  return
f = (e, x) ->
  try
    throw "error"
  catch e
    debugger
    assertEquals "foo", e
  debugger
  assertEquals "bar", e
  assertEquals "modified", x
  return
Debug = debug.Debug
step = 0
exception = null
Debug.setListener listener
f "argument"
assertNull exception
assertEquals 2, step
