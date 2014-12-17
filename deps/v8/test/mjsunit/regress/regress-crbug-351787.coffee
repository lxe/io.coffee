# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --allow-natives-syntax
ab1 = new ArrayBuffer(8)
ab1.__defineGetter__ "byteLength", ->
  1000000

ab2 = ab1.slice(800000, 900000)
array = new Uint8Array(ab2)
i = 0

while i < array.length
  assertEquals 0, array[i]
  i++
assertEquals 0, array.length
ab3 = new ArrayBuffer(8)
ab3.__defineGetter__ "byteLength", ->
  0xfffffffc

aaa = new DataView(ab3)
i = 10

while i < aaa.length
  aaa.setInt8 i, 0xcc
  i++
assertEquals 8, aaa.byteLength
a = new Int8Array(4)
a.__defineGetter__ "length", ->
  0xffff

b = new Int8Array(a)
i = 0

while i < b.length
  assertEquals 0, b[i]
  i++
ab4 = new ArrayBuffer(8)
ab4.__defineGetter__ "byteLength", ->
  0xfffffffc

aaaa = new Uint32Array(ab4)
i = 10

while i < aaaa.length
  aaaa[i] = 0xcccccccc
  i++
assertEquals 2, aaaa.length
