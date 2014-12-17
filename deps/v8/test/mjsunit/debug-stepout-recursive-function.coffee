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

# Flags: --expose-debug-as debug
# Get the Debug object exposed from the debug context global object.

# Simple debug event handler which counts the number of breaks hit and steps.
listener = (event, exec_state, event_data, data) ->
  try
    if event is Debug.DebugEvent.Break
      break_point_hit_count++
      
      # Continue stepping until returned to bottom frame.
      exec_state.prepareStep Debug.StepAction.StepOut, step_out_count  if exec_state.frameCount() > 1
  catch e
    exception = e
  return
BeginTest = (name) ->
  test_name = name
  break_point_hit_count = 0
  exception = null
  return
EndTest = (expected_break_point_hit_count) ->
  assertEquals expected_break_point_hit_count, break_point_hit_count, test_name
  assertNull exception, test_name
  test_name = null
  return

# Add the debug event listener.
fact = (x) ->
  debugger  if shouldBreak(x)
  if x < 2
    1
  else
    x * fact(x - 1)
Debug = debug.Debug
exception = null
step_out_count = 1
break_point_hit_count = 0
Debug.setListener listener
shouldBreak = null
BeginTest "Test 1"
shouldBreak = (x) ->
  x is 3

step_out_count = 1
fact 3
EndTest 2
BeginTest "Test 2"
shouldBreak = (x) ->
  x is 2

step_out_count = 1
fact 3
EndTest 3
BeginTest "Test 3"
shouldBreak = (x) ->
  x is 1

step_out_count = 2
fact 3
EndTest 2
BeginTest "Test 4"
shouldBreak = (x) ->
  x is 1 or x is 3

step_out_count = 2
fact 3
EndTest 3

# Get rid of the debug event listener.
Debug.setListener null
