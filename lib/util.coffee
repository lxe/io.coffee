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

# Mark that a method should not be used.
# Returns a modified function which warns once by default.
# If --no-deprecation is set, then it is a no-op.

# Allow for deprecating things in the process of starting up.

###*
Echos the value of a value. Trys to print the value out
in the best way possible given the different types.

@param {Object} obj The object to print out.
@param {Object} opts Optional options object that alters the output.
###

# legacy: obj, showHidden, depth, colors
inspect = (obj, opts) ->
  
  # default options
  ctx =
    seen: []
    stylize: stylizeNoColor

  
  # legacy...
  ctx.depth = arguments[2]  if arguments.length >= 3
  ctx.colors = arguments[3]  if arguments.length >= 4
  if isBoolean(opts)
    
    # legacy...
    ctx.showHidden = opts
  
  # got an "options" object
  else exports._extend ctx, opts  if opts
  
  # set default options
  ctx.showHidden = false  if isUndefined(ctx.showHidden)
  ctx.depth = 2  if isUndefined(ctx.depth)
  ctx.colors = false  if isUndefined(ctx.colors)
  ctx.customInspect = true  if isUndefined(ctx.customInspect)
  ctx.stylize = stylizeWithColor  if ctx.colors
  formatValue ctx, obj, ctx.depth

# http://en.wikipedia.org/wiki/ANSI_escape_code#graphics

# Don't use 'blue' not visible on cmd.exe

# "name": intentionally not styling
stylizeWithColor = (str, styleType) ->
  style = inspect.styles[styleType]
  if style
    "\u001b[" + inspect.colors[style][0] + "m" + str + "\u001b[" + inspect.colors[style][1] + "m"
  else
    str
stylizeNoColor = (str, styleType) ->
  str
arrayToHash = (array) ->
  hash = {}
  array.forEach (val, idx) ->
    hash[val] = true
    return

  hash
formatValue = (ctx, value, recurseTimes) ->
  
  # Provide a hook for user-specified inspect functions.
  # Check that value is an object with an inspect function on it
  
  # Filter out the util module, it's inspect function is special
  
  # Also filter out any prototype objects using the circular check.
  if ctx.customInspect and value and isFunction(value.inspect) and value.inspect isnt exports.inspect and not (value.constructor and value.constructor:: is value)
    ret = value.inspect(recurseTimes, ctx)
    ret = formatValue(ctx, ret, recurseTimes)  unless isString(ret)
    return ret
  
  # Primitive types cannot have properties
  primitive = formatPrimitive(ctx, value)
  return primitive  if primitive
  
  # Look up the keys of the object.
  keys = Object.keys(value)
  visibleKeys = arrayToHash(keys)
  keys = Object.getOwnPropertyNames(value)  if ctx.showHidden
  
  # This could be a boxed primitive (new String(), etc.), check valueOf()
  # NOTE: Avoid calling `valueOf` on `Date` instance because it will return
  # a number which, when object has some additional user-stored `keys`,
  # will be printed out.
  formatted = undefined
  raw = value
  try
    
    # the .valueOf() call can fail for a multitude of reasons
    raw = value.valueOf()  unless isDate(value)
  
  # ignore...
  if isString(raw)
    
    # for boxed Strings, we have to remove the 0-n indexed entries,
    # since they just noisey up the output and are redundant
    keys = keys.filter((key) ->
      not (key >= 0 and key < raw.length)
    )
  
  # Some type of object without properties can be shortcutted.
  if keys.length is 0
    if isFunction(value)
      name = (if value.name then ": " + value.name else "")
      return ctx.stylize("[Function" + name + "]", "special")
    return ctx.stylize(RegExp::toString.call(value), "regexp")  if isRegExp(value)
    return ctx.stylize(Date::toString.call(value), "date")  if isDate(value)
    return formatError(value)  if isError(value)
    
    # now check the `raw` value to handle boxed primitives
    if isString(raw)
      formatted = formatPrimitiveNoColor(ctx, raw)
      return ctx.stylize("[String: " + formatted + "]", "string")
    if isNumber(raw)
      formatted = formatPrimitiveNoColor(ctx, raw)
      return ctx.stylize("[Number: " + formatted + "]", "number")
    if isBoolean(raw)
      formatted = formatPrimitiveNoColor(ctx, raw)
      return ctx.stylize("[Boolean: " + formatted + "]", "boolean")
  base = ""
  array = false
  braces = [
    "{"
    "}"
  ]
  
  # Make Array say that they are Array
  if isArray(value)
    array = true
    braces = [
      "["
      "]"
    ]
  
  # Make functions say that they are functions
  if isFunction(value)
    n = (if value.name then ": " + value.name else "")
    base = " [Function" + n + "]"
  
  # Make RegExps say that they are RegExps
  base = " " + RegExp::toString.call(value)  if isRegExp(value)
  
  # Make dates with properties first say the date
  base = " " + Date::toUTCString.call(value)  if isDate(value)
  
  # Make error with message first say the error
  base = " " + formatError(value)  if isError(value)
  
  # Make boxed primitive Strings look like such
  if isString(raw)
    formatted = formatPrimitiveNoColor(ctx, raw)
    base = " " + "[String: " + formatted + "]"
  
  # Make boxed primitive Numbers look like such
  if isNumber(raw)
    formatted = formatPrimitiveNoColor(ctx, raw)
    base = " " + "[Number: " + formatted + "]"
  
  # Make boxed primitive Booleans look like such
  if isBoolean(raw)
    formatted = formatPrimitiveNoColor(ctx, raw)
    base = " " + "[Boolean: " + formatted + "]"
  return braces[0] + base + braces[1]  if keys.length is 0 and (not array or value.length is 0)
  if recurseTimes < 0
    if isRegExp(value)
      return ctx.stylize(RegExp::toString.call(value), "regexp")
    else
      return ctx.stylize("[Object]", "special")
  ctx.seen.push value
  output = undefined
  if array
    output = formatArray(ctx, value, recurseTimes, visibleKeys, keys)
  else
    output = keys.map((key) ->
      formatProperty ctx, value, recurseTimes, visibleKeys, key, array
    )
  ctx.seen.pop()
  reduceToSingleString output, base, braces
formatPrimitive = (ctx, value) ->
  return ctx.stylize("undefined", "undefined")  if isUndefined(value)
  if isString(value)
    simple = "'" + JSON.stringify(value).replace(/^"|"$/g, "").replace(/'/g, "\\'").replace(/\\"/g, "\"") + "'"
    return ctx.stylize(simple, "string")
  if isNumber(value)
    
    # Format -0 as '-0'. Strict equality won't distinguish 0 from -0,
    # so instead we use the fact that 1 / -0 < 0 whereas 1 / 0 > 0 .
    return ctx.stylize("-0", "number")  if value is 0 and 1 / value < 0
    return ctx.stylize("" + value, "number")
  return ctx.stylize("" + value, "boolean")  if isBoolean(value)
  
  # For some reason typeof null is "object", so special case here.
  return ctx.stylize("null", "null")  if isNull(value)
  
  # es6 symbol primitive
  ctx.stylize value.toString(), "symbol"  if isSymbol(value)
formatPrimitiveNoColor = (ctx, value) ->
  stylize = ctx.stylize
  ctx.stylize = stylizeNoColor
  str = formatPrimitive(ctx, value)
  ctx.stylize = stylize
  str
formatError = (value) ->
  "[" + Error::toString.call(value) + "]"
formatArray = (ctx, value, recurseTimes, visibleKeys, keys) ->
  output = []
  i = 0
  l = value.length

  while i < l
    if hasOwnProperty(value, String(i))
      output.push formatProperty(ctx, value, recurseTimes, visibleKeys, String(i), true)
    else
      output.push ""
    ++i
  keys.forEach (key) ->
    output.push formatProperty(ctx, value, recurseTimes, visibleKeys, key, true)  unless key.match(/^\d+$/)
    return

  output
formatProperty = (ctx, value, recurseTimes, visibleKeys, key, array) ->
  name = undefined
  str = undefined
  desc = undefined
  desc = Object.getOwnPropertyDescriptor(value, key) or value: value[key]
  if desc.get
    if desc.set
      str = ctx.stylize("[Getter/Setter]", "special")
    else
      str = ctx.stylize("[Getter]", "special")
  else
    str = ctx.stylize("[Setter]", "special")  if desc.set
  name = "[" + key + "]"  unless hasOwnProperty(visibleKeys, key)
  unless str
    if ctx.seen.indexOf(desc.value) < 0
      if isNull(recurseTimes)
        str = formatValue(ctx, desc.value, null)
      else
        str = formatValue(ctx, desc.value, recurseTimes - 1)
      if str.indexOf("\n") > -1
        if array
          str = str.split("\n").map((line) ->
            "  " + line
          ).join("\n").substr(2)
        else
          str = "\n" + str.split("\n").map((line) ->
            "   " + line
          ).join("\n")
    else
      str = ctx.stylize("[Circular]", "special")
  if isUndefined(name)
    return str  if array and key.match(/^\d+$/)
    name = JSON.stringify("" + key)
    if name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)
      name = name.substr(1, name.length - 2)
      name = ctx.stylize(name, "name")
    else
      name = name.replace(/'/g, "\\'").replace(/\\"/g, "\"").replace(/(^"|"$)/g, "'").replace(/\\\\/g, "\\")
      name = ctx.stylize(name, "string")
  name + ": " + str
reduceToSingleString = (output, base, braces) ->
  length = output.reduce((prev, cur) ->
    prev + cur.replace(/\u001b\[\d\d?m/g, "").length + 1
  , 0)
  return braces[0] + ((if base is "" then "" else base + "\n ")) + " " + output.join(",\n  ") + " " + braces[1]  if length > 60
  braces[0] + base + " " + output.join(", ") + " " + braces[1]

# NOTE: These type checking functions intentionally don't use `instanceof`
# because it is fragile and can be easily faked with `Object.create()`.
isBoolean = (arg) ->
  typeof arg is "boolean"
isNull = (arg) ->
  arg is null
isNullOrUndefined = (arg) ->
  not arg?
isNumber = (arg) ->
  typeof arg is "number"
isString = (arg) ->
  typeof arg is "string"
isSymbol = (arg) ->
  typeof arg is "symbol"
isUndefined = (arg) ->
  arg is undefined
isRegExp = (re) ->
  isObject(re) and objectToString(re) is "[object RegExp]"
isObject = (arg) ->
  typeof arg is "object" and arg isnt null
isDate = (d) ->
  isObject(d) and objectToString(d) is "[object Date]"
isError = (e) ->
  isObject(e) and (objectToString(e) is "[object Error]" or e instanceof Error)
isFunction = (arg) ->
  typeof arg is "function"
isPrimitive = (arg) ->
  # ES6 symbol
  arg is null or typeof arg is "boolean" or typeof arg is "number" or typeof arg is "string" or typeof arg is "symbol" or typeof arg is "undefined"
isBuffer = (arg) ->
  arg instanceof Buffer
objectToString = (o) ->
  Object::toString.call o
pad = (n) ->
  (if n < 10 then "0" + n.toString(10) else n.toString(10))

# 26 Feb 16:19:34
timestamp = ->
  d = new Date()
  time = [
    pad(d.getHours())
    pad(d.getMinutes())
    pad(d.getSeconds())
  ].join(":")
  [
    d.getDate()
    months[d.getMonth()]
    time
  ].join " "

# log is just a thin wrapper to console.log that prepends a timestamp

###*
Inherit the prototype methods from one constructor into another.

The Function.prototype.inherits from lang.js rewritten as a standalone
function (not on Function.prototype). NOTE: If this file is to be loaded
during bootstrapping this function needs to be rewritten using some native
functions as prototype setup using normal JavaScript does not work as
expected during bootstrapping (see mirror.js in r114903).

@param {function} ctor Constructor function which needs to inherit the
prototype.
@param {function} superCtor Constructor function to inherit prototype from.
###

# Don't do anything if add isn't an object
hasOwnProperty = (obj, prop) ->
  Object::hasOwnProperty.call obj, prop
"use strict"
formatRegExp = /%[sdj%]/g
exports.format = (f) ->
  unless isString(f)
    objects = []
    i = 0

    while i < arguments.length
      objects.push inspect(arguments[i])
      i++
    return objects.join(" ")
  i = 1
  args = arguments
  len = args.length
  str = String(f).replace(formatRegExp, (x) ->
    return "%"  if x is "%"
    return x  if i >= len
    switch x
      when "%s"
        String args[i++]
      when "%d"
        Number args[i++]
      when "%j"
        try
          return JSON.stringify(args[i++])
        catch _
          return "[Circular]"
      else
        x
    return
  )
  x = args[i]

  while i < len
    if isNull(x) or not isObject(x)
      str += " " + x
    else
      str += " " + inspect(x)
    x = args[++i]
  str

exports.deprecate = (fn, msg) ->
  deprecated = ->
    unless warned
      if process.throwDeprecation
        throw new Error(msg)
      else if process.traceDeprecation
        console.trace msg
      else
        console.error msg
      warned = true
    fn.apply this, arguments
  if isUndefined(global.process)
    return ->
      exports.deprecate(fn, msg).apply this, arguments
  return fn  if process.noDeprecation is true
  warned = false
  deprecated

debugs = {}
debugEnviron = undefined
exports.debuglog = (set) ->
  debugEnviron = process.env.NODE_DEBUG or ""  if isUndefined(debugEnviron)
  set = set.toUpperCase()
  unless debugs[set]
    if new RegExp("\\b" + set + "\\b", "i").test(debugEnviron)
      pid = process.pid
      debugs[set] = ->
        msg = exports.format.apply(exports, arguments)
        console.error "%s %d: %s", set, pid, msg
        return
    else
      debugs[set] = ->
  debugs[set]

exports.inspect = inspect
inspect.colors =
  bold: [
    1
    22
  ]
  italic: [
    3
    23
  ]
  underline: [
    4
    24
  ]
  inverse: [
    7
    27
  ]
  white: [
    37
    39
  ]
  grey: [
    90
    39
  ]
  black: [
    30
    39
  ]
  blue: [
    34
    39
  ]
  cyan: [
    36
    39
  ]
  green: [
    32
    39
  ]
  magenta: [
    35
    39
  ]
  red: [
    31
    39
  ]
  yellow: [
    33
    39
  ]

inspect.styles =
  special: "cyan"
  number: "yellow"
  boolean: "yellow"
  undefined: "grey"
  null: "bold"
  string: "green"
  symbol: "green"
  date: "magenta"
  regexp: "red"

isArray = exports.isArray = Array.isArray
exports.isBoolean = isBoolean
exports.isNull = isNull
exports.isNullOrUndefined = isNullOrUndefined
exports.isNumber = isNumber
exports.isString = isString
exports.isSymbol = isSymbol
exports.isUndefined = isUndefined
exports.isRegExp = isRegExp
exports.isObject = isObject
exports.isDate = isDate
exports.isError = isError
exports.isFunction = isFunction
exports.isPrimitive = isPrimitive
exports.isBuffer = isBuffer
months = [
  "Jan"
  "Feb"
  "Mar"
  "Apr"
  "May"
  "Jun"
  "Jul"
  "Aug"
  "Sep"
  "Oct"
  "Nov"
  "Dec"
]
exports.log = ->
  console.log "%s - %s", timestamp(), exports.format.apply(exports, arguments)
  return

exports.inherits = (ctor, superCtor) ->
  ctor.super_ = superCtor
  ctor:: = Object.create(superCtor::,
    constructor:
      value: ctor
      enumerable: false
      writable: true
      configurable: true
  )
  return

exports._extend = (origin, add) ->
  return origin  if not add or not isObject(add)
  keys = Object.keys(add)
  i = keys.length
  origin[keys[i]] = add[keys[i]]  while i--
  origin


# Deprecated old stuff.
exports.p = exports.deprecate(->
  i = 0
  len = arguments.length

  while i < len
    console.error exports.inspect(arguments[i])
    ++i
  return
, "util.p: Use console.error() instead")
exports.exec = exports.deprecate(->
  require("child_process").exec.apply this, arguments
, "util.exec is now called `child_process.exec`.")
exports.print = exports.deprecate(->
  i = 0
  len = arguments.length

  while i < len
    process.stdout.write String(arguments[i])
    ++i
  return
, "util.print: Use console.log instead")
exports.puts = exports.deprecate(->
  i = 0
  len = arguments.length

  while i < len
    process.stdout.write arguments[i] + "\n"
    ++i
  return
, "util.puts: Use console.log instead")
exports.debug = exports.deprecate((x) ->
  process.stderr.write "DEBUG: " + x + "\n"
  return
, "util.debug: Use console.error instead")
exports.error = exports.deprecate((x) ->
  i = 0
  len = arguments.length

  while i < len
    process.stderr.write arguments[i] + "\n"
    ++i
  return
, "util.error: Use console.error instead")
exports.pump = exports.deprecate((readStream, writeStream, callback) ->
  call = (a, b, c) ->
    if callback and not callbackCalled
      callback a, b, c
      callbackCalled = true
    return
  callbackCalled = false
  readStream.addListener "data", (chunk) ->
    readStream.pause()  if writeStream.write(chunk) is false
    return

  writeStream.addListener "drain", ->
    readStream.resume()
    return

  readStream.addListener "end", ->
    writeStream.end()
    return

  readStream.addListener "close", ->
    call()
    return

  readStream.addListener "error", (err) ->
    writeStream.end()
    call err
    return

  writeStream.addListener "error", (err) ->
    readStream.destroy()
    call err
    return

  return
, "util.pump(): Use readableStream.pipe() instead")
uv = undefined
exports._errnoException = (err, syscall, original) ->
  uv = process.binding("uv")  if isUndefined(uv)
  errname = uv.errname(err)
  message = syscall + " " + errname
  message += " " + original  if original
  e = new Error(message)
  e.code = errname
  e.errno = errname
  e.syscall = syscall
  e
