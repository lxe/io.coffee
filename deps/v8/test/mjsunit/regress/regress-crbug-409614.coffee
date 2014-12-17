# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-debug-as debug
f = ->
  0 # Break
listener = (event, exec_state, event_data, data) ->
  return  unless event is Debug.DebugEvent.Break
  try
    error_count++  if exec_state.frame(0).sourceLineText().indexOf("Break") < 0
    exec_state.prepareStep Debug.StepAction.StepIn, 2
    f() # We should not break in this call of f().
  catch e
    print e + e.stack
    exception = e
  return
Debug = debug.Debug
exception = null
error_count = 0
Debug.setListener listener
debugger # Break
f()
Debug.setListener null # Break
assertNull exception
assertEquals 0, error_count
