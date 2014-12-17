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

# Simple function which stores the last debug event.
safeEval = (code) ->
  try
    return eval("(" + code + ")")
  catch e
    assertEquals undefined, e
    return `undefined`
  return
testArguments = (dcp, arguments, success, type, enabled) ->
  request = "{" + base_request + ",\"arguments\":" + arguments + "}"
  json_response = dcp.processDebugJSONRequest(request)
  response = safeEval(json_response)
  if success
    assertTrue response.success, json_response
    assertEquals response.body.type, type
    assertEquals response.body.enabled, enabled
  else
    assertFalse response.success, json_response
  return
listener = (event, exec_state, event_data, data) ->
  try
    if event is Debug.DebugEvent.Break
      
      # Get the debug command processor.
      dcp = exec_state.debugCommandProcessor("unspecified_running_state")
      
      # Test some illegal setexceptionbreak requests.
      request = "{" + base_request + "}"
      response = safeEval(dcp.processDebugJSONRequest(request))
      assertFalse response.success
      testArguments dcp, "{}", false
      testArguments dcp, "{\"type\":0}", false
      
      # Test some legal setexceptionbreak requests with default.
      # Note: by default, break on exceptions should be disabled.  Hence,
      # the first time, we send the command with no enabled arg, the debugger
      # should toggle it on.  The second time, it should toggle it off.
      testArguments dcp, "{\"type\":\"all\"}", true, "all", true
      testArguments dcp, "{\"type\":\"all\"}", true, "all", false
      testArguments dcp, "{\"type\":\"uncaught\"}", true, "uncaught", true
      testArguments dcp, "{\"type\":\"uncaught\"}", true, "uncaught", false
      
      # Test some legal setexceptionbreak requests with explicit enabled arg.
      testArguments dcp, "{\"type\":\"all\",\"enabled\":true}", true, "all", true
      testArguments dcp, "{\"type\":\"all\",\"enabled\":false}", true, "all", false
      testArguments dcp, "{\"type\":\"uncaught\",\"enabled\":true}", true, "uncaught", true
      testArguments dcp, "{\"type\":\"uncaught\",\"enabled\":false}", true, "uncaught", false
      
      # Indicate that all was processed.
      listenerComplete = true
  catch e
    exception = e
  return

# Add the debug event listener.
g = ->
Debug = debug.Debug
listenerComplete = false
exception = false
breakpoint = -1
base_request = "\"seq\":0,\"type\":\"request\",\"command\":\"setexceptionbreak\""
Debug.setListener listener

# Set a break point and call to invoke the debug event listener.
breakpoint = Debug.setBreakPoint(g, 0, 0)
g()

# Make sure that the debug event listener vas invoked.
assertFalse exception, "exception in listener"
assertTrue listenerComplete, "listener did not run to completion"
