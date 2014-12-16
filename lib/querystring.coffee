# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

# Query String Utilities

# If obj.hasOwnProperty has been overridden, then calling
# obj.hasOwnProperty(prop) will break.
# See: https://github.com/joyent/node/issues/1707
hasOwnProperty = (obj, prop) ->
  Object::hasOwnProperty.call obj, prop
charCode = (c) ->
  c.charCodeAt 0
"use strict"
QueryString = exports
util = require("util")

# a safe fast alternative to decodeURIComponent
QueryString.unescapeBuffer = (s, decodeSpaces) ->
  out = new Buffer(s.length)
  state = "CHAR" # states: CHAR, HEX0, HEX1
  n = undefined
  m = undefined
  hexchar = undefined
  inIndex = 0
  outIndex = 0

  while inIndex <= s.length
    c = s.charCodeAt(inIndex)
    switch state
      when "CHAR"
        switch c
          when charCode("%")
            n = 0
            m = 0
            state = "HEX0"
          when charCode("+")
            c = charCode(" ")  if decodeSpaces
          
          # pass thru
          else
            out[outIndex++] = c
      when "HEX0"
        state = "HEX1"
        hexchar = c
        if charCode("0") <= c and c <= charCode("9")
          n = c - charCode("0")
        else if charCode("a") <= c and c <= charCode("f")
          n = c - charCode("a") + 10
        else if charCode("A") <= c and c <= charCode("F")
          n = c - charCode("A") + 10
        else
          out[outIndex++] = charCode("%")
          out[outIndex++] = c
          state = "CHAR"
          break
      when "HEX1"
        state = "CHAR"
        if charCode("0") <= c and c <= charCode("9")
          m = c - charCode("0")
        else if charCode("a") <= c and c <= charCode("f")
          m = c - charCode("a") + 10
        else if charCode("A") <= c and c <= charCode("F")
          m = c - charCode("A") + 10
        else
          out[outIndex++] = charCode("%")
          out[outIndex++] = hexchar
          out[outIndex++] = c
          break
        out[outIndex++] = 16 * n + m
    inIndex++
  
  # TODO support returning arbitrary buffers.
  out.slice 0, outIndex - 1

QueryString.unescape = (s, decodeSpaces) ->
  try
    return decodeURIComponent(s)
  catch e
    return QueryString.unescapeBuffer(s, decodeSpaces).toString()
  return

QueryString.escape = (str) ->
  encodeURIComponent str

stringifyPrimitive = (v) ->
  return v  if util.isString(v)
  return (if v then "true" else "false")  if util.isBoolean(v)
  return (if isFinite(v) then v else "")  if util.isNumber(v)
  ""

QueryString.stringify = QueryString.encode = (obj, sep, eq, options) ->
  sep = sep or "&"
  eq = eq or "="
  encode = QueryString.escape
  encode = options.encodeURIComponent  if options and typeof options.encodeURIComponent is "function"
  if util.isObject(obj)
    keys = Object.keys(obj)
    fields = []
    i = 0

    while i < keys.length
      k = keys[i]
      v = obj[k]
      ks = encode(stringifyPrimitive(k)) + eq
      if util.isArray(v)
        j = 0

        while j < v.length
          fields.push ks + encode(stringifyPrimitive(v[j]))
          j++
      else
        fields.push ks + encode(stringifyPrimitive(v))
      i++
    return fields.join(sep)
  ""


# Parse a key=val string.
QueryString.parse = QueryString.decode = (qs, sep, eq, options) ->
  sep = sep or "&"
  eq = eq or "="
  obj = {}
  return obj  if not util.isString(qs) or qs.length is 0
  regexp = /\+/g
  qs = qs.split(sep)
  maxKeys = 1000
  maxKeys = options.maxKeys  if options and util.isNumber(options.maxKeys)
  len = qs.length
  
  # maxKeys <= 0 means that we should not limit keys count
  len = maxKeys  if maxKeys > 0 and len > maxKeys
  decode = QueryString.unescape
  decode = options.decodeURIComponent  if options and typeof options.decodeURIComponent is "function"
  i = 0

  while i < len
    x = qs[i].replace(regexp, "%20")
    idx = x.indexOf(eq)
    kstr = undefined
    vstr = undefined
    k = undefined
    v = undefined
    if idx >= 0
      kstr = x.substr(0, idx)
      vstr = x.substr(idx + 1)
    else
      kstr = x
      vstr = ""
    try
      k = decode(kstr)
      v = decode(vstr)
    catch e
      k = QueryString.unescape(kstr, true)
      v = QueryString.unescape(vstr, true)
    unless hasOwnProperty(obj, k)
      obj[k] = v
    else if util.isArray(obj[k])
      obj[k].push v
    else
      obj[k] = [
        obj[k]
        v
      ]
    ++i
  obj
