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
description "This test checks that deletion of properties works properly with getters and setters."
b1 = 1
@__defineSetter__ "a1", ->

@__defineSetter__ "b1", ->

delete a1

shouldThrow "b1.property"
a2 = 1
@__defineSetter__ "a2", ->

@__defineSetter__ "b2", ->

delete b2

shouldThrow "a2.property"
b3 = 1
@__defineGetter__ "a3", ->

@__defineGetter__ "b3", ->

delete a3

shouldThrow "b3.property"
a4 = 1
@__defineGetter__ "a4", ->

@__defineGetter__ "b4", ->

delete b4

shouldThrow "a4.property"
b5 = 1
@__defineSetter__ "a5", ->

@__defineGetter__ "b5", ->

delete a5

shouldThrow "b5.property"
a6 = 1
@__defineSetter__ "a6", ->

@__defineGetter__ "b6", ->

delete b6

shouldThrow "a6.property"
b7 = 1
@__defineGetter__ "a7", ->

@__defineSetter__ "b7", ->

delete a7

shouldThrow "b7.property"
a8 = 1
@__defineGetter__ "a8", ->

@__defineSetter__ "b8", ->

delete b8

shouldThrow "a8.property"
o1 = b: 1
o1.__defineSetter__ "a", ->

o1.__defineSetter__ "b", ->

delete o1.a

shouldThrow "o1.b.property"
o2 = a: 1
o2.__defineSetter__ "a", ->

o2.__defineSetter__ "b", ->

delete o2.b

shouldThrow "o1.a.property"
o3 = b: 1
o3.__defineGetter__ "a", ->

o3.__defineGetter__ "b", ->

delete o3.a

shouldThrow "o3.b.property"
o4 = a: 1
o4.__defineGetter__ "a", ->

o4.__defineGetter__ "b", ->

delete o4.b

shouldThrow "o4.a.property"
o5 = b: 1
o5.__defineSetter__ "a", ->

o5.__defineSetter__ "b", ->

delete o5.a

shouldThrow "o5.b.property"
o6 = a: 1
o6.__defineSetter__ "a", ->

o6.__defineSetter__ "b", ->

delete o6.b

shouldThrow "o6.a.property"
o7 = b: 1
o7.__defineGetter__ "a", ->

o7.__defineGetter__ "b", ->

delete o7.a

shouldThrow "o7.b.property"
o8 = a: 1
o8.__defineGetter__ "a", ->

o8.__defineGetter__ "b", ->

delete o8.b

shouldThrow "o8.a.property"
