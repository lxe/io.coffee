# Copyright 2012 the V8 project authors. All rights reserved.
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

# Accepts a function/closure 'fun' that must have a debugger statement inside.
# A variable 'variable_name' must be initialized before debugger statement
# and returned after the statement. The test will alter variable value when
# on debugger statement and check that returned value reflects the change.
RunPauseTest = (scope_number, expected_old_result, variable_name, new_value, expected_new_result, fun) ->
  listener_delegate = (exec_state) ->
    scope = exec_state.frame(0).scope(scope_number)
    scope.setVariableValue variable_name, new_value
    return
  listener = (event, exec_state, event_data, data) ->
    try
      if event is Debug.DebugEvent.Break
        listener_called = true
        listener_delegate exec_state
    catch e
      exception = e
    return
  actual_old_result = fun()
  assertEquals expected_old_result, actual_old_result
  listener_delegate = undefined
  listener_called = false
  exception = null
  
  # Add the debug event listener.
  Debug.setListener listener
  actual_new_value = undefined
  try
    actual_new_result = fun()
  finally
    Debug.setListener null
  assertUnreachable "Exception in listener\n" + exception.stack  if exception?
  assertTrue listener_called
  assertEquals expected_new_result, actual_new_result
  return

# Accepts a closure 'fun' that returns a variable from it's outer scope.
# The test changes the value of variable via the handle to function and checks
# that the return value changed accordingly.
RunClosureTest = (scope_number, expected_old_result, variable_name, new_value, expected_new_result, fun) ->
  actual_old_result = fun()
  assertEquals expected_old_result, actual_old_result
  fun_mirror = Debug.MakeMirror(fun)
  scope = fun_mirror.scope(scope_number)
  scope.setVariableValue variable_name, new_value
  actual_new_result = fun()
  assertEquals expected_new_result, actual_new_result
  return
ClosureTestCase = (scope_index, old_result, variable_name, new_value, new_result, success_expected, factory) ->
  @scope_index_ = scope_index
  @old_result_ = old_result
  @variable_name_ = variable_name
  @new_value_ = new_value
  @new_result_ = new_result
  @success_expected_ = success_expected
  @factory_ = factory
  return
Debug = debug.Debug
ClosureTestCase::run_pause_test = ->
  th = this
  fun = @factory_(true)
  @run_and_catch_ ->
    RunPauseTest th.scope_index_ + 1, th.old_result_, th.variable_name_, th.new_value_, th.new_result_, fun
    return

  return

ClosureTestCase::run_closure_test = ->
  th = this
  fun = @factory_(false)
  @run_and_catch_ ->
    RunClosureTest th.scope_index_, th.old_result_, th.variable_name_, th.new_value_, th.new_result_, fun
    return

  return

ClosureTestCase::run_and_catch_ = (runnable) ->
  if @success_expected_
    runnable()
  else
    assertThrows runnable
  return


# Test scopes visible from closures.
closure_test_cases = [
  new ClosureTestCase(0, "cat", "v1", 5, 5, true, Factory = (debug_stop) ->
    v1 = "cat"
    ->
      debugger  if debug_stop
      v1
  )
  new ClosureTestCase(0, 4, "t", 7, 9, true, Factory = (debug_stop) ->
    t = 2
    r = eval("t")
    ->
      debugger  if debug_stop
      r + t
  )
  new ClosureTestCase(0, 6, "t", 10, 13, true, Factory = (debug_stop) ->
    t = 2
    r = eval("t = 3")
    ->
      debugger  if debug_stop
      r + t
  )
  new ClosureTestCase(0, 17, "s", "Bird", "Bird", true, Factory = (debug_stop) ->
    eval "var s = 17"
    ->
      debugger  if debug_stop
      s
  )
  new ClosureTestCase(2, "capybara", "foo", 77, 77, true, Factory = (debug_stop) ->
    foo = "capybara"
    (->
      bar = "fish"
      try
        throw name: "test exception"
      catch e
        return ->
          debugger  if debug_stop
          bar = "beast"
          foo
      return
    )()
  )
  new ClosureTestCase(0, "AlphaBeta", "eee", 5, "5Beta", true, Factory = (debug_stop) ->
    foo = "Beta"
    (->
      bar = "fish"
      try
        throw "Alpha"
      catch eee
        return ->
          debugger  if debug_stop
          eee + foo
      return
    )()
  )
]
i = 0

while i < closure_test_cases.length
  closure_test_cases[i].run_pause_test()
  i++
i = 0

while i < closure_test_cases.length
  closure_test_cases[i].run_closure_test()
  i++

# Test local scope.
RunPauseTest 0, "HelloYou", "u", "We", "HelloWe", (Factory = ->
  ->
    u = "You"
    v = "Hello"
    debugger
    v + u
)()
RunPauseTest 0, "Helloworld", "p", "GoodBye", "HelloGoodBye", (Factory = ->
  H = (p) ->
    v = "Hello"
    debugger
    v + p
  ->
    H "world"
)()
RunPauseTest 0, "mouse", "v1", "dog", "dog", (Factory = ->
  ->
    v1 = "cat"
    eval "v1 = 'mouse'"
    debugger
    v1
)()
RunPauseTest 0, "mouse", "v1", "dog", "dog", (Factory = ->
  ->
    eval "var v1 = 'mouse'"
    debugger
    v1
)()

# Check that we correctly update local variable that
# is referenced from an inner closure.
RunPauseTest 0, "Blue", "v", "Green", "Green", (Factory = ->
  ->
    A = ->
      Inner = ->
        undefined
      v = "Blue"
      debugger
      v
    A()
)()

# Check that we correctly update parameter, that is known to be stored
# both on stack and in heap.
RunPauseTest 0, 5, "p", 2012, 2012, (Factory = ->
  ->
    A = (p) ->
      Inner = ->
        undefined
      debugger
      p
    A 5
)()

# Test value description protocol JSON
assertEquals true, Debug.TestApi.CommandProcessorResolveValue(value: true)
assertSame null, Debug.TestApi.CommandProcessorResolveValue(type: "null")
assertSame `undefined`, Debug.TestApi.CommandProcessorResolveValue(type: "undefined")
assertSame "123", Debug.TestApi.CommandProcessorResolveValue(
  type: "string"
  stringDescription: "123"
)
assertSame 123, Debug.TestApi.CommandProcessorResolveValue(
  type: "number"
  stringDescription: "123"
)
assertSame Number, Debug.TestApi.CommandProcessorResolveValue(handle: Debug.MakeMirror(Number).handle())
assertSame RunClosureTest, Debug.TestApi.CommandProcessorResolveValue(handle: Debug.MakeMirror(RunClosureTest).handle())
