# http://wiki.commonjs.org/wiki/Unit_Testing/1.0
#
# THIS IS NOT TESTED NOR LIKELY TO WORK OUTSIDE V8!
#
# Originally from narwhal.js (http://narwhaljs.org)
# Copyright (c) 2009 Thomas Robinson <280north.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# UTILITY

# 1. The assert module provides functions that throw
# AssertionError's when particular conditions are not met. The
# assert module must conform to the following interface.

# 2. The AssertionError is defined in assert.
# new assert.AssertionError({ message: message,
#                             actual: actual,
#                             expected: expected })

# assert.AssertionError instanceof Error
replacer = (key, value) ->
  return "" + value  if util.isUndefined(value)
  return value.toString()  if util.isNumber(value) and not isFinite(value)
  return value.toString()  if util.isFunction(value) or util.isRegExp(value)
  value
truncate = (s, n) ->
  if util.isString(s)
    (if s.length < n then s else s.slice(0, n))
  else
    s
getMessage = (self) ->
  truncate(JSON.stringify(self.actual, replacer), 128) + " " + self.operator + " " + truncate(JSON.stringify(self.expected, replacer), 128)

# At present only the three keys mentioned above are used and
# understood by the spec. Implementations or sub modules can pass
# other keys to the AssertionError's constructor - they will be
# ignored.

# 3. All of the following functions must throw an AssertionError
# when a corresponding condition is not met, with a message that
# may be undefined if not provided.  All assertion methods provide
# both the actual and expected values to the assertion error for
# display purposes.
fail = (actual, expected, message, operator, stackStartFunction) ->
  throw new assert.AssertionError(
    message: message
    actual: actual
    expected: expected
    operator: operator
    stackStartFunction: stackStartFunction
  )return

# EXTENSION! allows for well behaved errors defined elsewhere.

# 4. Pure assertion tests whether a value is truthy, as determined
# by !!guard.
# assert.ok(guard, message_opt);
# This statement is equivalent to assert.equal(true, !!guard,
# message_opt);. To test strictly for the value true, use
# assert.strictEqual(true, guard, message_opt);.
ok = (value, message) ->
  fail value, true, message, "==", assert.ok  unless value
  return

# 5. The equality assertion tests shallow, coercive equality with
# ==.
# assert.equal(actual, expected, message_opt);

# 6. The non-equality assertion tests for whether two objects are not equal
# with != assert.notEqual(actual, expected, message_opt);

# 7. The equivalence assertion tests a deep equality relation.
# assert.deepEqual(actual, expected, message_opt);
_deepEqual = (actual, expected) ->
  
  # 7.1. All identical values are equivalent, as determined by ===.
  if actual is expected
    true
  else if util.isBuffer(actual) and util.isBuffer(expected)
    return false  unless actual.length is expected.length
    i = 0

    while i < actual.length
      return false  if actual[i] isnt expected[i]
      i++
    true
  
  # 7.2. If the expected value is a Date object, the actual value is
  # equivalent if it is also a Date object that refers to the same time.
  else if util.isDate(actual) and util.isDate(expected)
    actual.getTime() is expected.getTime()
  
  # 7.3 If the expected value is a RegExp object, the actual value is
  # equivalent if it is also a RegExp object with the same source and
  # properties (`global`, `multiline`, `lastIndex`, `ignoreCase`).
  else if util.isRegExp(actual) and util.isRegExp(expected)
    actual.source is expected.source and actual.global is expected.global and actual.multiline is expected.multiline and actual.lastIndex is expected.lastIndex and actual.ignoreCase is expected.ignoreCase
  
  # 7.4. Other pairs that do not both pass typeof value == 'object',
  # equivalence is determined by ==.
  else if not util.isObject(actual) and not util.isObject(expected)
    actual is expected
  
  # 7.5 For all other Object pairs, including Array objects, equivalence is
  # determined by having the same number of owned properties (as verified
  # with Object.prototype.hasOwnProperty.call), the same set of keys
  # (although not necessarily the same order), equivalent values for every
  # corresponding key, and an identical 'prototype' property. Note: this
  # accounts for both named and indexed properties on Arrays.
  else
    objEquiv actual, expected
isArguments = (object) ->
  Object::toString.call(object) is "[object Arguments]"
objEquiv = (a, b) ->
  return false  if util.isNullOrUndefined(a) or util.isNullOrUndefined(b)
  
  # an identical 'prototype' property.
  return false  if a:: isnt b::
  
  #~~~I've managed to break Object.keys through screwy arguments passing.
  #   Converting to array solves the problem.
  aIsArgs = isArguments(a)
  bIsArgs = isArguments(b)
  return false  if (aIsArgs and not bIsArgs) or (not aIsArgs and bIsArgs)
  if aIsArgs
    a = pSlice.call(a)
    b = pSlice.call(b)
    return _deepEqual(a, b)
  try
    ka = Object.keys(a)
    kb = Object.keys(b)
    key = undefined
    i = undefined
  catch e #happens when one is a string literal and the other isn't
    return false
  
  # having the same number of owned properties (keys incorporates
  # hasOwnProperty)
  return false  unless ka.length is kb.length
  
  #the same set of keys (although not necessarily the same order),
  ka.sort()
  kb.sort()
  
  #~~~cheap key test
  i = ka.length - 1
  while i >= 0
    return false  unless ka[i] is kb[i]
    i--
  
  #equivalent values for every corresponding key, and
  #~~~possibly expensive deep test
  i = ka.length - 1
  while i >= 0
    key = ka[i]
    return false  unless _deepEqual(a[key], b[key])
    i--
  true

# 8. The non-equivalence assertion tests for any deep inequality.
# assert.notDeepEqual(actual, expected, message_opt);

# 9. The strict equality assertion tests strict equality, as determined by ===.
# assert.strictEqual(actual, expected, message_opt);

# 10. The strict non-equality assertion tests for strict inequality, as
# determined by !==.  assert.notStrictEqual(actual, expected, message_opt);
expectedException = (actual, expected) ->
  return false  if not actual or not expected
  if Object::toString.call(expected) is "[object RegExp]"
    return expected.test(actual)
  else if actual instanceof expected
    return true
  else return true  if expected.call({}, actual) is true
  false
_throws = (shouldThrow, block, expected, message) ->
  actual = undefined
  if util.isString(expected)
    message = expected
    expected = null
  try
    block()
  catch e
    actual = e
  message = ((if expected and expected.name then " (" + expected.name + ")." else ".")) + ((if message then " " + message else "."))
  fail actual, expected, "Missing expected exception" + message  if shouldThrow and not actual
  fail actual, expected, "Got unwanted exception" + message  if not shouldThrow and expectedException(actual, expected)
  throw actual  if (shouldThrow and actual and expected and not expectedException(actual, expected)) or (not shouldThrow and actual)
  return
"use strict"
util = require("util")
pSlice = Array::slice
assert = module.exports = ok
assert.AssertionError = AssertionError = (options) ->
  @name = "AssertionError"
  @actual = options.actual
  @expected = options.expected
  @operator = options.operator
  if options.message
    @message = options.message
    @generatedMessage = false
  else
    @message = getMessage(this)
    @generatedMessage = true
  stackStartFunction = options.stackStartFunction or fail
  Error.captureStackTrace this, stackStartFunction
  return

util.inherits assert.AssertionError, Error
assert.fail = fail
assert.ok = ok
assert.equal = equal = (actual, expected, message) ->
  fail actual, expected, message, "==", assert.equal  unless actual is expected
  return

assert.notEqual = notEqual = (actual, expected, message) ->
  fail actual, expected, message, "!=", assert.notEqual  if actual is expected
  return

assert.deepEqual = deepEqual = (actual, expected, message) ->
  fail actual, expected, message, "deepEqual", assert.deepEqual  unless _deepEqual(actual, expected)
  return

assert.notDeepEqual = notDeepEqual = (actual, expected, message) ->
  fail actual, expected, message, "notDeepEqual", assert.notDeepEqual  if _deepEqual(actual, expected)
  return

assert.strictEqual = strictEqual = (actual, expected, message) ->
  fail actual, expected, message, "===", assert.strictEqual  if actual isnt expected
  return

assert.notStrictEqual = notStrictEqual = (actual, expected, message) ->
  fail actual, expected, message, "!==", assert.notStrictEqual  if actual is expected
  return


# 11. Expected to throw an error:
# assert.throws(block, Error_opt, message_opt);
assert.throws = (block, error, message) -> #optional
#optional
  _throws.apply this, [true].concat(pSlice.call(arguments))
  return


# EXTENSION! This is annoying to write outside this module.
assert.doesNotThrow = (block, message) -> #optional
  _throws.apply this, [false].concat(pSlice.call(arguments))
  return

assert.ifError = (err) ->
  throw err  if err
  return
