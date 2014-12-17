# Copyright 2011 the V8 project authors. All rights reserved.
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

# Non generic natives do not work on any input other than the specific
# type, but since this change will allow call to be invoked with undefined
# or null as this we still explicitly test that we throw on these here.

# Mapping functions.

# Reduce functions.
checkExpectedMessage = (e) ->
  assertTrue e.message.indexOf("called on null or undefined") >= 0 or e.message.indexOf("invoked on undefined or null value") >= 0 or e.message.indexOf("Cannot convert undefined or null to object") >= 0
  return
should_throw_on_null_and_undefined = [
  Object::toLocaleString
  Object::valueOf
  Object::hasOwnProperty
  Object::isPrototypeOf
  Object::propertyIsEnumerable
  Array::concat
  Array::join
  Array::pop
  Array::push
  Array::reverse
  Array::shift
  Array::slice
  Array::sort
  Array::splice
  Array::unshift
  Array::indexOf
  Array::lastIndexOf
  Array::every
  Array::some
  Array::forEach
  Array::map
  Array::filter
  Array::reduce
  Array::reduceRight
  String::charAt
  String::charCodeAt
  String::concat
  String::indexOf
  String::lastIndexOf
  String::localeCompare
  String::match
  String::replace
  String::search
  String::slice
  String::split
  String::substring
  String::toLowerCase
  String::toLocaleLowerCase
  String::toUpperCase
  String::toLocaleUpperCase
  String::trim
]
non_generic = [
  Array::toString
  Array::toLocaleString
  Function::toString
  Function::call
  Function::apply
  String::toString
  String::valueOf
  Boolean::toString
  Boolean::valueOf
  Number::toString
  Number::valueOf
  Number::toFixed
  Number::toExponential
  Number::toPrecision
  Date::toString
  Date::toDateString
  Date::toTimeString
  Date::toLocaleString
  Date::toLocaleDateString
  Date::toLocaleTimeString
  Date::valueOf
  Date::getTime
  Date::getFullYear
  Date::getUTCFullYear
  Date::getMonth
  Date::getUTCMonth
  Date::getDate
  Date::getUTCDate
  Date::getDay
  Date::getUTCDay
  Date::getHours
  Date::getUTCHours
  Date::getMinutes
  Date::getUTCMinutes
  Date::getSeconds
  Date::getUTCSeconds
  Date::getMilliseconds
  Date::getUTCMilliseconds
  Date::getTimezoneOffset
  Date::setTime
  Date::setMilliseconds
  Date::setUTCMilliseconds
  Date::setSeconds
  Date::setUTCSeconds
  Date::setMinutes
  Date::setUTCMinutes
  Date::setHours
  Date::setUTCHours
  Date::setDate
  Date::setUTCDate
  Date::setMonth
  Date::setUTCMonth
  Date::setFullYear
  Date::setUTCFullYear
  Date::toUTCString
  Date::toISOString
  Date::toJSON
  RegExp::exec
  RegExp::test
  RegExp::toString
  Error::toString
]
mapping_functions = [
  Array::every
  Array::some
  Array::forEach
  Array::map
  Array::filter
]
reducing_functions = [
  Array::reduce
  Array::reduceRight
]

# Test that all natives using the ToObject call throw the right exception.
i = 0

while i < should_throw_on_null_and_undefined.length
  
  # Sanity check that all functions are correct
  assertEquals typeof (should_throw_on_null_and_undefined[i]), "function"
  exception = false
  try
    
    # We need to pass a dummy object argument ({}) to these functions because
    # of Object.prototype.isPrototypeOf's special behavior, see issue 3483
    # for more details.
    should_throw_on_null_and_undefined[i].call null, {}
  catch e
    exception = true
    checkExpectedMessage e
  assertTrue exception
  exception = false
  try
    should_throw_on_null_and_undefined[i].call `undefined`, {}
  catch e
    exception = true
    checkExpectedMessage e
  assertTrue exception
  exception = false
  try
    should_throw_on_null_and_undefined[i].apply null, [{}]
  catch e
    exception = true
    checkExpectedMessage e
  assertTrue exception
  exception = false
  try
    should_throw_on_null_and_undefined[i].apply `undefined`, [{}]
  catch e
    exception = true
    checkExpectedMessage e
  assertTrue exception
  i++

# Test that all natives that are non generic throw on null and undefined.
i = 0

while i < non_generic.length
  
  # Sanity check that all functions are correct
  assertEquals typeof (non_generic[i]), "function"
  exception = false
  try
    non_generic[i].call null
  catch e
    exception = true
    assertTrue e instanceof TypeError
  assertTrue exception
  exception = false
  try
    non_generic[i].call null
  catch e
    exception = true
    assertTrue e instanceof TypeError
  assertTrue exception
  exception = false
  try
    non_generic[i].apply null
  catch e
    exception = true
    assertTrue e instanceof TypeError
  assertTrue exception
  exception = false
  try
    non_generic[i].apply null
  catch e
    exception = true
    assertTrue e instanceof TypeError
  assertTrue exception
  i++

# Test that we still throw when calling with thisArg null or undefined
# through an array mapping function.
# We need to make sure that the elements of `array` are all object values,
# see issue 3483 for more details.
array = [
  {
    {}
  }
  []
  new Number
  new Map
  new WeakSet
]
j = 0

while j < mapping_functions.length
  i = 0

  while i < should_throw_on_null_and_undefined.length
    exception = false
    try
      mapping_functions[j].call array, should_throw_on_null_and_undefined[i], null
    catch e
      exception = true
      checkExpectedMessage e
    assertTrue exception
    exception = false
    try
      mapping_functions[j].call array, should_throw_on_null_and_undefined[i], `undefined`
    catch e
      exception = true
      checkExpectedMessage e
    assertTrue exception
    i++
  j++
j = 0

while j < mapping_functions.length
  i = 0

  while i < non_generic.length
    exception = false
    try
      mapping_functions[j].call array, non_generic[i], null
    catch e
      exception = true
      assertTrue e instanceof TypeError
    assertTrue exception
    exception = false
    try
      mapping_functions[j].call array, non_generic[i], `undefined`
    catch e
      exception = true
      assertTrue e instanceof TypeError
    assertTrue exception
    i++
  j++

# Reduce functions do a call with null as this argument.
j = 0

while j < reducing_functions.length
  i = 0

  while i < should_throw_on_null_and_undefined.length
    exception = false
    try
      reducing_functions[j].call array, should_throw_on_null_and_undefined[i]
    catch e
      exception = true
      checkExpectedMessage e
    assertTrue exception
    exception = false
    try
      reducing_functions[j].call array, should_throw_on_null_and_undefined[i]
    catch e
      exception = true
      checkExpectedMessage e
    assertTrue exception
    i++
  j++
j = 0

while j < reducing_functions.length
  i = 0

  while i < non_generic.length
    exception = false
    try
      reducing_functions[j].call array, non_generic[i]
    catch e
      exception = true
      assertTrue e instanceof TypeError
    assertTrue exception
    exception = false
    try
      reducing_functions[j].call array, non_generic[i]
    catch e
      exception = true
      assertTrue e instanceof TypeError
    assertTrue exception
    i++
  j++

# Object.prototype.toString()
assertEquals Object::toString.call(null), "[object Null]"
assertEquals Object::toString.call(`undefined`), "[object Undefined]"
