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

# test the internal isDate implementation

# test positive/negative zero

# test for sparse array

# test for property descriptors

# exceptions should print the error message, not '{}'

# GH-1941
# should not throw:

# GH-1944

# bug with user-supplied inspect function returns non-string

# GH-2225

# util.inspect should not display the escaped value of a key.

# util.inspect.styles and util.inspect.colors
test_color_style = (style, input, implicit) ->
  color_name = util.inspect.styles[style]
  color = [
    ""
    ""
  ]
  color = util.inspect.colors[color_name]  if util.inspect.colors[color_name]
  without_color = util.inspect(input, false, 0, false)
  with_color = util.inspect(input, false, 0, true)
  expect = "\u001b[" + color[0] + "m" + without_color + "\u001b[" + color[1] + "m"
  assert.equal with_color, expect, "util.inspect color for style " + style
  return

# an object with "hasOwnProperty" overwritten should not throw

# new API, accepts an "options" object

# "customInspect" option can enable/disable calling inspect() on objects

# custom inspect() functions should be able to return other Objects

# util.inspect with "colors" option should produce as many lines as without it
test_lines = (input) ->
  count_lines = (str) ->
    (str.match(/\n/g) or []).length

  without_color = util.inspect(input)
  with_color = util.inspect(input,
    colors: true
  )
  assert.equal count_lines(without_color), count_lines(with_color)
  return
common = require("../common")
assert = require("assert")
util = require("util")
Date2 = require("vm").runInNewContext("Date")
d = new Date2()
orig = util.inspect(d)
Date2::foo = "bar"
after = util.inspect(d)
assert.equal orig, after
assert.equal util.inspect(0), "0"
assert.equal util.inspect(-0), "-0"
a = [
  "foo"
  "bar"
  "baz"
]
assert.equal util.inspect(a), "[ 'foo', 'bar', 'baz' ]"
delete a[1]

assert.equal util.inspect(a), "[ 'foo', , 'baz' ]"
assert.equal util.inspect(a, true), "[ 'foo', , 'baz', [length]: 3 ]"
assert.equal util.inspect(new Array(5)), "[ , , , ,  ]"
getter = Object.create(null,
  a:
    get: ->
      "aaa"
)
setter = Object.create(null,
  b:
    set: ->
)
getterAndSetter = Object.create(null,
  c:
    get: ->
      "ccc"

    set: ->
)
assert.equal util.inspect(getter, true), "{ [a]: [Getter] }"
assert.equal util.inspect(setter, true), "{ [b]: [Setter] }"
assert.equal util.inspect(getterAndSetter, true), "{ [c]: [Getter/Setter] }"
assert.equal util.inspect(new Error()), "[Error]"
assert.equal util.inspect(new Error("FAIL")), "[Error: FAIL]"
assert.equal util.inspect(new TypeError("FAIL")), "[TypeError: FAIL]"
assert.equal util.inspect(new SyntaxError("FAIL")), "[SyntaxError: FAIL]"
try
  undef()
catch e
  assert.equal util.inspect(e), "[ReferenceError: undef is not defined]"
ex = util.inspect(new Error("FAIL"), true)
assert.ok ex.indexOf("[Error: FAIL]") isnt -1
assert.ok ex.indexOf("[stack]") isnt -1
assert.ok ex.indexOf("[message]") isnt -1
assert.equal util.inspect(Object.create(Date::)), "{}"
assert.doesNotThrow ->
  d = new Date()
  d.toUTCString = null
  util.inspect d
  return

assert.doesNotThrow ->
  r = /regexp/
  r.toString = null
  util.inspect r
  return

assert.doesNotThrow ->
  util.inspect [inspect: ->
    123
  ]
  return

x = inspect: util.inspect
assert.ok util.inspect(x).indexOf("inspect") isnt -1
w =
  "\\": 1
  "\\\\": 2
  "\\\\\\": 3
  "\\\\\\\\": 4

y = [
  "a"
  "b"
  "c"
]
y["\\\\\\"] = "d"
assert.ok util.inspect(w), "{ '\\': 1, '\\\\': 2, '\\\\\\': 3, '\\\\\\\\': 4 }"
assert.ok util.inspect(y), "[ 'a', 'b', 'c', '\\\\\\': 'd' ]"
test_color_style "special", ->

test_color_style "number", 123.456
test_color_style "boolean", true
test_color_style "undefined", `undefined`
test_color_style "null", null
test_color_style "string", "test string"
test_color_style "date", new Date
test_color_style "regexp", /regexp/
assert.doesNotThrow ->
  util.inspect hasOwnProperty: null
  return

subject =
  foo: "bar"
  hello: 31
  a:
    b:
      c:
        d: 0

Object.defineProperty subject, "hidden",
  enumerable: false
  value: null

assert util.inspect(subject,
  showHidden: false
).indexOf("hidden") is -1
assert util.inspect(subject,
  showHidden: true
).indexOf("hidden") isnt -1
assert util.inspect(subject,
  colors: false
).indexOf("\u001b[32m") is -1
assert util.inspect(subject,
  colors: true
).indexOf("\u001b[32m") isnt -1
assert util.inspect(subject,
  depth: 2
).indexOf("c: [Object]") isnt -1
assert util.inspect(subject,
  depth: 0
).indexOf("a: [Object]") isnt -1
assert util.inspect(subject,
  depth: null
).indexOf("{ d: 0 }") isnt -1
subject = inspect: ->
  123

assert util.inspect(subject,
  customInspect: true
).indexOf("123") isnt -1
assert util.inspect(subject,
  customInspect: true
).indexOf("inspect") is -1
assert util.inspect(subject,
  customInspect: false
).indexOf("123") is -1
assert util.inspect(subject,
  customInspect: false
).indexOf("inspect") isnt -1
subject.inspect = ->
  foo: "bar"

assert.equal util.inspect(subject), "{ foo: 'bar' }"
subject.inspect = (depth, opts) ->
  assert.strictEqual opts.customInspectOptions, true
  return

util.inspect subject,
  customInspectOptions: true

test_lines [
  1
  2
  3
  4
  5
  6
  7
]
test_lines ->
  big_array = []
  i = 0

  while i < 100
    big_array.push i
    i++
  big_array
()
test_lines
  foo: "bar"
  baz: 35
  b:
    a: 35

test_lines
  foo: "bar"
  baz: 35
  b:
    a: 35

  very_long_key: "very_long_value"
  even_longer_key: ["with even longer value in array"]


# test boxed primitives output the correct values
assert.equal util.inspect(new String("test")), "[String: 'test']"
assert.equal util.inspect(new Boolean(false)), "[Boolean: false]"
assert.equal util.inspect(new Boolean(true)), "[Boolean: true]"
assert.equal util.inspect(new Number(0)), "[Number: 0]"
assert.equal util.inspect(new Number(-0)), "[Number: -0]"
assert.equal util.inspect(new Number(-1.1)), "[Number: -1.1]"
assert.equal util.inspect(new Number(13.37)), "[Number: 13.37]"

# test boxed primitives with own properties
str = new String("baz")
str.foo = "bar"
assert.equal util.inspect(str), "{ [String: 'baz'] foo: 'bar' }"
bool = new Boolean(true)
bool.foo = "bar"
assert.equal util.inspect(bool), "{ [Boolean: true] foo: 'bar' }"
num = new Number(13.37)
num.foo = "bar"
assert.equal util.inspect(num), "{ [Number: 13.37] foo: 'bar' }"

# test es6 Symbol
if typeof Symbol isnt "undefined"
  assert.equal util.inspect(Symbol()), "Symbol()"
  assert.equal util.inspect(Symbol(123)), "Symbol(123)"
  assert.equal util.inspect(Symbol("hi")), "Symbol(hi)"
  assert.equal util.inspect([Symbol()]), "[ Symbol() ]"
  assert.equal util.inspect(foo: Symbol()), "{ foo: Symbol() }"
