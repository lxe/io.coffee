# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-debug-as debug
f0 = ->
  v00 = 0 # Break 1
  v01 = 1
  
  # Normal function call in a catch scope.
  try
    throw 1
  catch e
    try
      f1()
    catch e
      v02 = 2 # Break 13
  v03 = 3
  v04 = 4
  return
f1 = ->
  v10 = 0 # Break 2
  v11 = 1
  
  # Getter call.
  v12 = o.get
  v13 = 3 # Break 4
  # Setter call.
  o.set = 2
  v14 = 4 # Break 6
  # Function.prototype.call.
  f2.call()
  v15 = 5 # Break 12
  v16 = 6
  
  # Exit function by throw.
  throw 1v17 = 7
  return
get = ->
  g0 = 0 # Break 3
  g1 = 1
  3
set = ->
  s0 = 0 # Break 5
  3
f2 = ->
  v20 = 0 # Break 7
  # Construct call.
  v21 = new c0()
  v22 = 2 # Break 9
  # Bound function.
  b0()
  2 # Break 11
c0 = ->
  @v0 = 0 # Break 8
  @v1 = 1
  return
f3 = ->
  v30 = 0 # Break 10
  v31 = 1
  3
listener = (event, exec_state, event_data, data) ->
  return  unless event is Debug.DebugEvent.Break
  try
    line = exec_state.frame(0).sourceLineText()
    print line
    match = line.match(/\/\/ Break (\d+)$/)
    assertEquals 2, match.length
    assertEquals break_count, parseInt(match[1])
    break_count += step_size
    exec_state.prepareStep Debug.StepAction.StepFrame, step_size
  catch e
    print e + e.stack
    exception = e
  return
b0 = f3.bind(o)
o = {}
Object.defineProperty o, "get",
  get: get

Object.defineProperty o, "set",
  set: set

Debug = debug.Debug
break_count = 0
exception = null
step_size = undefined
step_size = 1
while step_size < 6
  print "step size = " + step_size
  break_count = 0
  Debug.setListener listener
  debugger # Break 0
  f0()
  Debug.setListener null # Break 14
  assertTrue break_count > 14
  step_size++
assertNull exception
