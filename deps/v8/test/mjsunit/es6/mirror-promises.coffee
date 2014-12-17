# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-debug-as debug
# Test the mirror object for promises.
MirrorRefCache = (json_refs) ->
  tmp = eval("(" + json_refs + ")")
  @refs_ = []
  i = 0

  while i < tmp.length
    @refs_[tmp[i].handle] = tmp[i]
    i++
  return
testPromiseMirror = (promise, status, value) ->
  
  # Create mirror and JSON representation.
  mirror = debug.MakeMirror(promise)
  serializer = debug.MakeMirrorSerializer()
  json = JSON.stringify(serializer.serializeValue(mirror))
  refs = new MirrorRefCache(JSON.stringify(serializer.serializeReferencedObjects()))
  
  # Check the mirror hierachy.
  assertTrue mirror instanceof debug.Mirror
  assertTrue mirror instanceof debug.ValueMirror
  assertTrue mirror instanceof debug.ObjectMirror
  assertTrue mirror instanceof debug.PromiseMirror
  
  # Check the mirror properties.
  assertEquals status, mirror.status()
  assertTrue mirror.isPromise()
  assertEquals "promise", mirror.type()
  assertFalse mirror.isPrimitive()
  assertEquals "Object", mirror.className()
  assertEquals "#<Promise>", mirror.toText()
  assertSame promise, mirror.value()
  assertTrue mirror.promiseValue() instanceof debug.Mirror
  assertEquals value, mirror.promiseValue().value()
  
  # Parse JSON representation and check.
  fromJSON = eval("(" + json + ")")
  assertEquals "promise", fromJSON.type
  assertEquals "Object", fromJSON.className
  assertEquals "function", refs.lookup(fromJSON.constructorFunction.ref).type
  assertEquals "Promise", refs.lookup(fromJSON.constructorFunction.ref).name
  assertEquals status, fromJSON.status
  assertEquals value, refs.lookup(fromJSON.promiseValue.ref).value
  return
MirrorRefCache::lookup = (handle) ->
  @refs_[handle]


# Test a number of different promises.
resolved = new Promise((resolve, reject) ->
  resolve()
  return
)
rejected = new Promise((resolve, reject) ->
  reject()
  return
)
pending = new Promise((resolve, reject) ->
)
testPromiseMirror resolved, "resolved", `undefined`
testPromiseMirror rejected, "rejected", `undefined`
testPromiseMirror pending, "pending", `undefined`
resolvedv = new Promise((resolve, reject) ->
  resolve "resolve"
  return
)
rejectedv = new Promise((resolve, reject) ->
  reject "reject"
  return
)
thrownv = new Promise((resolve, reject) ->
  throw "throw"return
)
testPromiseMirror resolvedv, "resolved", "resolve"
testPromiseMirror rejectedv, "rejected", "reject"
testPromiseMirror thrownv, "rejected", "throw"

# Test internal properties of different promises.
m1 = debug.MakeMirror(new Promise((resolve, reject) ->
  resolve 1
  return
))
ip = m1.internalProperties()
assertEquals 2, ip.length
assertEquals "[[PromiseStatus]]", ip[0].name()
assertEquals "[[PromiseValue]]", ip[1].name()
assertEquals "resolved", ip[0].value().value()
assertEquals 1, ip[1].value().value()
m2 = debug.MakeMirror(new Promise((resolve, reject) ->
  reject 2
  return
))
ip = m2.internalProperties()
assertEquals "rejected", ip[0].value().value()
assertEquals 2, ip[1].value().value()
m3 = debug.MakeMirror(new Promise((resolve, reject) ->
))
ip = m3.internalProperties()
assertEquals "pending", ip[0].value().value()
assertEquals "undefined", typeof (ip[1].value().value())
