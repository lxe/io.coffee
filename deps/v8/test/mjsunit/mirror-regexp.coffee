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

# Flags: --expose-debug-as debug
# Test the mirror object for regular expression values
MirrorRefCache = (json_refs) ->
  tmp = eval("(" + json_refs + ")")
  @refs_ = []
  i = 0

  while i < tmp.length
    @refs_[tmp[i].handle] = tmp[i]
    i++
  return
testRegExpMirror = (r) ->
  
  # Create mirror and JSON representation.
  mirror = debug.MakeMirror(r)
  serializer = debug.MakeMirrorSerializer()
  json = JSON.stringify(serializer.serializeValue(mirror))
  refs = new MirrorRefCache(JSON.stringify(serializer.serializeReferencedObjects()))
  
  # Check the mirror hierachy.
  assertTrue mirror instanceof debug.Mirror
  assertTrue mirror instanceof debug.ValueMirror
  assertTrue mirror instanceof debug.ObjectMirror
  assertTrue mirror instanceof debug.RegExpMirror
  
  # Check the mirror properties.
  assertTrue mirror.isRegExp()
  assertEquals "regexp", mirror.type()
  assertFalse mirror.isPrimitive()
  for p of expected_attributes
    assertEquals expected_attributes[p], mirror.property(p).attributes(), p + " attributes"
  
  # Test text representation
  assertEquals "/" + r.source + "/", mirror.toText()
  
  # Parse JSON representation and check.
  fromJSON = eval("(" + json + ")")
  assertEquals "regexp", fromJSON.type
  assertEquals "RegExp", fromJSON.className
  for p of expected_attributes
    i = 0

    while i < fromJSON.properties.length
      if fromJSON.properties[i].name is p
        assertEquals expected_attributes[p], fromJSON.properties[i].attributes, "Unexpected value for " + p + " attributes"
        assertEquals mirror.property(p).propertyType(), fromJSON.properties[i].propertyType, "Unexpected value for " + p + " propertyType"
        assertEquals mirror.property(p).value().handle(), fromJSON.properties[i].ref, "Unexpected handle for " + p
        assertEquals mirror.property(p).value().value(), refs.lookup(fromJSON.properties[i].ref).value, "Unexpected value for " + p
      i++
  return
all_attributes = debug.PropertyAttribute.ReadOnly | debug.PropertyAttribute.DontEnum | debug.PropertyAttribute.DontDelete
expected_attributes =
  source: all_attributes
  global: all_attributes
  ignoreCase: all_attributes
  multiline: all_attributes
  lastIndex: debug.PropertyAttribute.DontEnum | debug.PropertyAttribute.DontDelete

MirrorRefCache::lookup = (handle) ->
  @refs_[handle]


# Test Date values.
testRegExpMirror /x/
testRegExpMirror /[abc]/
testRegExpMirror /[\r\n]/g
testRegExpMirror /a*b/g
