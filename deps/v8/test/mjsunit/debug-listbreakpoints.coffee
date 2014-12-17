# Copyright 2010 the V8 project authors. All rights reserved.
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

# Note: the following tests only checks the debugger handling of the
# setexceptionbreak command.  It does not test whether the debugger
# actually breaks on exceptions or not.  That functionality is tested
# in test-debug.cc instead.

# Note: The following function g() is purposedly placed here so that
# its line numbers will not change should we add more lines of test code
# below.  The test checks for these line numbers.
g = -> # line 40
  x = 5
  y = 6
  z = 7
  return
# Must be the line number of g() above.
# The first line of the file is line 0.

# Simple function which stores the last debug event.
safeEval = (code) ->
  try
    return eval("(" + code + ")")
  catch e
    assertEquals undefined, e
    return `undefined`
  return
clearBreakpoint = (dcp, breakpoint_id) ->
  base_request = "\"seq\":0,\"type\":\"request\",\"command\":\"clearbreakpoint\""
  arguments = "{\"breakpoint\":" + breakpoint_id + "}"
  request = "{" + base_request + ",\"arguments\":" + arguments + "}"
  json_response = dcp.processDebugJSONRequest(request)
  return
setBreakOnException = (dcp, type, enabled) ->
  base_request = "\"seq\":0,\"type\":\"request\",\"command\":\"setexceptionbreak\""
  arguments = "{\"type\":\"" + type + "\",\"enabled\":" + enabled + "}"
  request = "{" + base_request + ",\"arguments\":" + arguments + "}"
  json_response = dcp.processDebugJSONRequest(request)
  return
testArguments = (dcp, success, breakpoint_ids, breakpoint_linenos, break_on_all, break_on_uncaught) ->
  request = "{" + base_request + "}"
  json_response = dcp.processDebugJSONRequest(request)
  response = safeEval(json_response)
  num_breakpoints = breakpoint_ids.length
  if success
    assertTrue response.success, json_response
    assertEquals response.body.breakpoints.length, num_breakpoints
    if num_breakpoints > 0
      breakpoints = response.body.breakpoints
      i = 0

      while i < breakpoints.length
        id = breakpoints[i].number
        found = false
        j = 0

        while j < num_breakpoints
          if breakpoint_ids[j] is id
            assertEquals breakpoints[i].line, breakpoint_linenos[j]
            found = true
            break
          j++
        assertTrue found, "found unexpected breakpoint " + id
        i++
    assertEquals response.body.breakOnExceptions, break_on_all
    assertEquals response.body.breakOnUncaughtExceptions, break_on_uncaught
  else
    assertFalse response.success, json_response
  return
listener = (event, exec_state, event_data, data) ->
  try
    if event is Debug.DebugEvent.Break
      
      # Get the debug command processor.
      dcp = exec_state.debugCommandProcessor("unspecified_running_state")
      
      # Test with the 1 breakpoint already set:
      testArguments dcp, true, [breakpoint1], [first_lineno], false, false
      setBreakOnException dcp, "all", true
      testArguments dcp, true, [breakpoint1], [first_lineno], true, false
      setBreakOnException dcp, "uncaught", true
      testArguments dcp, true, [breakpoint1], [first_lineno], true, true
      setBreakOnException dcp, "all", false
      testArguments dcp, true, [breakpoint1], [first_lineno], false, true
      setBreakOnException dcp, "uncaught", false
      testArguments dcp, true, [breakpoint1], [first_lineno], false, false
      
      # Clear the one breakpoint and retest:
      clearBreakpoint dcp, breakpoint1
      testArguments dcp, true, [], [], false, false
      setBreakOnException dcp, "all", true
      testArguments dcp, true, [], [], true, false
      setBreakOnException dcp, "uncaught", true
      testArguments dcp, true, [], [], true, true
      setBreakOnException dcp, "all", false
      testArguments dcp, true, [], [], false, true
      setBreakOnException dcp, "uncaught", false
      testArguments dcp, true, [], [], false, false
      
      # Set some more breakpoints, and clear them in various orders:
      bp2 = Debug.setBreakPoint(g, 1, 0)
      testArguments dcp, true, [bp2], [first_lineno + 1], false, false
      bp3 = Debug.setBreakPoint(g, 2, 0)
      testArguments dcp, true, [
        bp2
        bp3
      ], [
        first_lineno + 1
        first_lineno + 2
      ], false, false
      bp4 = Debug.setBreakPoint(g, 3, 0)
      testArguments dcp, true, [
        bp2
        bp3
        bp4
      ], [
        first_lineno + 1
        first_lineno + 2
        first_lineno + 3
      ], false, false
      clearBreakpoint dcp, bp3
      testArguments dcp, true, [
        bp2
        bp4
      ], [
        first_lineno + 1
        first_lineno + 3
      ], false, false
      clearBreakpoint dcp, bp4
      testArguments dcp, true, [bp2], [first_lineno + 1], false, false
      bp5 = Debug.setBreakPoint(g, 3, 0)
      testArguments dcp, true, [
        bp2
        bp5
      ], [
        first_lineno + 1
        first_lineno + 3
      ], false, false
      clearBreakpoint dcp, bp2
      testArguments dcp, true, [bp5], [first_lineno + 3], false, false
      clearBreakpoint dcp, bp5
      testArguments dcp, true, [], [], false, false
      
      # Indicate that all was processed.
      listenerComplete = true
  catch e
    exception = e
  return
Debug = debug.Debug
first_lineno = 40
listenerComplete = false
exception = false
breakpoint1 = -1
base_request = "\"seq\":0,\"type\":\"request\",\"command\":\"listbreakpoints\""

# Add the debug event listener.
Debug.setListener listener

# Set a break point and call to invoke the debug event listener.
breakpoint1 = Debug.setBreakPoint(g, 0, 0)
g()

# Make sure that the debug event listener vas invoked.
assertFalse exception, "exception in listener"
assertTrue listenerComplete, "listener did not run to completion"
