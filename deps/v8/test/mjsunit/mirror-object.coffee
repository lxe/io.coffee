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

# Flags: --expose-debug-as debug
# Test the mirror object for objects
MirrorRefCache = (json_refs) ->
  tmp = eval("(" + json_refs + ")")
  @refs_ = []
  i = 0

  while i < tmp.length
    @refs_[tmp[i].handle] = tmp[i]
    i++
  return
testObjectMirror = (obj, cls_name, ctor_name, hasSpecialProperties) ->
  
  # Create mirror and JSON representation.
  mirror = debug.MakeMirror(obj)
  serializer = debug.MakeMirrorSerializer()
  json = JSON.stringify(serializer.serializeValue(mirror))
  refs = new MirrorRefCache(JSON.stringify(serializer.serializeReferencedObjects()))
  
  # Check the mirror hierachy.
  assertTrue mirror instanceof debug.Mirror, "Unexpected mirror hierarchy"
  assertTrue mirror instanceof debug.ValueMirror, "Unexpected mirror hierarchy"
  assertTrue mirror instanceof debug.ObjectMirror, "Unexpected mirror hierarchy"
  
  # Check the mirror properties.
  assertTrue mirror.isObject(), "Unexpected mirror"
  assertEquals "object", mirror.type(), "Unexpected mirror type"
  assertFalse mirror.isPrimitive(), "Unexpected primitive mirror"
  assertEquals cls_name, mirror.className(), "Unexpected mirror class name"
  assertTrue mirror.constructorFunction() instanceof debug.ObjectMirror, "Unexpected mirror hierarchy"
  assertEquals ctor_name, mirror.constructorFunction().name(), "Unexpected constructor function name"
  assertTrue mirror.protoObject() instanceof debug.Mirror, "Unexpected mirror hierarchy"
  assertTrue mirror.prototypeObject() instanceof debug.Mirror, "Unexpected mirror hierarchy"
  assertFalse mirror.hasNamedInterceptor(), "No named interceptor expected"
  assertFalse mirror.hasIndexedInterceptor(), "No indexed interceptor expected"
  names = mirror.propertyNames()
  properties = mirror.properties()
  assertEquals names.length, properties.length
  i = 0

  while i < properties.length
    assertTrue properties[i] instanceof debug.Mirror, "Unexpected mirror hierarchy"
    assertTrue properties[i] instanceof debug.PropertyMirror, "Unexpected mirror hierarchy"
    assertEquals "property", properties[i].type(), "Unexpected mirror type"
    assertEquals names[i], properties[i].name(), "Unexpected property name"
    i++
  internalProperties = mirror.internalProperties()
  i = 0

  while i < internalProperties.length
    assertTrue internalProperties[i] instanceof debug.Mirror, "Unexpected mirror hierarchy"
    assertTrue internalProperties[i] instanceof debug.InternalPropertyMirror, "Unexpected mirror hierarchy"
    assertEquals "internalProperty", internalProperties[i].type(), "Unexpected mirror type"
    i++
  for p of obj
    property_mirror = mirror.property(p)
    assertTrue property_mirror instanceof debug.PropertyMirror
    assertEquals p, property_mirror.name()
    
    # If the object has some special properties don't test for these.
    unless hasSpecialProperties
      assertEquals 0, property_mirror.attributes(), property_mirror.name()
      assertFalse property_mirror.isReadOnly()
      assertTrue property_mirror.isEnum()
      assertTrue property_mirror.canDelete()
  
  # Parse JSON representation and check.
  fromJSON = eval("(" + json + ")")
  assertEquals "object", fromJSON.type, "Unexpected mirror type in JSON"
  assertEquals cls_name, fromJSON.className, "Unexpected mirror class name in JSON"
  assertEquals mirror.constructorFunction().handle(), fromJSON.constructorFunction.ref, "Unexpected constructor function handle in JSON"
  assertEquals "function", refs.lookup(fromJSON.constructorFunction.ref).type, "Unexpected constructor function type in JSON"
  assertEquals ctor_name, refs.lookup(fromJSON.constructorFunction.ref).name, "Unexpected constructor function name in JSON"
  assertEquals mirror.protoObject().handle(), fromJSON.protoObject.ref, "Unexpected proto object handle in JSON"
  assertEquals mirror.protoObject().type(), refs.lookup(fromJSON.protoObject.ref).type, "Unexpected proto object type in JSON"
  assertEquals mirror.prototypeObject().handle(), fromJSON.prototypeObject.ref, "Unexpected prototype object handle in JSON"
  assertEquals mirror.prototypeObject().type(), refs.lookup(fromJSON.prototypeObject.ref).type, "Unexpected prototype object type in JSON"
  assertEquals undefined, fromJSON.namedInterceptor, "No named interceptor expected in JSON"
  assertEquals undefined, fromJSON.indexedInterceptor, "No indexed interceptor expected in JSON"
  
  # Check that the serialization contains all properties.
  assertEquals names.length, fromJSON.properties.length, "Some properties missing in JSON"
  j = 0

  while j < names.length
    name = names[j]
    
    # Serialization of symbol-named properties to JSON doesn't really
    # work currently, as they don't get a {name: ...} entry.
    continue  if typeof name is "symbol"
    found = false
    i = 0

    while i < fromJSON.properties.length
      if fromJSON.properties[i].name is name
        
        # Check that serialized handle is correct.
        assertEquals properties[i].value().handle(), fromJSON.properties[i].ref, "Unexpected serialized handle"
        
        # Check that serialized name is correct.
        assertEquals properties[i].name(), fromJSON.properties[i].name, "Unexpected serialized name"
        
        # If property type is normal property type is not serialized.
        unless properties[i].propertyType() is debug.PropertyType.Normal
          assertEquals properties[i].propertyType(), fromJSON.properties[i].propertyType, "Unexpected serialized property type"
        else
          assertTrue typeof (fromJSON.properties[i].propertyType) is "undefined", "Unexpected serialized property type"
        
        # If there are no attributes attributes are not serialized.
        unless properties[i].attributes() is debug.PropertyAttribute.None
          assertEquals properties[i].attributes(), fromJSON.properties[i].attributes, "Unexpected serialized attributes"
        else
          assertTrue typeof (fromJSON.properties[i].attributes) is "undefined", "Unexpected serialized attributes"
        
        # Lookup the serialized object from the handle reference.
        o = refs.lookup(fromJSON.properties[i].ref)
        assertTrue o?, "Referenced object is not serialized"
        assertEquals properties[i].value().type(), o.type, "Unexpected serialized property type for " + name
        if properties[i].value().isPrimitive()
          if properties[i].value().type() is "null" or properties[i].value().type() is "undefined"
            
            # Null and undefined has no value property.
            assertFalse "value" of o, "Unexpected value property for " + name
          else if properties[i].value().type() is "number" and not isFinite(properties[i].value().value())
            assertEquals String(properties[i].value().value()), o.value, "Unexpected serialized property value for " + name
          else
            assertEquals properties[i].value().value(), o.value, "Unexpected serialized property value for " + name
        else assertEquals properties[i].value().source(), o.source, "Unexpected serialized property value for " + name  if properties[i].value().isFunction()
        found = true
      i++
    assertTrue found, "\"" + name + "\" not found (" + json + ")"
    j++
  return
Point = (x, y) ->
  @x_ = x
  @y_ = y
  return
MirrorRefCache::lookup = (handle) ->
  @refs_[handle]

object_with_symbol = {}
object_with_symbol[Symbol.iterator] = 42

# Test a number of different objects.
testObjectMirror {}, "Object", "Object"
testObjectMirror
  a: 1
  b: 2
, "Object", "Object"
testObjectMirror
  1: undefined
  2: null
  f: pow = (x, y) ->
    Math.pow x, y
, "Object", "Object"
testObjectMirror new Point(-1.2, 2.003), "Object", "Point"
testObjectMirror this, "global", "", true # Global object has special properties
testObjectMirror @__proto__, "Object", ""
testObjectMirror [], "Array", "Array"
testObjectMirror [
  1
  2
], "Array", "Array"
testObjectMirror Object(17), "Number", "Number"
testObjectMirror object_with_symbol, "Object", "Object"

# Test circular references.
o = {}
o.o = o
testObjectMirror o, "Object", "Object"

# Test that non enumerable properties are part of the mirror
global_mirror = debug.MakeMirror(this)
assertEquals "property", global_mirror.property("Math").type()
assertFalse global_mirror.property("Math").isEnum(), "Math is enumerable" + global_mirror.property("Math").attributes()
math_mirror = global_mirror.property("Math").value()
assertEquals "property", math_mirror.property("E").type()
assertFalse math_mirror.property("E").isEnum(), "Math.E is enumerable"
assertTrue math_mirror.property("E").isReadOnly()
assertFalse math_mirror.property("E").canDelete()

# Test objects with JavaScript accessors.
o = {}
o.__defineGetter__ "a", ->
  "a"

o.__defineSetter__ "b", ->

o.__defineGetter__ "c", ->
  throw "c"return

o.__defineSetter__ "c", ->
  throw "c"return

testObjectMirror o, "Object", "Object"
mirror = debug.MakeMirror(o)

# a has getter but no setter.
assertTrue mirror.property("a").hasGetter()
assertFalse mirror.property("a").hasSetter()
assertEquals debug.PropertyType.Callbacks, mirror.property("a").propertyType()
assertEquals "function", mirror.property("a").getter().type()
assertEquals "undefined", mirror.property("a").setter().type()
assertEquals "function (){return 'a';}", mirror.property("a").getter().source()

# b has setter but no getter.
assertFalse mirror.property("b").hasGetter()
assertTrue mirror.property("b").hasSetter()
assertEquals debug.PropertyType.Callbacks, mirror.property("b").propertyType()
assertEquals "undefined", mirror.property("b").getter().type()
assertEquals "function", mirror.property("b").setter().type()
assertEquals "function (){}", mirror.property("b").setter().source()
assertFalse mirror.property("b").isException()

# c has both getter and setter. The getter throws an exception.
assertTrue mirror.property("c").hasGetter()
assertTrue mirror.property("c").hasSetter()
assertEquals debug.PropertyType.Callbacks, mirror.property("c").propertyType()
assertEquals "function", mirror.property("c").getter().type()
assertEquals "function", mirror.property("c").setter().type()
assertEquals "function (){throw 'c';}", mirror.property("c").getter().source()
assertEquals "function (){throw 'c';}", mirror.property("c").setter().source()

# Test objects with native accessors.
mirror = debug.MakeMirror(new String("abc"))
assertTrue mirror instanceof debug.ObjectMirror
assertFalse mirror.property("length").hasGetter()
assertFalse mirror.property("length").hasSetter()
assertTrue mirror.property("length").isNative()
assertEquals "a", mirror.property(0).value().value()
assertEquals "b", mirror.property(1).value().value()
assertEquals "c", mirror.property(2).value().value()

# Test value wrapper internal properties.
mirror = debug.MakeMirror(Object("Capybara"))
ip = mirror.internalProperties()
assertEquals 1, ip.length
assertEquals "[[PrimitiveValue]]", ip[0].name()
assertEquals "string", ip[0].value().type()
assertEquals "Capybara", ip[0].value().value()

# Test bound function internal properties.
mirror = debug.MakeMirror(Number.bind(Array, 2))
ip = mirror.internalProperties()
assertEquals 3, ip.length
property_map = {}
i = 0

while i < ip.length
  property_map[ip[i].name()] = ip[i]
  i++
assertTrue "[[BoundThis]]" of property_map
assertEquals "function", property_map["[[BoundThis]]"].value().type()
assertEquals Array, property_map["[[BoundThis]]"].value().value()
assertTrue "[[TargetFunction]]" of property_map
assertEquals "function", property_map["[[TargetFunction]]"].value().type()
assertEquals Number, property_map["[[TargetFunction]]"].value().value()
assertTrue "[[BoundArgs]]" of property_map
assertEquals "object", property_map["[[BoundArgs]]"].value().type()
assertEquals 1, property_map["[[BoundArgs]]"].value().value().length
