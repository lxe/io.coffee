# Copyright 2012 the V8 project authors. All rights reserved.
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

# Flags: --harmony-proxies
testStringify = (expected, object) ->
  
  # Test fast case that bails out to slow case.
  assertEquals expected, JSON.stringify(object)
  
  # Test slow case.
  assertEquals expected, JSON.stringify(object, `undefined`, 0)
  return

# Test serializing a proxy, function proxy and objects that contain them.
handler1 =
  get: (target, name) ->
    name.toUpperCase()

  enumerate: (target) ->
    [
      "a"
      "b"
      "c"
    ]

  getOwnPropertyDescriptor: (target, name) ->
    enumerable: true

proxy1 = Proxy.create(handler1)
testStringify "{\"a\":\"A\",\"b\":\"B\",\"c\":\"C\"}", proxy1
proxy_fun = Proxy.createFunction(handler1, ->
  1
)
testStringify `undefined`, proxy_fun
testStringify "[1,null]", [
  1
  proxy_fun
]
parent1a = b: proxy1
testStringify "{\"b\":{\"a\":\"A\",\"b\":\"B\",\"c\":\"C\"}}", parent1a
parent1b =
  a: 123
  b: proxy1
  c: true

testStringify "{\"a\":123,\"b\":{\"a\":\"A\",\"b\":\"B\",\"c\":\"C\"},\"c\":true}", parent1b
parent1c = [
  123
  proxy1
  true
]
testStringify "[123,{\"a\":\"A\",\"b\":\"B\",\"c\":\"C\"},true]", parent1c

# Proxy with side effect.
handler2 =
  get: (target, name) ->
    delete parent2.c

    name.toUpperCase()

  enumerate: (target) ->
    [
      "a"
      "b"
      "c"
    ]

  getOwnPropertyDescriptor: (target, name) ->
    enumerable: true

proxy2 = Proxy.create(handler2)
parent2 =
  a: "delete"
  b: proxy2
  c: "remove"

expected2 = "{\"a\":\"delete\",\"b\":{\"a\":\"A\",\"b\":\"B\",\"c\":\"C\"}}"
assertEquals expected2, JSON.stringify(parent2)
parent2.c = "remove" # Revert side effect.
assertEquals expected2, JSON.stringify(parent2, `undefined`, 0)

# Proxy with a get function that uses the first argument.
handler3 =
  get: (target, name) ->
    if name is "valueOf"
      return ->
        "proxy"
    name + "(" + target + ")"

  enumerate: (target) ->
    [
      "a"
      "b"
      "c"
    ]

  getOwnPropertyDescriptor: (target, name) ->
    enumerable: true

proxy3 = Proxy.create(handler3)
parent3 =
  x: 123
  y: proxy3

testStringify "{\"x\":123,\"y\":{\"a\":\"a(proxy)\",\"b\":\"b(proxy)\",\"c\":\"c(proxy)\"}}", parent3

# Empty proxy.
handler4 =
  get: (target, name) ->
    0

  enumerate: (target) ->
    []

  getOwnPropertyDescriptor: (target, name) ->
    enumerable: false

proxy4 = Proxy.create(handler4)
testStringify "{}", proxy4
testStringify "{\"a\":{}}",
  a: proxy4


# Proxy that provides a toJSON function that uses this.
handler5 =
  get: (target, name) ->
    return 97000  if name is "z"
    (key) ->
      key.charCodeAt(0) + @z

  enumerate: (target) ->
    [
      "toJSON"
      "z"
    ]

  getOwnPropertyDescriptor: (target, name) ->
    enumerable: true

proxy5 = Proxy.create(handler5)
testStringify "{\"a\":97097}",
  a: proxy5


# Proxy that provides a toJSON function that returns undefined.
handler6 =
  get: (target, name) ->
    (key) ->
      `undefined`

  enumerate: (target) ->
    ["toJSON"]

  getOwnPropertyDescriptor: (target, name) ->
    enumerable: true

proxy6 = Proxy.create(handler6)
testStringify "[1,null,true]", [
  1
  proxy6
  true
]
testStringify "{\"a\":1,\"c\":true}",
  a: 1
  b: proxy6
  c: true


# Object containing a proxy that changes the parent's properties.
handler7 =
  get: (target, name) ->
    delete parent7.a

    delete parent7.c

    parent7.e = "5"
    name.toUpperCase()

  enumerate: (target) ->
    [
      "a"
      "b"
      "c"
    ]

  getOwnPropertyDescriptor: (target, name) ->
    enumerable: true

proxy7 = Proxy.create(handler7)
parent7 =
  a: "1"
  b: proxy7
  c: "3"
  d: "4"

assertEquals "{\"a\":\"1\",\"b\":{\"a\":\"A\",\"b\":\"B\",\"c\":\"C\"},\"d\":\"4\"}", JSON.stringify(parent7)
assertEquals "{\"b\":{\"a\":\"A\",\"b\":\"B\",\"c\":\"C\"},\"d\":\"4\",\"e\":\"5\"}", JSON.stringify(parent7)
