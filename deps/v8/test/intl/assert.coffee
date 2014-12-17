# Copyright 2013 the V8 project authors. All rights reserved.
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

# Some methods are taken from v8/test/mjsunit/mjsunit.js

###*
Compares two objects for key/value equality.
Returns true if they are equal, false otherwise.
###
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

###*
Compares two JavaScript values for type and value equality.
It checks internals of arrays and objects.
###
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

###*
Throws an exception, and prints the values in case of error.
###
fail = (expected, found) ->
  
  # TODO(cira): Replace String with PrettyPrint for objects and arrays.
  message = "Failure: expected <" + String(expected) + ">, found <" + String(found) + ">."
  throw new Error(message)return

###*
Throws if two variables have different types or values.
###
assertEquals = (expected, found) ->
  fail expected, found  unless deepEquals(expected, found)
  return

###*
Throws if value is false.
###
assertTrue = (value) ->
  assertEquals true, value
  return

###*
Throws if value is true.
###
assertFalse = (value) ->
  assertEquals false, value
  return

###*
Returns true if code throws specified exception.
###
assertThrows = (code, type_opt, cause_opt) ->
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
  throw new Error("Did not throw exception")return

###*
Throws an exception if code throws.
###
assertDoesNotThrow = (code, name_opt) ->
  try
    if typeof code is "function"
      code()
    else
      eval code
  catch e
    fail "threw an exception: ", e.message or e, name_opt
  return

###*
Throws if obj is not of given type.
###
assertInstanceof = (obj, type) ->
  unless obj instanceof type
    actualTypeName = null
    actualConstructor = Object.prototypeOf(obj).constructor
    actualTypeName = actualConstructor.name or String(actualConstructor)  if typeof actualConstructor is "function"
    throw new Error("Object <" + obj + "> is not an instance of <" + (type.name or type) + ">" + ((if actualTypeName then " but of < " + actualTypeName + ">" else "")))
  return
