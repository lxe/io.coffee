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

# Test references and assignments to global variables.

# Test compilation of a global variable store.

# Test that the store worked.

# Test that patching the IC in the compiled code works.

# Test a second store.

# Test a load.

# Test that patching the IC in the compiled code works.

# Test a second load.

# Test postfix count operation

# Test simple assignment to non-deletable and deletable globals.
f1 = (x) ->
  glo1 = x
  return
f2 = (x) ->
  glo2 = x
  return
g = 0
assertEquals 1, eval("g = 1")
assertEquals 1, g
assertEquals 1, eval("g = 1")
assertEquals 1, g
assertEquals 1, eval("g = 1")
assertEquals 1, g
assertEquals "2", eval("g = \"2\"")
assertEquals "2", g
assertEquals "2", eval("g")
assertEquals "2", eval("g")
assertEquals "2", eval("g")
g = 3
assertEquals 3, eval("g")
t = undefined
t = g++
assertEquals 3, t
assertEquals 4, g
code = "g--; 1"
assertEquals 1, eval(code)
assertEquals 3, g
glo1 = 0
f1 42
assertEquals glo1, 42
glo2 = 0
f2 42
assertEquals 42, glo2
