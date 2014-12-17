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
TestObject = ->
  @toString = ->
    @test

  @test = "FAIL"
  this
assign_test1 = ->
  testObject = new TestObject
  a = testObject
  a.test = "PASS"
  testObject.test
assign_test2 = ->
  testObject = new TestObject
  a = testObject
  a = a.test = "PASS"
  testObject.test
assign_test3 = ->
  testObject = new TestObject
  a = testObject
  a.test = a = "PASS"
  testObject.test
assign_test6 = ->
  testObject = new TestObject
  a = testObject
  a["test"] = "PASS"
  testObject.test
assign_test7 = ->
  testObject = new TestObject
  a = testObject
  a = a["test"] = "PASS"
  testObject.test
assign_test8 = ->
  testObject = new TestObject
  a = testObject
  a["test"] = a = "PASS"
  testObject.test
assign_test9 = ->
  testObject = new TestObject
  a = testObject
  a["test"] = @a = "PASS"
  testObject.test
assign_test11 = ->
  testObject = new TestObject
  a = testObject
  a[a = "test"] = "PASS"
  testObject.test
assign_test12 = ->
  test = "test"
  testObject = new TestObject
  a = testObject
  a[test] = "PASS"
  testObject.test
assign_test13 = ->
  testObject = new TestObject
  a = testObject
  a.test = (a = "FAIL"
  "PASS"
  )
  testObject.test
assign_test14 = ->
  testObject = new TestObject
  a = testObject
  a["test"] = (a = "FAIL"
  "PASS"
  )
  testObject.test
assign_test15 = ->
  test = "test"
  testObject = new TestObject
  a = testObject
  a[test] = (test = "FAIL"
  "PASS"
  )
  testObject.test
assign_test16 = ->
  a = 1
  a = (a = 2)
  a
assign_test18 = ->
  a = 1
  a += (a += 1)
  a
assign_test20 = ->
  a = b: 1
  a.b += (a.b += 1)
  a.b
assign_test22 = ->
  a = b: 1
  a["b"] += (a["b"] += 1)
  a["b"]
assign_test23 = ->
  o = b: 1
  a = o
  a.b += a = 2
  o.b
assign_test24 = ->
  o = b: 1
  a = o
  a["b"] += a = 2
  o["b"]
assign_test25 = ->
  o = b: 1
  a = o
  a[a = "b"] += a = 2
  o["b"]
assign_test26 = ->
  o = b: 1
  a = o
  b = "b"
  a[b] += a = 2
  o["b"]
assign_test27 = ->
  o = b: 1
  a = o
  a.b += (a = 100
  2
  )
  o.b
assign_test28 = ->
  o = b: 1
  a = o
  a["b"] += (a = 100
  2
  )
  o["b"]
assign_test29 = ->
  o = b: 1
  a = o
  b = "b"
  a[b] += (a = 100
  2
  )
  o["b"]
assign_test30 = ->
  a = "foo"
  a += (a++)
  a
assign_test31 = ->
  result = ->
    "PASS"
  (globalVar = result)()
bracket_test1 = ->
  o = [-1]
  a = o[++o]
  a
bracket_test2 = ->
  o = [1]
  a = o[--o]
  a
bracket_test3 = ->
  o = [0]
  a = o[o++]
  a
bracket_test4 = ->
  o = [0]
  a = o[o--]
  a
bracket_test5 = ->
  o = [1]
  a = o[o ^= 1]
  a
bracket_test6 = ->
  o = b: 1
  b = o[o = b: 2
  "b"
  ]
  b
mult_test1 = ->
  a = 1
  a * (a = 2)
mult_test2 = ->
  a = 1
  a * ++a
mult_test3 = ->
  a = 1
  a * (a += 1)
div_test1 = ->
  a = 1
  a / (a = 2)
div_test2 = ->
  a = 1
  a / ++a
div_test3 = ->
  a = 1
  a / (a += 1)
mod_test1 = ->
  a = 1
  a % (a = 2)
mod_test2 = ->
  a = 1
  a % ++a
mod_test3 = ->
  a = 1
  a % (a += 1)
add_test1 = ->
  a = 1
  a + (a = 2)
add_test2 = ->
  a = 1
  a + ++a
add_test3 = ->
  a = 1
  a + (a += 1)
sub_test1 = ->
  a = 1
  a - (a = 2)
sub_test2 = ->
  a = 1
  a - ++a
sub_test3 = ->
  a = 1
  a - (a += 1)
lshift_test1 = ->
  a = 1
  a << (a = 2)
lshift_test2 = ->
  a = 1
  a << ++a
lshift_test3 = ->
  a = 1
  a << (a += 1)
rshift_test1 = ->
  a = 4
  a >> (a = 2)
rshift_test2 = ->
  a = 2
  a >> --a
rshift_test3 = ->
  a = 2
  a >> (a -= 1)
urshift_test1 = ->
  a = 4
  a >>> (a = 2)
urshift_test2 = ->
  a = 2
  a >>> --a
urshift_test3 = ->
  a = 2
  a >>> (a -= 1)
less_test1 = ->
  a = 1
  a < (a = 2)
less_test2 = ->
  a = 1
  a < ++a
less_test3 = ->
  a = 1
  a < (a += 1)
greater_test1 = ->
  a = 2
  a > (a = 1)
greater_test2 = ->
  a = 2
  a > --a
greater_test3 = ->
  a = 2
  a > (a -= 1)
lesseq_test1 = ->
  a = 1
  a <= (a = 3
  2
  )
lesseq_test2 = ->
  a = 1
  a <= (++a
  1
  )
lesseq_test3 = ->
  a = 1
  a <= (a += 1
  1
  )
greatereq_test1 = ->
  a = 2
  a >= (a = 1
  2
  )
greatereq_test2 = ->
  a = 2
  a >= (--a
  2
  )
greatereq_test3 = ->
  a = 2
  a >= (a -= 1
  2
  )
instanceof_test1 = ->
  a = {}
  a instanceof (a = 1
  Object
  )
instanceof_test2 = ->
  a = valueOf: ->
    1

  a instanceof (++a
  Object
  )
instanceof_test3 = ->
  a = valueOf: ->
    1

  a instanceof (a += 1
  Object
  )
in_test1 = ->
  a = "a"
  a of (a = "b"
  a: 1
  )
in_test2 = ->
  a =
    toString: ->
      "a"

    valueOf: ->
      1

  a of (++a
  a: 1
  )
in_test3 = ->
  a =
    toString: ->
      "a"

    valueOf: ->
      1

  a of (a += 1
  a: 1
  )
eq_test1 = ->
  a = 1
  a is (a = 2)
eq_test2 = ->
  a = 1
  a is ++a
eq_test3 = ->
  a = 1
  a is (a += 1)
neq_test1 = ->
  a = 1
  a isnt (a = 2)
neq_test2 = ->
  a = 1
  a isnt ++a
neq_test3 = ->
  a = 1
  a isnt (a += 1)
stricteq_test1 = ->
  a = 1
  a is (a = 2)
stricteq_test2 = ->
  a = 1
  a is ++a
stricteq_test3 = ->
  a = 1
  a is (a += 1)
nstricteq_test1 = ->
  a = 1
  a isnt (a = 2)
nstricteq_test2 = ->
  a = 1
  a isnt ++a
nstricteq_test3 = ->
  a = 1
  a isnt (a += 1)
bitand_test1 = ->
  a = 1
  a & (a = 2)
bitand_test2 = ->
  a = 1
  a & ++a
bitand_test3 = ->
  a = 1
  a & (a += 1)
bitor_test1 = ->
  a = 1
  a | (a = 2)
bitor_test2 = ->
  a = 1
  a | ++a
bitor_test3 = ->
  a = 1
  a | (a += 1)
bitxor_test1 = ->
  a = 1
  a ^ (a = 2)
bitxor_test2 = ->
  a = 1
  a ^ ++a
bitxor_test3 = ->
  a = 1
  a ^ (a += 1)
switch_test1_helper = (a, b) ->
  switch a
    when b
    else
  b
switch_test1 = ->
  switch_test1_helper(0, 1) is 1
switch_test2_helper = (a, b) ->
  c = b
  switch a
    when c
    else
  c
switch_test2 = ->
  switch_test2_helper(0, 1) is 1
switch_test3_helper = (a) ->
  switch a
    when this
    else
  this
switch_test3 = ->
  this is switch_test3_helper.call(this, 0)
construct_test = ->
  f = ->
    new c[0](true)
  c = [(a) ->
    @a = a
    return
  ]
  f().a
description "Tests whether bytecode codegen properly handles temporaries."
a = true
a = false or a
shouldBeTrue "a"
b = false
b = true and b
shouldBeFalse "b"
shouldBe "assign_test1()", "'PASS'"
shouldBe "assign_test2()", "'PASS'"
shouldBe "assign_test3()", "'PASS'"
testObject4 = new TestObject
a4 = testObject4
a4.test = @a4 = "PASS"
shouldBe "testObject4.test", "'PASS'"
testObject5 = new TestObject
a5 = testObject5
a5 = @a5.test = "PASS"
shouldBe "testObject5.test", "'PASS'"
shouldBe "assign_test6()", "'PASS'"
shouldBe "assign_test7()", "'PASS'"
shouldBe "assign_test8()", "'PASS'"
shouldBe "assign_test9()", "'PASS'"
testObject10 = new TestObject
a10 = testObject10
a10 = @a10["test"] = "PASS"
shouldBe "testObject10.test", "'PASS'"
shouldBe "assign_test11()", "'PASS'"
shouldBe "assign_test12()", "'PASS'"
shouldBe "assign_test13()", "'PASS'"
shouldBe "assign_test14()", "'PASS'"
shouldBe "assign_test15()", "'PASS'"
shouldBe "assign_test16()", "2"
a17 = 1
a17 += (a17 += 1)
shouldBe "a17", "3"
shouldBe "assign_test18()", "3"
a19 = b: 1
a19.b += (a19.b += 1)
shouldBe "a19.b", "3"
shouldBe "assign_test20()", "3"
a21 = b: 1
a21["b"] += (a21["b"] += 1)
shouldBe "a21['b']", "3"
shouldBe "assign_test22()", "3"
shouldBe "assign_test23()", "3"
shouldBe "assign_test24()", "3"
shouldBe "assign_test25()", "3"
shouldBe "assign_test26()", "3"
shouldBe "assign_test27()", "3"
shouldBe "assign_test28()", "3"
shouldBe "assign_test29()", "3"
shouldBe "assign_test30()", "'fooNaN'"
shouldBe "assign_test31()", "'PASS'"
shouldBe "bracket_test1()", "-1"
shouldBe "bracket_test2()", "1"
shouldBe "bracket_test3()", "0"
shouldBe "bracket_test4()", "0"
shouldBe "bracket_test5()", "1"
shouldBe "bracket_test6()", "1"
shouldBe "mult_test1()", "2"
shouldBe "mult_test2()", "2"
shouldBe "mult_test3()", "2"
shouldBe "div_test1()", "0.5"
shouldBe "div_test2()", "0.5"
shouldBe "div_test3()", "0.5"
shouldBe "mod_test1()", "1"
shouldBe "mod_test2()", "1"
shouldBe "mod_test3()", "1"
shouldBe "add_test1()", "3"
shouldBe "add_test2()", "3"
shouldBe "add_test3()", "3"
shouldBe "sub_test1()", "-1"
shouldBe "sub_test2()", "-1"
shouldBe "sub_test3()", "-1"
shouldBe "lshift_test1()", "4"
shouldBe "lshift_test2()", "4"
shouldBe "lshift_test3()", "4"
shouldBe "rshift_test1()", "1"
shouldBe "rshift_test2()", "1"
shouldBe "rshift_test3()", "1"
shouldBe "urshift_test1()", "1"
shouldBe "urshift_test2()", "1"
shouldBe "urshift_test3()", "1"
shouldBeTrue "less_test1()"
shouldBeTrue "less_test2()"
shouldBeTrue "less_test3()"
shouldBeTrue "greater_test1()"
shouldBeTrue "greater_test2()"
shouldBeTrue "greater_test3()"
shouldBeTrue "lesseq_test1()"
shouldBeTrue "lesseq_test2()"
shouldBeTrue "lesseq_test3()"
shouldBeTrue "greatereq_test1()"
shouldBeTrue "greatereq_test2()"
shouldBeTrue "greatereq_test3()"
shouldBeTrue "instanceof_test1()"
shouldBeTrue "instanceof_test2()"
shouldBeTrue "instanceof_test3()"
shouldBeTrue "in_test1()"
shouldBeTrue "in_test2()"
shouldBeTrue "in_test3()"
shouldBeFalse "eq_test1()"
shouldBeFalse "eq_test2()"
shouldBeFalse "eq_test3()"
shouldBeTrue "neq_test1()"
shouldBeTrue "neq_test2()"
shouldBeTrue "neq_test3()"
shouldBeFalse "stricteq_test1()"
shouldBeFalse "stricteq_test2()"
shouldBeFalse "stricteq_test3()"
shouldBeTrue "nstricteq_test1()"
shouldBeTrue "nstricteq_test2()"
shouldBeTrue "nstricteq_test3()"
shouldBe "bitand_test1()", "0"
shouldBe "bitand_test2()", "0"
shouldBe "bitand_test3()", "0"
shouldBe "bitor_test1()", "3"
shouldBe "bitor_test2()", "3"
shouldBe "bitor_test3()", "3"
shouldBe "bitxor_test1()", "3"
shouldBe "bitxor_test2()", "3"
shouldBe "bitxor_test3()", "3"
shouldBeTrue "switch_test1()"
shouldBeTrue "switch_test2()"
shouldBeTrue "switch_test3()"
shouldBeTrue "construct_test()"
testStr = "["
i = 0

while i < 64
  testStr += "(0/0), "
  i++
testStr += "].length"
shouldBe testStr, "64"
