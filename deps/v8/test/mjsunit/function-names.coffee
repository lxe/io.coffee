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
TestFunctionNames = (object, names) ->
  i = 0

  while i < names.length
    assertEquals names[i], object[names[i]].name
    i++
  return

# Array.prototype functions.
arrayPrototypeFunctions = [
  "toString"
  "toLocaleString"
  "join"
  "pop"
  "push"
  "concat"
  "reverse"
  "shift"
  "unshift"
  "slice"
  "splice"
  "sort"
  "filter"
  "forEach"
  "some"
  "every"
  "map"
  "indexOf"
  "lastIndexOf"
]
TestFunctionNames Array::, arrayPrototypeFunctions

# Boolean prototype functions.
booleanPrototypeFunctions = [
  "toString"
  "valueOf"
]
TestFunctionNames Boolean::, booleanPrototypeFunctions

# Date functions.
dateFunctions = [
  "UTC"
  "parse"
  "now"
]
TestFunctionNames Date, dateFunctions

# Date.prototype functions.
datePrototypeFunctions = [
  "toString"
  "toDateString"
  "toTimeString"
  "toLocaleString"
  "toLocaleDateString"
  "toLocaleTimeString"
  "valueOf"
  "getTime"
  "getFullYear"
  "getUTCFullYear"
  "getMonth"
  "getUTCMonth"
  "getDate"
  "getUTCDate"
  "getDay"
  "getUTCDay"
  "getHours"
  "getUTCHours"
  "getMinutes"
  "getUTCMinutes"
  "getSeconds"
  "getUTCSeconds"
  "getMilliseconds"
  "getUTCMilliseconds"
  "getTimezoneOffset"
  "setTime"
  "setMilliseconds"
  "setUTCMilliseconds"
  "setSeconds"
  "setUTCSeconds"
  "setMinutes"
  "setUTCMinutes"
  "setHours"
  "setUTCHours"
  "setDate"
  "setUTCDate"
  "setMonth"
  "setUTCMonth"
  "setFullYear"
  "setUTCFullYear"
  "toGMTString"
  "toUTCString"
  "getYear"
  "setYear"
]
TestFunctionNames Date::, datePrototypeFunctions

# Function.prototype functions.
functionPrototypeFunctions = [
  "toString"
  "apply"
  "call"
]
TestFunctionNames Function::, functionPrototypeFunctions

# Math functions.
mathFunctions = [
  "random"
  "abs"
  "acos"
  "asin"
  "atan"
  "ceil"
  "cos"
  "exp"
  "floor"
  "log"
  "round"
  "sin"
  "sqrt"
  "tan"
  "atan2"
  "pow"
  "max"
  "min"
]
TestFunctionNames Math, mathFunctions

# Number.prototype functions.
numberPrototypeFunctions = [
  "toString"
  "toLocaleString"
  "valueOf"
  "toFixed"
  "toExponential"
  "toPrecision"
]
TestFunctionNames Number::, numberPrototypeFunctions

# Object.prototype functions.
objectPrototypeFunctions = [
  "toString"
  "toLocaleString"
  "valueOf"
  "hasOwnProperty"
  "isPrototypeOf"
  "propertyIsEnumerable"
  "__defineGetter__"
  "__lookupGetter__"
  "__defineSetter__"
  "__lookupSetter__"
]
TestFunctionNames Object::, objectPrototypeFunctions

# RegExp.prototype functions.
regExpPrototypeFunctions = [
  "exec"
  "test"
  "toString"
  "compile"
]
TestFunctionNames RegExp::, regExpPrototypeFunctions

# String functions.
stringFunctions = ["fromCharCode"]
TestFunctionNames String, stringFunctions

# String.prototype functions.
stringPrototypeFunctions = [
  "toString"
  "valueOf"
  "charAt"
  "charCodeAt"
  "concat"
  "indexOf"
  "lastIndexOf"
  "localeCompare"
  "match"
  "replace"
  "search"
  "slice"
  "split"
  "substring"
  "substr"
  "toLowerCase"
  "toLocaleLowerCase"
  "toUpperCase"
  "toLocaleUpperCase"
  "link"
  "anchor"
  "fontcolor"
  "fontsize"
  "big"
  "blink"
  "bold"
  "fixed"
  "italics"
  "small"
  "strike"
  "sub"
  "sup"
]
TestFunctionNames String::, stringPrototypeFunctions

# Global functions.
globalFunctions = [
  "escape"
  "unescape"
  "decodeURI"
  "decodeURIComponent"
  "encodeURI"
  "encodeURIComponent"
  "Error"
  "TypeError"
  "RangeError"
  "SyntaxError"
  "ReferenceError"
  "EvalError"
  "URIError"
  "isNaN"
  "isFinite"
  "parseInt"
  "parseFloat"
  "eval"
]
TestFunctionNames this, globalFunctions
