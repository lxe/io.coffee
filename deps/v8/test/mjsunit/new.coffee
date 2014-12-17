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
Construct = (x) ->
  x
assertFalse null is new Construct(null)
assertFalse undefined is new Construct(undefined)
assertFalse 0 is new Construct(0)
assertFalse 1 is new Construct(1)
assertFalse 4.2 is new Construct(4.2)
assertFalse "foo" is new Construct("foo")
assertFalse true is new Construct(true)
x = {}
assertTrue x is new Construct(x)
assertFalse x is new Construct(null)
assertFalse x is new Construct(undefined)
assertFalse x is new Construct(1)
assertFalse x is new Construct(3.2)
assertFalse x is new Construct(false)
assertFalse x is new Construct("bar")
x = []
assertTrue x is new Construct(x)
x = new Boolean(true)
assertTrue x is new Construct(x)
x = new Number(42)
assertTrue x is new Construct(x)
x = new String("foo")
assertTrue x is new Construct(x)
x = ->

assertTrue x is new Construct(x)
