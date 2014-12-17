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
n = null
u = undefined
assertTrue null is null
assertTrue null is n
assertTrue n is null
assertTrue n is n
assertFalse null is undefined
assertFalse undefined is null
assertFalse u is null
assertFalse null is u
assertFalse n is u
assertFalse u is n
assertTrue undefined is undefined
assertTrue u is u
assertTrue u is undefined
assertTrue undefined is u
assertTrue "foo" is "foo"
assertFalse "bar" is "foo"
assertFalse "foo" is new String("foo")
assertFalse new String("foo") is new String("foo")
s = new String("foo")
assertTrue s is s
assertFalse s is null
assertFalse s is undefined
assertFalse "foo" is null
assertFalse "foo" is 7
assertFalse "foo" is true
assertFalse "foo" is undefined
assertFalse "foo" is {}
assertFalse {} is {}
x = {}
assertTrue x is x
assertFalse x is null
assertFalse x is 7
assertFalse x is true
assertFalse x is undefined
assertFalse x is {}
assertTrue true is true
assertTrue false is false
assertFalse false is true
assertFalse true is false
assertFalse true is new Boolean(true)
assertFalse true is new Boolean(false)
assertFalse false is new Boolean(true)
assertFalse false is new Boolean(false)
assertFalse true is 0
assertFalse true is 1
assertTrue 0 is 0
assertTrue -0 is -0
assertTrue -0 is 0
assertTrue 0 is -0
assertFalse 0 is new Number(0)
assertFalse 1 is new Number(1)
assertTrue 4.2 is 4.2
assertTrue 4.2 is Number(4.2)
