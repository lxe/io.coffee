# Copyright 2010 the V8 project authors. All rights reserved.
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

# Add property a with getter/setter.

# Add property b with getter/setter.
getB = ->
  try
    y.x = 30
  catch e
    assertEquals 3, e.stack.split("\n").length
  30
setB = (val) ->
  try
    y.x = 30
  catch e
    assertEquals 3, e.stack.split("\n").length
  return
x = {}
x.__defineGetter__ "a", ->
  try
    y.x = 40
  catch e
    assertEquals 3, e.stack.split("\n").length
  40

x.__defineSetter__ "a", (val) ->
  try
    y.x = 40
  catch e
    assertEquals 3, e.stack.split("\n").length
  return

x.__defineGetter__ "b", getB
x.__defineSetter__ "b", setB

# Add property c with getter/setter.
descriptor =
  get: ->
    try
      y.x = 40
    catch e
      assertEquals 3, e.stack.split("\n").length
    40

  set: (val) ->
    try
      y.x = 40
    catch e
      assertEquals 3, e.stack.split("\n").length
    return

Object.defineProperty x, "c", descriptor

# Check that the stack for an exception in a getter and setter produce the
# expected stack height.
x.a
x.b
x.c
x.a = 1
x.b = 1
x.c = 1

# Do the same with the getters/setters on the a prototype object.
xx = {}
xx.__proto__ = x
xx.a
xx.b
xx.c
xx.a = 1
xx.b = 1
xx.c = 1
