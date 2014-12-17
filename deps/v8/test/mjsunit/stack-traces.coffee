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
testMethodNameInference = ->
  Foo = ->
  Foo::bar = ->
    FAIL
    return

  (new Foo).bar()
  return
testNested = ->
  one = ->
    two = ->
      three = ->
        FAIL
        return
      three()
      return
    two()
    return
  one()
  return
testArrayNative = ->
  [
    1
    2
    3
  ].map ->
    FAIL
    return

  return
testImplicitConversion = ->
  Nirk = ->
  Nirk::valueOf = ->
    FAIL
    return

  1 + (new Nirk)
testEval = ->
  eval "function Doo() { FAIL; }; Doo();"
  return
testNestedEval = ->
  x = "FAIL"
  eval "function Outer() { eval('function Inner() { eval(x); }'); Inner(); }; Outer();"
  return
testEvalWithSourceURL = ->
  eval "function Doo() { FAIL; }; Doo();\n//# sourceURL=res://name"
  return
testNestedEvalWithSourceURL = ->
  x = "FAIL"
  innerEval = "function Inner() { eval(x); }\n//@ sourceURL=res://inner-eval"
  eval "function Outer() { eval(innerEval); Inner(); }; Outer();\n//# sourceURL=res://outer-eval"
  return
testValue = ->
  Number::causeError = ->
    FAIL
    return

  (1).causeError()
  return
testConstructor = ->
  Plonk = ->
    FAIL
    return
  new Plonk()
  return
testRenamedMethod = ->
  a$b$c$d = ->
    FAIL
  Wookie = ->
  Wookie::d = a$b$c$d
  (new Wookie).d()
  return
testAnonymousMethod = ->
  (->
    FAIL
    return
  ).call [
    1
    2
    3
  ]
  return
CustomError = (message, stripPoint) ->
  @message = message
  Error.captureStackTrace this, stripPoint
  return
testDefaultCustomError = ->
  throw new CustomError("hep-hey", `undefined`)return
testStrippedCustomError = ->
  throw new CustomError("hep-hey", CustomError)return
testClassNames = ->
  (new MyObjCreator).Create()
  return

# Utility function for testing that the expected strings occur
# in the stack trace produced when running the given function.
testTrace = (name, fun, expected, unexpected) ->
  threw = false
  try
    fun()
  catch e
    i = 0

    while i < expected.length
      assertTrue e.stack.indexOf(expected[i]) isnt -1, name + " doesn't contain expected[" + i + "] stack = " + e.stack
      i++
    if unexpected
      i = 0

      while i < unexpected.length
        assertEquals e.stack.indexOf(unexpected[i]), -1, name + " contains unexpected[" + i + "]"
        i++
    threw = true
  assertTrue threw, name + " didn't throw"
  return

# Test that the error constructor is not shown in the trace
testCallerCensorship = ->
  threw = false
  try
    FAIL
  catch e
    assertEquals -1, e.stack.indexOf("at new ReferenceError"), "CallerCensorship contained new ReferenceError"
    threw = true
  assertTrue threw, "CallerCensorship didn't throw"
  return

# Test that the explicit constructor call is shown in the trace
testUnintendedCallerCensorship = ->
  threw = false
  try
    new ReferenceError(toString: ->
      FAIL
      return
    )
  catch e
    assertTrue e.stack.indexOf("at new ReferenceError") isnt -1, "UnintendedCallerCensorship didn't contain new ReferenceError"
    threw = true
  assertTrue threw, "UnintendedCallerCensorship didn't throw"
  return

# If an error occurs while the stack trace is being formatted it should
# be handled gracefully.
testErrorsDuringFormatting = ->
  Nasty = ->
  Nasty::foo = ->
    throw new RangeError()return

  n = new Nasty()
  n.__defineGetter__ "constructor", ->
    CONS_FAIL
    return

  threw = false
  try
    n.foo()
  catch e
    threw = true
    assertTrue e.stack.indexOf("<error: ReferenceError") isnt -1, "ErrorsDuringFormatting didn't contain error: ReferenceError"
  assertTrue threw, "ErrorsDuringFormatting didn't throw"
  threw = false
  
  # Now we can't even format the message saying that we couldn't format
  # the stack frame.  Put that in your pipe and smoke it!
  ReferenceError::toString = ->
    NESTED_FAIL
    return

  try
    n.foo()
  catch e
    threw = true
    assertTrue e.stack.indexOf("<error>") isnt -1, "ErrorsDuringFormatting didn't contain <error>"
  assertTrue threw, "ErrorsDuringFormatting didnt' throw (2)"
  return

# Poisonous object that throws a reference error if attempted converted to
# a primitive values.

# Tests that a native constructor function is included in the
# stack trace.
testTraceNativeConstructor = (nativeFunc) ->
  nativeFuncName = nativeFunc.name
  try
    new nativeFunc(thrower)
    assertUnreachable nativeFuncName
  catch e
    assertTrue e.stack.indexOf(nativeFuncName) >= 0, nativeFuncName
  return

# Tests that a native conversion function is included in the
# stack trace.
testTraceNativeConversion = (nativeFunc) ->
  nativeFuncName = nativeFunc.name
  try
    nativeFunc thrower
    assertUnreachable nativeFuncName
  catch e
    assertTrue e.stack.indexOf(nativeFuncName) >= 0, nativeFuncName
  return
testOmittedBuiltin = (throwing, omitted) ->
  try
    throwing()
    assertUnreachable omitted
  catch e
    assertTrue e.stack.indexOf(omitted) < 0, omitted
  return
CustomError::toString = ->
  "CustomError: " + @message

MyObj = ->
  FAIL
  return

MyObjCreator = ->

MyObjCreator::Create = ->
  new MyObj()

thrower =
  valueOf: ->
    FAIL
    return

  toString: ->
    FAIL
    return

testTrace "testArrayNative", testArrayNative, ["Array.map (native)"]
testTrace "testNested", testNested, [
  "at one"
  "at two"
  "at three"
]
testTrace "testMethodNameInference", testMethodNameInference, ["at Foo.bar"]
testTrace "testImplicitConversion", testImplicitConversion, ["at Nirk.valueOf"]
testTrace "testEval", testEval, ["at Doo (eval at testEval"]
testTrace "testNestedEval", testNestedEval, ["eval at Inner (eval at Outer"]
testTrace "testEvalWithSourceURL", testEvalWithSourceURL, ["at Doo (res://name:1:18)"]
testTrace "testNestedEvalWithSourceURL", testNestedEvalWithSourceURL, [
  " at Inner (res://inner-eval:1:20)"
  " at Outer (res://outer-eval:1:37)"
]
testTrace "testValue", testValue, ["at Number.causeError"]
testTrace "testConstructor", testConstructor, ["new Plonk"]
testTrace "testRenamedMethod", testRenamedMethod, ["Wookie.a$b$c$d [as d]"]
testTrace "testAnonymousMethod", testAnonymousMethod, ["Array.<anonymous>"]
testTrace "testDefaultCustomError", testDefaultCustomError, [
  "hep-hey"
  "new CustomError"
], ["collectStackTrace"]
testTrace "testStrippedCustomError", testStrippedCustomError, ["hep-hey"], [
  "new CustomError"
  "collectStackTrace"
]
testTrace "testClassNames", testClassNames, [
  "new MyObj"
  "MyObjCreator.Create"
], ["as Create"]
testCallerCensorship()
testUnintendedCallerCensorship()
testErrorsDuringFormatting()
testTraceNativeConversion String # Does ToString on argument.
testTraceNativeConversion Number # Does ToNumber on argument.
testTraceNativeConversion RegExp # Does ToString on argument.
testTraceNativeConstructor String # Does ToString on argument.
testTraceNativeConstructor Number # Does ToNumber on argument.
testTraceNativeConstructor RegExp # Does ToString on argument.
testTraceNativeConstructor Date # Does ToNumber on argument.

# Omitted because QuickSort has builtins object as receiver, and is non-native
# builtin.
testOmittedBuiltin (->
  [
    thrower
    2
  ].sort (a, b) ->
    (b < a) - (a < b)
    return

  return
), "QuickSort"

# Omitted because ADD from runtime.js is non-native builtin.
testOmittedBuiltin (->
  thrower + 2
  return
), "ADD"
error = new Error()
error.toString = ->
  assertUnreachable()
  return

error.stack
error = new Error()
error.name = toString: ->
  assertUnreachable()
  return

error.message = toString: ->
  assertUnreachable()
  return

error.stack
error = new Error()
Array::push = (x) ->
  assertUnreachable()
  return

Array::join = (x) ->
  assertUnreachable()
  return

error.stack
fired = false
error = new Error(toString: ->
  fired = true
  return
)
assertTrue fired
error.stack
assertTrue fired

# Check that throwing exception in a custom stack trace formatting function
# does not lead to recursion.
Error.prepareStackTrace = ->
  throw new Error("abc")return

message = undefined
try
  try
    throw new Error()
  catch e
    e.stack
catch e
  message = e.message
assertEquals "abc", message

# Test that modifying Error.prepareStackTrace by itself works.
Error.prepareStackTrace = ->
  Error.prepareStackTrace = "custom"
  return

new Error().stack
assertEquals "custom", Error.prepareStackTrace

# Check that the formatted stack trace can be set to undefined.
error = new Error()
error.stack = `undefined`
assertEquals `undefined`, error.stack

# Check that the stack trace accessors are not forcibly set.
my_error = {}
Object.freeze my_error
assertThrows ->
  Error.captureStackTrace my_error
  return

my_error = {}
Object.preventExtensions my_error
assertThrows ->
  Error.captureStackTrace my_error
  return

fake_error = {}
my_error = new Error()
stolen_getter = Object.getOwnPropertyDescriptor(my_error, "stack").get
Object.defineProperty fake_error, "stack",
  get: stolen_getter

assertEquals `undefined`, fake_error.stack
