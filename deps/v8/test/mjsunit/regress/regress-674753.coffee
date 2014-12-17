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

# Number
assertTrue typeof 0 is "number"
assertTrue typeof 0 is "number"
assertTrue typeof 1.2 is "number"
assertTrue typeof 1.2 is "number"
assertFalse typeof "x" is "number"
assertFalse typeof "x" is "number"

# String
assertTrue typeof "x" is "string"
assertTrue typeof "x" is "string"
assertTrue typeof ("x" + "x") is "string"
assertTrue typeof ("x" + "x") is "string"
assertFalse typeof 1 is "string"
assertFalse typeof 1 is "string"
assertFalse typeof Object() is "string"
assertFalse typeof Object() is "string"

# Boolean
assertTrue typeof true is "boolean"
assertTrue typeof true is "boolean"
assertTrue typeof false is "boolean"
assertTrue typeof false is "boolean"
assertFalse typeof 1 is "boolean"
assertFalse typeof 1 is "boolean"
assertFalse typeof Object() is "boolean"
assertFalse typeof Object() is "boolean"

# Undefined
assertTrue typeof undefined is "undefined"
assertTrue typeof undefined is "undefined"
assertFalse typeof 1 is "undefined"
assertFalse typeof 1 is "undefined"
assertFalse typeof Object() is "undefined"
assertFalse typeof Object() is "undefined"

# Function
assertTrue typeof Object is "function"
assertTrue typeof Object is "function"
assertFalse typeof 1 is "function"
assertFalse typeof 1 is "function"
assertFalse typeof Object() is "function"
assertFalse typeof Object() is "function"

# Object
assertTrue typeof Object() is "object"
assertTrue typeof Object() is "object"
assertTrue typeof new String("x") is "object"
assertTrue typeof new String("x") is "object"
assertTrue typeof ["x"] is "object"
assertTrue typeof ["x"] is "object"
assertTrue typeof null is "object"
assertTrue typeof null is "object"
assertFalse typeof 1 is "object"
assertFalse typeof 1 is "object"
assertFalse typeof "x" is "object" # bug #674753
assertFalse typeof "x" is "object"
assertFalse typeof Object is "object"
assertFalse typeof Object is "object"
