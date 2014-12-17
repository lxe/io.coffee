# Copyright 2008 the V8 project authors. All rights reserved.
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
listener = (event, exec_state, event_data, data) ->
  try
    context = what_is_capybara: "a fish"
    context2 =
      what_is_capybara: "a fish"
      what_is_parrot: "a beard"

    
    # Try in frame's scope.
    local_expression = "(what_is_capybara ? what_is_capybara : 'a beast') + '/' + what_is_parrot"
    result = evaluate_callback.in_top_frame(exec_state, local_expression, context)
    assertEquals "a fish/a bird", result
    
    # Try in frame's scope with overrididen local variables.
    result = evaluate_callback.in_top_frame(exec_state, local_expression, context2)
    assertEquals "a fish/a beard", result
    
    # Try in frame's scope, without context.
    local_expression2 = "what_is_parrot"
    result = evaluate_callback.in_top_frame(exec_state, local_expression2, undefined)
    assertEquals "a bird", result
    
    # Try in global additional scope.
    global_expression = "what_is_capybara ? what_is_capybara : 'a beast'"
    result = evaluate_callback.globally(exec_state, global_expression, context)
    assertEquals "a fish", result
    
    # Try in global scope with overridden global variables.
    context_with_undefined = undefined: "kitten"
    global_expression2 = "'cat' + '/' + undefined"
    result = evaluate_callback.globally(exec_state, global_expression2, context_with_undefined)
    assertEquals "cat/kitten", result
    
    # Try in global scope with no overridden global variables.
    result = evaluate_callback.globally(exec_state, global_expression2, undefined)
    assertEquals "cat/undefined", result
    
    # Try in global scope without additional context.
    global_expression3 = "'cat' + '/' + 'dog'"
    result = evaluate_callback.globally(exec_state, global_expression3, undefined)
    assertEquals "cat/dog", result
    listenerComplete = true
  catch e
    exception = e
  return
f = ->
  what_is_parrot = "a bird"
  debugger
  return
runF = ->
  exception = false
  listenerComplete = false
  Debug.setListener listener
  
  # Add the debug event listener.
  Debug.setListener listener
  f()
  assertFalse exception, "exception in listener"
  assertTrue listenerComplete
  return

# Now try all the same, but via debug protocol.
evaluateViaProtocol = (exec_state, expression, additional_context, frame_argument_adder) ->
  dcp = exec_state.debugCommandProcessor("unspecified_running_state")
  request_json =
    seq: 17
    type: "request"
    command: "evaluate"
    arguments:
      expression: expression

  frame_argument_adder request_json.arguments
  if additional_context
    context_json = []
    for key of additional_context
      context_json.push
        name: key
        handle: Debug.MakeMirror(additional_context[key]).handle()

    request_json.arguments.additional_context = context_json
  request = JSON.stringify(request_json)
  response_json = dcp.processDebugJSONRequest(request)
  response = JSON.parse(response_json)
  assertTrue response.success
  str_result = response.body.value
  str_result
Debug = debug.Debug
evaluate_callback = undefined
evaluate_callback =
  in_top_frame: (exec_state, expression, additional_context) ->
    exec_state.frame(0).evaluate(expression, undefined, additional_context).value()

  globally: (exec_state, expression, additional_context) ->
    exec_state.evaluateGlobal(expression, undefined, additional_context).value()

runF()
evaluate_callback =
  in_top_frame: (exec_state, expression, additional_context) ->
    evaluateViaProtocol exec_state, expression, additional_context, (args) ->
      args.frame = 0
      return


  globally: (exec_state, expression, additional_context) ->
    evaluateViaProtocol exec_state, expression, additional_context, (args) ->
      args.global = true
      return


runF()
