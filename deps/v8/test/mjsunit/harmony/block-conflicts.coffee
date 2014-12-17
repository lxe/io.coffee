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

# Flags: --harmony-scoping

# Test for conflicting variable bindings.
CheckException = (e) ->
  string = e.toString()
  assertTrue string.indexOf("has already been declared") >= 0 or string.indexOf("redeclaration") >= 0
  "Conflict"
TestGlobal = (s, e) ->
  try
    return eval(s + e)
  catch x
    return CheckException(x)
  return
TestFunction = (s, e) ->
  try
    return eval("(function(){" + s + " return " + e + "})")()
  catch x
    return CheckException(x)
  return
TestBlock = (s, e) ->
  try
    return eval("(function(){ {" + s + "} return " + e + "})")()
  catch x
    return CheckException(x)
  return
TestAll = (expected, s, opt_e) ->
  e = ""
  msg = s
  if opt_e
    e = opt_e
    msg += opt_e
  assertEquals (if expected is "LocalConflict" then "NoConflict" else expected), TestGlobal(s, e), "global:'" + msg + "'"
  assertEquals (if expected is "LocalConflict" then "NoConflict" else expected), TestFunction(s, e), "function:'" + msg + "'"
  assertEquals (if expected is "LocalConflict" then "Conflict" else expected), TestBlock(s, e), "block:'" + msg + "'"
  return
TestConflict = (s) ->
  TestAll "Conflict", s
  TestAll "Conflict", "eval(\"" + s + "\");"
  return
TestNoConflict = (s) ->
  TestAll "NoConflict", s, "'NoConflict'"
  TestAll "NoConflict", "eval(\"" + s + "\");", "'NoConflict'"
  return
TestLocalConflict = (s) ->
  TestAll "LocalConflict", s, "'NoConflict'"
  TestAll "NoConflict", "eval(\"" + s + "\");", "'NoConflict'"
  return
"use strict"
letbinds = [
  "let x;"
  "let x = 0;"
  "let x = undefined;"
  "let x = function() {};"
  "let x, y;"
  "let y, x;"
  "const x = 0;"
  "const x = undefined;"
  "const x = function() {};"
  "const x = 2, y = 3;"
  "const y = 4, x = 5;"
]
varbinds = [
  "var x;"
  "var x = 0;"
  "var x = undefined;"
  "var x = function() {};"
  "var x, y;"
  "var y, x;"
]
funbind = "function x() {}"
l = 0

while l < letbinds.length
  
  # Test conflicting let/var bindings.
  v = 0

  while v < varbinds.length
    
    # Same level.
    TestConflict letbinds[l] + varbinds[v]
    TestConflict varbinds[v] + letbinds[l]
    
    # Different level.
    TestConflict letbinds[l] + "{" + varbinds[v] + "}"
    TestConflict "{" + varbinds[v] + "}" + letbinds[l]
    TestNoConflict varbinds[v] + "{" + letbinds[l] + "}"
    TestNoConflict "{" + letbinds[l] + "}" + varbinds[v]
    
    # For loop.
    TestConflict "for (" + letbinds[l] + "0;) {" + varbinds[v] + "}"
    TestNoConflict "for (" + varbinds[v] + "0;) {" + letbinds[l] + "}"
    ++v
  
  # Test conflicting let/let bindings.
  k = 0

  while k < letbinds.length
    
    # Same level.
    TestConflict letbinds[l] + letbinds[k]
    TestConflict letbinds[k] + letbinds[l]
    
    # Different level.
    TestNoConflict letbinds[l] + "{ " + letbinds[k] + "}"
    TestNoConflict "{" + letbinds[k] + "} " + letbinds[l]
    
    # For loop.
    TestNoConflict "for (" + letbinds[l] + "0;) {" + letbinds[k] + "}"
    TestNoConflict "for (" + letbinds[k] + "0;) {" + letbinds[l] + "}"
    ++k
  
  # Test conflicting function/let bindings.
  # Same level.
  TestConflict letbinds[l] + funbind
  TestConflict funbind + letbinds[l]
  
  # Different level.
  TestNoConflict letbinds[l] + "{" + funbind + "}"
  TestNoConflict "{" + funbind + "}" + letbinds[l]
  TestNoConflict funbind + "{" + letbinds[l] + "}"
  TestNoConflict "{" + letbinds[l] + "}" + funbind
  
  # For loop.
  TestNoConflict "for (" + letbinds[l] + "0;) {" + funbind + "}"
  
  # Test conflicting parameter/let bindings.
  TestConflict "(function(x) {" + letbinds[l] + "})();"
  ++l

# Test conflicting function/var bindings.
v = 0

while v < varbinds.length
  
  # Same level.
  TestLocalConflict varbinds[v] + funbind
  TestLocalConflict funbind + varbinds[v]
  
  # Different level.
  TestLocalConflict funbind + "{" + varbinds[v] + "}"
  TestLocalConflict "{" + varbinds[v] + "}" + funbind
  TestNoConflict varbinds[v] + "{" + funbind + "}"
  TestNoConflict "{" + funbind + "}" + varbinds[v]
  
  # For loop.
  TestNoConflict "for (" + varbinds[v] + "0;) {" + funbind + "}"
  ++v

# Test conflicting catch/var bindings.
v = 0

while v < varbinds.length
  TestConflict "try {} catch(x) {" + varbinds[v] + "}"
  ++v

# Test conflicting parameter/var bindings.
v = 0

while v < varbinds.length
  TestNoConflict "(function (x) {" + varbinds[v] + "})();"
  ++v

# Test conflicting catch/function bindings.
TestNoConflict "try {} catch(x) {" + funbind + "}"

# Test conflicting parameter/function bindings.
TestNoConflict "(function (x) {" + funbind + "})();"
