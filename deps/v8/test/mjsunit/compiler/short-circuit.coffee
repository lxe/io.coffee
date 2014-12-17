# Copyright 2009 the V8 project authors. All rights reserved.
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

# Test some expression contexts involving short-circuit boolean
# operations that did not otherwise have test coverage.
x = 42

# Literals in value/test context.
assertEquals x, ->
  0 or x
()
assertEquals 1, ->
  1 or x
()

# Literals in test/value context.
assertEquals 0, ->
  0 and x
()
assertEquals x, ->
  1 and x
()

# A value on top of the stack in value/test context.
assertEquals x, (y) ->
  y++ or x
(0)
assertEquals 1, (y) ->
  y++ or x
(1)

# A value on top of the stack in a test/value context.
assertEquals 0, (y) ->
  y++ and x
(0)
assertEquals x, (y) ->
  y++ and x
(1)

# An object literal in value context.
assertEquals 0, ->
  x: 0
().x

# An object literal in value/test context.
assertEquals 0, ->
  x: 0 or this
().x

# An object literal in test/value context.
assertEquals x, ->
  x: 0 and this
().x

# An array literal in value/test context.
assertEquals 0, ->
  [
    0
    1
  ] or new Array(x, 1)
()[0]

# An array literal in test/value context.
assertEquals x, ->
  [
    0
    1
  ] and new Array(x, 1)
()[0]

# Slot assignment in value/test context.
assertEquals x, (y) ->
  (y = 0) or x
("?")
assertEquals 1, (y) ->
  (y = 1) or x
("?")

# Slot assignment in test/value context.
assertEquals 0, (y) ->
  (y = 0) and x
("?")
assertEquals x, (y) ->
  (y = 1) and x
("?")

# void in value context.
assertEquals undefined, ->
  undefined
()

# void in value/test context.
assertEquals x, ->
  (undefined) or x
()

# void in test/value context.
assertEquals undefined, ->
  (undefined) and x
()

# Unary not in value context.
assertEquals false, ->
  not x
()

# Unary not in value/test context.
assertEquals true, (y) ->
  not y or x
(0)
assertEquals x, (y) ->
  not y or x
(1)

# Unary not in test/value context.
assertEquals x, (y) ->
  not y and x
(0)
assertEquals false, (y) ->
  not y and x
(1)

# Comparison in value context.
assertEquals false, ->
  x < x
()

# Comparison in value/test context.
assertEquals x, ->
  x < x or x
()
assertEquals true, ->
  x <= x or x
()

# Comparison in test/value context.
assertEquals false, ->
  x < x and x
()
assertEquals x, ->
  x <= x and x
()
