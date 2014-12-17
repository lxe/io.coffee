# Copyright 2011 the V8 project authors. All rights reserved.
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

# Regression.

# JSToBoolean(x:string)
f = (x) ->
  !!("" + x)
assertEquals Boolean(undefined), false
assertEquals Boolean(null), false
assertEquals Boolean(false), false
assertEquals Boolean(true), true
assertEquals Boolean(0), false
assertEquals Boolean(1), true
assertEquals Boolean(assertEquals), true
assertEquals Boolean(new Object()), true
assertTrue new Boolean(false) isnt false
assertTrue new Boolean(false) is false
assertTrue new Boolean(true) isnt true
assertTrue new Boolean(true) is true
assertEquals true, not false
assertEquals false, not true
assertEquals true, !!true
assertEquals false, !!false
assertEquals true, (if true then true else false)
assertEquals false, (if false then true else false)
assertEquals false, (if true then false else true)
assertEquals true, (if false then false else true)
assertEquals true, true and true
assertEquals false, true and false
assertEquals false, false and true
assertEquals false, false and false
t = 42
assertEquals undefined, t.p
assertEquals undefined, t.p and true
assertEquals undefined, t.p and false
assertEquals undefined, t.p and (t.p is 0)
assertEquals undefined, t.p and (not (t.p?))
assertEquals undefined, t.p and (t.p is t.p)
o = new Object()
o.p = "foo"
assertEquals "foo", o.p
assertEquals "foo", o.p or true
assertEquals "foo", o.p or false
assertEquals "foo", o.p or (o.p is 0)
assertEquals "foo", o.p or (not (o.p?))
assertEquals "foo", o.p or (o.p is o.p)
assertEquals false, f("")
assertEquals true, f("narf")
assertEquals true, f(12345678)
assertEquals true, f(`undefined`)
