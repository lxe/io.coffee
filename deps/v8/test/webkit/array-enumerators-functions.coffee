# Copyright 2013 the V8 project authors. All rights reserved.
# Copyright (C) 2005, 2006, 2007, 2008, 2009 Apple Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
toObject = (array) ->
  o = {}
  for i of array
    o[i] = array[i]
  o.length = array.length
  o
toUnorderedObject = (array) ->
  o = {}
  props = []
  for i of array
    props.push i
  i = props.length - 1

  while i >= 0
    o[props[i]] = array[props[i]]
    i--
  o.length = array.length
  o
returnFalse = ->
  count++
  false
returnTrue = ->
  count++
  true
returnElem = (elem) ->
  count++
  elem
returnIndex = (a, index) ->
  throw "Unordered traversal"  if lastIndex >= index
  lastIndex = index
  count++
  index
increaseLength = (a, b, array) ->
  count++
  array.length++
  return
decreaseLength = (a, b, array) ->
  count++
  array.length--
  return
halveLength = (a, b, array) ->
  count++
  array.length = (array.length / 2) | 0  unless array.halved
  array.halved = true
  return
copyArray = (a) ->
  g = []
  for i of a
    g[i] = a[i]
  g
description "This test checks the behavior of the various array enumeration functions in certain edge case scenarios"
functions = [
  "every"
  "forEach"
  "some"
  "filter"
  "reduce"
  "map"
  "reduceRight"
]
forwarders = [
  (elem, index, array) ->
    return currentFunc.call(this, elem, index, array)
  (elem, index, array) ->
    return currentFunc.call(this, elem, index, array)
  (elem, index, array) ->
    return currentFunc.call(this, elem, index, array)
  (elem, index, array) ->
    return currentFunc.call(this, elem, index, array)
  (prev, elem, index, array) ->
    return currentFunc.call(this, elem, index, array)
  (elem, index, array) ->
    return currentFunc.call(this, elem, index, array)
  (prev, elem, index, array) ->
    return currentFunc.call(this, elem, index, array)
]
testFunctions = [
  "returnFalse"
  "returnTrue"
  "returnElem"
  "returnIndex"
  "increaseLength"
  "decreaseLength"
  "halveLength"
]
simpleArray = [
  0
  1
  2
  3
  4
  5
]
emptyArray = []
largeEmptyArray = new Array(300)
largeSparseArray = [
  0
  1
  2
  3
  4
  5
]
largeSparseArray[299] = 299
arrays = [
  "simpleArray"
  "emptyArray"
  "largeEmptyArray"
  "largeSparseArray"
]

# Test object and array behaviour matches
f = 0

while f < functions.length
  t = 0

  while t < testFunctions.length
    a = 0

    while a < arrays.length
      functionName = functions[f]
      currentFunc = this[testFunctions[t]]
      continue  if arrays[a] is "largeEmptyArray" and functionName is "map"
      continue  if currentFunc is returnIndex and functionName is "reduceRight"
      shouldBe "count=0;lastIndex=-1;copyArray(" + arrays[a] + ")." + functionName + "(forwarders[f], " + testFunctions[t] + ", 0)", "count=0;lastIndex=-1;Array.prototype." + functionName + ".call(toObject(" + arrays[a] + "), forwarders[f], " + testFunctions[t] + ", 0)"
      a++
    t++
  f++

# Test unordered object and array behaviour matches
f = 0

while f < functions.length
  t = 0

  while t < testFunctions.length
    a = 0

    while a < arrays.length
      functionName = functions[f]
      currentFunc = this[testFunctions[t]]
      continue  if arrays[a] is "largeEmptyArray" and functionName is "map"
      continue  if currentFunc is returnIndex and functionName is "reduceRight"
      shouldBe "count=0;lastIndex=-1;copyArray(" + arrays[a] + ")." + functionName + "(forwarders[f], " + testFunctions[t] + ", 0)", "count=0;lastIndex=-1;Array.prototype." + functionName + ".call(toUnorderedObject(" + arrays[a] + "), forwarders[f], " + testFunctions[t] + ", 0)"
      a++
    t++
  f++

# Test number of function calls
callCounts = [
  [
    [
      1
      0
      0
      1
    ]
    [
      6
      0
      0
      7
    ]
    [
      1
      0
      0
      1
    ]
    [
      1
      0
      0
      1
    ]
    [
      1
      0
      0
      1
    ]
    [
      1
      0
      0
      1
    ]
    [
      1
      0
      0
      1
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      3
      0
      0
      6
    ]
    [
      3
      0
      0
      6
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      1
      0
      0
      1
    ]
    [
      2
      0
      0
      2
    ]
    [
      2
      0
      0
      2
    ]
    [
      6
      0
      0
      7
    ]
    [
      3
      0
      0
      6
    ]
    [
      3
      0
      0
      6
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      3
      0
      0
      6
    ]
    [
      3
      0
      0
      6
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      3
      0
      0
      6
    ]
    [
      3
      0
      0
      6
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      3
      0
      0
      6
    ]
    [
      3
      0
      0
      6
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      4
      0
      0
      7
    ]
  ]
]
objCallCounts = [
  [
    [
      1
      0
      0
      1
    ]
    [
      6
      0
      0
      7
    ]
    [
      1
      0
      0
      1
    ]
    [
      1
      0
      0
      1
    ]
    [
      1
      0
      0
      1
    ]
    [
      1
      0
      0
      1
    ]
    [
      1
      0
      0
      1
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      1
      0
      0
      1
    ]
    [
      2
      0
      0
      2
    ]
    [
      2
      0
      0
      2
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
  ]
  [
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
    [
      6
      0
      0
      7
    ]
  ]
]
f = 0

while f < functions.length
  t = 0

  while t < testFunctions.length
    a = 0

    while a < arrays.length
      functionName = functions[f]
      currentFunc = this[testFunctions[t]]
      continue  if currentFunc is returnIndex and functionName is "reduceRight"
      expectedCnt = "" + callCounts[f][t][a]
      shouldBe "count=0;lastIndex=-1;copyArray(" + arrays[a] + ")." + functionName + "(forwarders[f], " + testFunctions[t] + ", 0); count", expectedCnt
      expectedCnt = "" + objCallCounts[f][t][a]
      shouldBe "count=0;lastIndex=-1;Array.prototype." + functionName + ".call(toObject(" + arrays[a] + "), forwarders[f], " + testFunctions[t] + ", 0); count", expectedCnt
      shouldBe "count=0;lastIndex=-1;Array.prototype." + functionName + ".call(toObject(" + arrays[a] + "), forwarders[f], " + testFunctions[t] + ", 0); count", expectedCnt
      a++
    t++
  f++
