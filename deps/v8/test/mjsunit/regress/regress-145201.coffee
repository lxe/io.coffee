# Copyright 2012 the V8 project authors. All rights reserved.
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

# Fix some corner cases in skipping native methods using caller.
collect = ->
  item = (operator) ->
    binary operator, 1, false
    binary operator, 1, true
    binary operator, "{}", false
    binary operator, "{}", true
    binary operator, "\"x\"", false
    binary operator, "\"x\"", true
    unary operator, ""
    return
  unary = (op, after) ->
    
    # Capture:
    try
      eval op + " custom " + after
    return
  binary = (op, other_side, inverted) ->
    
    # Capture:
    try
      if inverted
        eval "custom " + op + " " + other_side
      else
        eval other_side + " " + op + " custom"
    return
  catcher = ->
    caller = catcher.caller
    net[caller] = 0  if /native/i.test(caller) or /ADD/.test(caller)
    return
  custom = Object.create(null,
    toString:
      value: catcher

    length:
      get: catcher
  )
  item "^"
  item "~"
  item "<<"
  item "<"
  item "=="
  item ">>>"
  item ">>"
  item "|"
  item "-"
  item "*"
  item "&"
  item "%"
  item "+"
  item "in"
  item "instanceof"
  unary "{}[", "]"
  unary "delete {}[", "]"
  unary "(function() {}).apply(null, ", ")"
  return
net = []
x = 0
collect()
collect()
collect()
keys = 0
for key of net
  print key
  keys++
assertTrue keys is 0
