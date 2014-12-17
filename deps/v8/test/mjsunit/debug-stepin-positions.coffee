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

# Flags: --expose-debug-as debug --nocrankshaft
# Get the Debug object exposed from the debug context global object.
DebuggerStatement = ->
  debugger #pause
  return
TestCase = (fun, frame_number) ->
  listener = (event, exec_state, event_data, data) ->
    assertHasLineMark = (mark, frame) ->
      line = frame.sourceLineText()
      throw new Error("Line " + line + " should contain mark " + mark)  unless mark.exec(frame.sourceLineText())
      return
    try
      if event is Debug.DebugEvent.Break or event is Debug.DebugEvent.Exception
        return  if step++ > 0
        assertHasLineMark /pause/, exec_state.frame(0)
        assertHasLineMark /positions/, exec_state.frame(frame_number)
        frame = exec_state.frame(frame_number)
        codeSnippet = frame.sourceLineText()
        resultPositions = frame.stepInPositions()
    catch e
      exception = e
    return
  replaceStringRange = (s, pos, substitute) ->
    s.substring(0, pos) + substitute + s.substring(pos + substitute.length)
  exception = false
  codeSnippet = `undefined`
  resultPositions = `undefined`
  step = 0
  Debug.setListener listener
  fun()
  Debug.setListener null
  assertTrue not exception, exception
  expectedPositions = {}
  markPattern = new RegExp("/\\*#\\*/", "g")
  matchResult = undefined
  expectedPositions[matchResult.index] = true  while (matchResult = markPattern.exec(codeSnippet))
  print codeSnippet
  decoratedResult = codeSnippet
  markLength = 5
  unexpectedPositionFound = false
  i = 0

  while i < resultPositions.length
    col = resultPositions[i].position.column - markLength
    if expectedPositions[col]
      delete expectedPositions[col]

      decoratedResult = replaceStringRange(decoratedResult, col, "*YES*")
    else
      decoratedResult = replaceStringRange(decoratedResult, col, "!BAD!")
      unexpectedPositionFound = true
    i++
  print decoratedResult
  for n of expectedPositions
    assertTrue false, "Some positions are not reported: " + decoratedResult
    break
  assertFalse unexpectedPositionFound, "Found unexpected position: " + decoratedResult
  return
TestCaseWithDebugger = (fun) ->
  TestCase fun, 1
  return
TestCaseWithBreakpoint = (fun, line_number, frame_number) ->
  breakpointId = Debug.setBreakPoint(fun, line_number)
  TestCase fun, frame_number
  Debug.clearBreakPoint breakpointId
  return
TestCaseWithException = (fun, frame_number) ->
  Debug.setBreakOnException()
  TestCase fun, frame_number
  Debug.clearBreakOnException()
  return
Debug = debug.Debug

# Test cases.

# Step in position, when the function call that we are standing at is already
# being executed.
fun = ->
  g = (p) ->
    throw String(p)return #pause
  try
    res = [ ##
#positions
      g(1)
      g(2)
    ]
  return

TestCaseWithBreakpoint fun, 2, 1
TestCaseWithException fun, 1

# Step in position, when the function call that we are standing at is raising
# an exception.
fun = ->
  o = g: (p) ->
    throw preturn

  try
    res = [ ##
##
#pause, positions
      f(1)
      g(2)
    ]
  return

TestCaseWithException fun, 0

# Step-in position, when already paused almost on the first call site.
fun = ->
  g = (p) ->
    throw preturn
  try
    res = [ ##
##
#pause, positions
      g(Math.rand)
      g(2)
    ]
  return

TestCaseWithBreakpoint fun, 5, 0

# Step-in position, when already paused on the first call site.
fun = ->
  g = ->
    throw "Debug"return
  try
    res = [ ##
##
#pause, positions
      g()
      g()
    ]
  return

TestCaseWithBreakpoint fun, 5, 0

# Method calls.
fun = ->
  data = a: ->

  res = [ ##
##
##
##
#positions
    DebuggerStatement()
    data.a()
    data[String("a")]()
    data["a"]()
    data.a
    data["a"]
  ]
  return

TestCaseWithDebugger fun

# Function call on a value.
fun = ->
  g = (p) ->
    g
  res = [ ##
##
##
##
##
##
#positions
    DebuggerStatement()
    g(2)
    g(2)(3)
    g(0)(0)(g)
  ]
  return

TestCaseWithDebugger fun

# Local function call, closure function call,
# local function construction call.
fun = ((p) ->
  ->
    f = (a, b) ->
    res = f(DebuggerStatement(), p(new f())) ##
##
##
#positions
    return
)(Object)
TestCaseWithDebugger fun

# Global function, global object construction, calls before pause point.
fun = ((p) ->
  ->
    res = [ ##
##
##
#positions
      Math.abs(new Object())
      DebuggerStatement()
      Math.abs(4)
      new Object().toString()
    ]
    return
)(Object)
TestCaseWithDebugger fun
