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

# Simple debug event handler which first time will cause 'step in' action
# to get into g.call and than check that execution is pauesed inside
# function 'g'.
listener = (event, exec_state, event_data, data) ->
  try
    if event is Debug.DebugEvent.Break
      if state is 0
        
        # Step into f2.call:
        exec_state.prepareStep Debug.StepAction.StepIn, 2
        state = 2
      else if state is 2
        assertEquals "g", event_data.func().name()
        assertEquals "  return t + 1; // expected line", event_data.sourceLineText()
        state = 3
  catch e
    exception = e
  return

# Add the debug event listener.

# Sample functions.
g = (t) ->
  t + 1 # expected line

# Test step into function call from a function without local variables.
call1 = ->
  debugger
  g.call null, 3
  return

# Test step into function call from a function with some local variables.
call2 = ->
  aLocalVar = "test"
  anotherLocalVar = g(aLocalVar) + "s"
  yetAnotherLocal = 10
  debugger
  g.call null, 3
  return

# Test step into function call which is a part of an expression.
call3 = ->
  alias = g
  debugger
  r = 10 + alias.call(null, 3)
  aLocalVar = "test"
  anotherLocalVar = g(aLocalVar) + "s"
  yetAnotherLocal = 10
  return

# Test step into function call from a function with some local variables.
call4 = ->
  alias = g
  debugger
  alias.call null, 3
  aLocalVar = "test"
  anotherLocalVar = g(aLocalVar) + "s"
  yetAnotherLocal = 10
  return

# Test step into function apply from a function without local variables.
apply1 = ->
  debugger
  g.apply null, [3]
  return

# Test step into function apply from a function with some local variables.
apply2 = ->
  aLocalVar = "test"
  anotherLocalVar = g(aLocalVar) + "s"
  yetAnotherLocal = 10
  debugger
  g.apply null, [
    3
    4
  ]
  return

# Test step into function apply which is a part of an expression.
apply3 = ->
  alias = g
  debugger
  r = 10 + alias.apply(null, [
    3
    "unused arg"
  ])
  aLocalVar = "test"
  anotherLocalVar = g(aLocalVar) + "s"
  yetAnotherLocal = 10
  return

# Test step into function apply from a function with some local variables.
apply4 = ->
  alias = g
  debugger
  alias.apply null, [3]
  aLocalVar = "test"
  anotherLocalVar = g(aLocalVar) + "s"
  yetAnotherLocal = 10
  return

# Test step into bound function.
bind1 = ->
  bound = g.bind(null, 3)
  debugger
  bound()
  return

# Test step into apply of bound function.
applyAndBind1 = ->
  bound = g.bind(null, 3)
  debugger
  bound.apply null, [3]
  aLocalVar = "test"
  anotherLocalVar = g(aLocalVar) + "s"
  yetAnotherLocal = 10
  return
Debug = debug.Debug
exception = null
state = 0
Debug.setListener listener
testFunctions = [
  call1
  call2
  call3
  call4
  apply1
  apply2
  apply3
  apply4
  bind1
  applyAndBind1
]
i = 0

while i < testFunctions.length
  state = 0
  testFunctions[i]()
  assertNull exception
  assertEquals 3, state
  i++

# Test global bound function.
state = 0
globalBound = g.bind(null, 3)
debugger
globalBound()
assertNull exception
assertEquals 3, state

# Get rid of the debug event listener.
Debug.setListener null
