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
MjsUnitAssertionError = (message) ->
  @message = message
  
  # This allows fetching the stack trace using TryCatch::StackTrace.
  @stack = new Error("").stack
  return

#
# * This file is included in all mini jsunit test cases.  The test
# * framework expects lines that signal failed tests to start with
# * the f-word and ignore all other lines.
# 
MjsUnitAssertionError::toString = ->
  @message


# Expected and found values the same objects, or the same primitive
# values.
# For known primitive values, please use assertEquals.
assertSame = undefined

# Expected and found values are identical primitive values or functions
# or similarly structured objects (checking internal properties
# of, e.g., Number and Date objects, the elements of arrays
# and the properties of non-Array objects).
assertEquals = undefined

# The difference between expected and found value is within certain tolerance.
assertEqualsDelta = undefined

# The found object is an Array with the same length and elements
# as the expected object. The expected object doesn't need to be an Array,
# as long as it's "array-ish".
assertArrayEquals = undefined

# The found object must have the same enumerable properties as the
# expected object. The type of object isn't checked.
assertPropertiesEqual = undefined

# Assert that the string conversion of the found value is equal to
# the expected string. Only kept for backwards compatability, please
# check the real structure of the found value.
assertToStringEquals = undefined

# Checks that the found value is true. Use with boolean expressions
# for tests that doesn't have their own assertXXX function.
assertTrue = undefined

# Checks that the found value is false.
assertFalse = undefined

# Checks that the found value is null. Kept for historical compatibility,
# please just use assertEquals(null, expected).
assertNull = undefined

# Checks that the found value is *not* null.
assertNotNull = undefined

# Assert that the passed function or eval code throws an exception.
# The optional second argument is an exception constructor that the
# thrown exception is checked against with "instanceof".
# The optional third argument is a message type string that is compared
# to the type property on the thrown exception.
assertThrows = undefined

# Assert that the passed function or eval code does not throw an exception.
assertDoesNotThrow = undefined

# Asserts that the found value is an instance of the constructor passed
# as the second argument.
assertInstanceof = undefined

# Assert that this code is never executed (i.e., always fails if executed).
assertUnreachable = undefined

# Assert that the function code is (not) optimized.  If "no sync" is passed
# as second argument, we do not wait for the concurrent optimization thread to
# finish when polling for optimization status.
# Only works with --allow-natives-syntax.
assertOptimized = undefined
assertUnoptimized = undefined
(-> # Scope for utility functions.
  classOf = (object) ->
    
    # Argument must not be null or undefined.
    string = Object::toString.call(object)
    
    # String has format [object <ClassName>].
    string.substring 8, string.length - 1
  PrettyPrint = (value) ->
    switch typeof value
      when "string"
        JSON.stringify value
      when "number"
        "-0"  if value is 0 and (1 / value) < 0
      
      # FALLTHROUGH.
      when "boolean", "undefined", "function"
        String value
      when "object"
        return "null"  if value is null
        objectClass = classOf(value)
        switch objectClass
          when "Number", "String", "Boolean", "Date"
            return objectClass + "(" + PrettyPrint(value.valueOf()) + ")"
          when "RegExp"
            return value.toString()
          when "Array"
            return "[" + value.map(PrettyPrintArrayElement).join(",") + "]"
          when "Object"
          else
            return objectClass + "()"
        
        # [[Class]] is "Object".
        name = value.constructor.name
        return name + "()"  if name
        "Object()"
      else
        "-- unknown value --"
  PrettyPrintArrayElement = (value, index, array) ->
    return ""  if value is `undefined` and (index not of array)
    PrettyPrint value
  fail = (expectedText, found, name_opt) ->
    message = "Fail" + "ure"
    
    # Fix this when we ditch the old test runner.
    message += " (" + name_opt + ")"  if name_opt
    message += ": expected <" + expectedText + "> found <" + PrettyPrint(found) + ">"
    throw new MjsUnitAssertionError(message)return
  deepObjectEquals = (a, b) ->
    aProps = Object.keys(a)
    aProps.sort()
    bProps = Object.keys(b)
    bProps.sort()
    return false  unless deepEquals(aProps, bProps)
    i = 0

    while i < aProps.length
      return false  unless deepEquals(a[aProps[i]], b[aProps[i]])
      i++
    true
  deepEquals = (a, b) ->
    if a is b
      
      # Check for -0.
      return (1 / a) is (1 / b)  if a is 0
      return true
    return false  unless typeof a is typeof b
    return isNaN(a) and isNaN(b)  if typeof a is "number"
    return false  if typeof a isnt "object" and typeof a isnt "function"
    
    # Neither a nor b is primitive.
    objectClass = classOf(a)
    return false  if objectClass isnt classOf(b)
    
    # For RegExp, just compare pattern and flags using its toString.
    return (a.toString() is b.toString())  if objectClass is "RegExp"
    
    # Functions are only identical to themselves.
    return false  if objectClass is "Function"
    if objectClass is "Array"
      elementCount = 0
      return false  unless a.length is b.length
      i = 0

      while i < a.length
        return false  unless deepEquals(a[i], b[i])
        i++
      return true
    return false  if a.valueOf() isnt b.valueOf()  if objectClass is "String" or objectClass is "Number" or objectClass is "Boolean" or objectClass is "Date"
    deepObjectEquals a, b
  checkArity = (args, arity, name) ->
    fail PrettyPrint(arity), args.length, name + " requires " + arity + " or more arguments"  if args.length < arity
    return
  assertSame = assertSame = (expected, found, name_opt) ->
    checkArity arguments, 2, "assertSame"
    
    # TODO(mstarzinger): We should think about using Harmony's egal operator
    # or the function equivalent Object.is() here.
    if found is expected
      return  if expected isnt 0 or (1 / expected) is (1 / found)
    else return  if (expected isnt expected) and (found isnt found)
    fail PrettyPrint(expected), found, name_opt
    return

  assertEquals = assertEquals = (expected, found, name_opt) ->
    checkArity arguments, 2, "assertEquals"
    fail PrettyPrint(expected), found, name_opt  unless deepEquals(found, expected)
    return

  assertEqualsDelta = assertEqualsDelta = (expected, found, delta, name_opt) ->
    assertTrue Math.abs(expected - found) <= delta, name_opt
    return

  assertArrayEquals = assertArrayEquals = (expected, found, name_opt) ->
    start = ""
    start = name_opt + " - "  if name_opt
    assertEquals expected.length, found.length, start + "array length"
    if expected.length is found.length
      i = 0

      while i < expected.length
        assertEquals expected[i], found[i], start + "array element at index " + i
        ++i
    return

  assertPropertiesEqual = assertPropertiesEqual = (expected, found, name_opt) ->
    
    # Check properties only.
    fail expected, found, name_opt  unless deepObjectEquals(expected, found)
    return

  assertToStringEquals = assertToStringEquals = (expected, found, name_opt) ->
    fail expected, found, name_opt  unless expected is String(found)
    return

  assertTrue = assertTrue = (value, name_opt) ->
    assertEquals true, value, name_opt
    return

  assertFalse = assertFalse = (value, name_opt) ->
    assertEquals false, value, name_opt
    return

  assertNull = assertNull = (value, name_opt) ->
    fail "null", value, name_opt  if value isnt null
    return

  assertNotNull = assertNotNull = (value, name_opt) ->
    fail "not null", value, name_opt  if value is null
    return

  assertThrows = assertThrows = (code, type_opt, cause_opt) ->
    threwException = true
    try
      if typeof code is "function"
        code()
      else
        eval code
      threwException = false
    catch e
      assertInstanceof e, type_opt  if typeof type_opt is "function"
      assertEquals e.type, cause_opt  if arguments.length >= 3
      
      # Success.
      return
    throw new MjsUnitAssertionError("Did not throw exception")return

  assertInstanceof = assertInstanceof = (obj, type) ->
    unless obj instanceof type
      actualTypeName = null
      actualConstructor = Object.getPrototypeOf(obj).constructor
      actualTypeName = actualConstructor.name or String(actualConstructor)  if typeof actualConstructor is "function"
      fail "Object <" + PrettyPrint(obj) + "> is not an instance of <" + (type.name or type) + ">" + ((if actualTypeName then " but of < " + actualTypeName + ">" else ""))
    return

  assertDoesNotThrow = assertDoesNotThrow = (code, name_opt) ->
    try
      if typeof code is "function"
        code()
      else
        eval code
    catch e
      fail "threw an exception: ", e.message or e, name_opt
    return

  assertUnreachable = assertUnreachable = (name_opt) ->
    
    # Fix this when we ditch the old test runner.
    message = "Fail" + "ure: unreachable"
    message += " - " + name_opt  if name_opt
    throw new MjsUnitAssertionError(message)return

  OptimizationStatusImpl = `undefined`
  OptimizationStatus = (fun, sync_opt) ->
    if OptimizationStatusImpl is `undefined`
      try
        OptimizationStatusImpl = new Function("fun", "sync", "return %GetOptimizationStatus(fun, sync);")
      catch e
        throw new Error("natives syntax not allowed")
    OptimizationStatusImpl fun, sync_opt

  assertUnoptimized = assertUnoptimized = (fun, sync_opt, name_opt) ->
    sync_opt = ""  if sync_opt is `undefined`
    assertTrue OptimizationStatus(fun, sync_opt) isnt 1, name_opt
    return

  assertOptimized = assertOptimized = (fun, sync_opt, name_opt) ->
    sync_opt = ""  if sync_opt is `undefined`
    assertTrue OptimizationStatus(fun, sync_opt) isnt 2, name_opt
    return

  return
)()
