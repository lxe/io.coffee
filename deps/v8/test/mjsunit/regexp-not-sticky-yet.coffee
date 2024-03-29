# Copyright 2014 the V8 project authors. All rights reserved.
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

# Test that sticky regexp support is not affecting V8 when the
# --harmony-regexps flag is not on.
assertThrows (->
  eval "/foo.bar/y"
  return
), SyntaxError
assertThrows (->
  eval "/foobar/y"
  return
), SyntaxError
assertThrows (->
  eval "/foo.bar/gy"
  return
), SyntaxError
assertThrows (->
  eval "/foobar/gy"
  return
), SyntaxError
assertThrows (->
  new RegExp("foo.bar", "y")
  return
), SyntaxError
assertThrows (->
  new RegExp("foobar", "y")
  return
), SyntaxError
assertThrows (->
  new RegExp("foo.bar", "gy")
  return
), SyntaxError
assertThrows (->
  new RegExp("foobar", "gy")
  return
), SyntaxError
re = /foo.bar/
assertEquals "/foo.bar/", "" + re
plain = /foobar/
assertEquals "/foobar/", "" + plain
re.compile "foo.bar"
assertEquals undefined, re.sticky
global = /foo.bar/g
assertEquals "/foo.bar/g", "" + global
plainglobal = /foobar/g
assertEquals "/foobar/g", "" + plainglobal
assertEquals undefined, re.sticky
re.sticky = true # Has no effect on the regexp, just sets a property.
assertTrue re.sticky
assertTrue re.test("..foo.bar")
re.lastIndex = -1 # Ignored for non-global, non-sticky.
assertTrue re.test("..foo.bar")
assertEquals -1, re.lastIndex
re.lastIndex = -1 # Ignored for non-global, non-sticky.
assertTrue !!re.exec("..foo.bar")
assertEquals -1, re.lastIndex
