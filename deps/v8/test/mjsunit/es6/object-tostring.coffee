# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --harmony-tostring
testToStringTag = (className) ->
  
  # Using builtin toStringTags
  obj = {}
  obj[Symbol.toStringTag] = className
  assertEquals "[object ~" + className + "]", Object::toString.call(obj)
  
  # Getter throws
  obj = {}
  Object.defineProperty obj, Symbol.toStringTag,
    get: ->
      throw classNamereturn

  assertThrows (->
    Object::toString.call obj
    return
  ), className
  
  # Getter does not throw
  obj = {}
  Object.defineProperty obj, Symbol.toStringTag,
    get: ->
      className

  assertEquals "[object ~" + className + "]", Object::toString.call(obj)
  
  # Custom, non-builtin toStringTags
  obj = {}
  obj[Symbol.toStringTag] = "X" + className
  assertEquals "[object X" + className + "]", Object::toString.call(obj)
  
  # With getter
  obj = {}
  Object.defineProperty obj, Symbol.toStringTag,
    get: ->
      "X" + className

  assertEquals "[object X" + className + "]", Object::toString.call(obj)
  
  # Undefined toStringTag should return [object className]
  obj = (if className is "Arguments" then (->
    arguments
  )() else new global[className])
  obj[Symbol.toStringTag] = `undefined`
  assertEquals "[object " + className + "]", Object::toString.call(obj)
  
  # With getter
  obj = (if className is "Arguments" then (->
    arguments
  )() else new global[className])
  Object.defineProperty obj, Symbol.toStringTag,
    get: ->
      `undefined`

  assertEquals "[object " + className + "]", Object::toString.call(obj)
  return
testToStringTagNonString = (value) ->
  obj = {}
  obj[Symbol.toStringTag] = value
  assertEquals "[object ???]", Object::toString.call(obj)
  
  # With getter
  obj = {}
  Object.defineProperty obj, Symbol.toStringTag,
    get: ->
      value

  assertEquals "[object ???]", Object::toString.call(obj)
  return
testObjectToStringPropertyDesc = ->
  desc = Object.getOwnPropertyDescriptor(Object::, "toString")
  assertTrue desc.writable
  assertFalse desc.enumerable
  assertTrue desc.configurable
  return
global = this
funs =
  Object: [Object]
  Function: [Function]
  Array: [Array]
  String: [String]
  Boolean: [Boolean]
  Number: [Number]
  Date: [Date]
  RegExp: [RegExp]
  Error: [
    Error
    TypeError
    RangeError
    SyntaxError
    ReferenceError
    EvalError
    URIError
  ]

for f of funs
  for i of funs[f]
    assertEquals "[object " + f + "]", Object::toString.call(new funs[f][i]), funs[f][i]
    assertEquals "[object Function]", Object::toString.call(funs[f][i]), funs[f][i]
[
  "Arguments"
  "Array"
  "Boolean"
  "Date"
  "Error"
  "Function"
  "Number"
  "RegExp"
  "String"
].forEach testToStringTag
[
  null
  ->
  []
  {
    {}
  }
  /regexp/
  42
  Symbol("sym")
  new Date()
  (->
    arguments
  )()
  true
  new Error("oops")
  new String("str")
].forEach testToStringTagNonString
testObjectToStringPropertyDesc()
