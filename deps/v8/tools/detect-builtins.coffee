# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
((global) ->
  GetProperties = (this_name, object) ->
    result = {}
    try
      names = Object.getOwnPropertyNames(object)
    catch e
      return
    i = 0

    while i < names.length
      name = names[i]
      continue  if name is "length" or name is "name" or name is "arguments" or name is "caller" or name is "prototype"  if typeof object is "function"
      
      # Avoid endless recursion.
      continue  if this_name is "prototype" and name is "constructor"
      
      # Could get this from the parent, but having it locally is easier.
      property = name: name
      try
        value = object[name]
      catch e
        property.type = "getter"
        result[name] = property
        continue
      type = typeof value
      property.type = type
      if type is "function"
        property.length = value.length
        property:: = GetProperties("prototype", value::)
      property.properties = GetProperties(name, value)
      result[name] = property
      ++i
    result

  g = GetProperties("", global, "")
  print JSON.stringify(g, `undefined`, 2)
  return
) this # Must wrap in anonymous closure or it'll detect itself as builtin.
