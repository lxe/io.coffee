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

# Tests global loads from eval.
test = ->
  g = ->
    h = ->
      
      # Shadow with local variable.
      i = (x) ->
        
        # Shadow with parameter.
        j = ->
          
          # Shadow with function name.
          x = ->
            assertEquals x, eval("x")
            return
          assertEquals x, eval("x")
          x()
          return
        assertEquals 44, eval("x")
        j()
        return
      x = 22
      assertEquals 22, eval("x")
      i 44
      return
    assertEquals 27, eval("x")
    h()
    return
  g()
  return

# Test loading of globals from deeply nested eval.  This code is a
# bit complicated, but the complication is needed to check that the
# code that loads the global variable accounts for the fact that the
# global variable becomes shadowed by an eval-introduced variable.
testDeep = (source, load, test) ->
  f = ->
    g = ->
      h = ->
        eval load
        eval test
        return
      z = 25
      h()
      return
    y = 23
    g()
    return
  eval source
  f()
  return
x = 27
test()
result = 0
testDeep "1", "result = x", "assertEquals(27, result)"

# Because of the eval-cache, the 'result = x' code gets reused.  This
# time in a context where the 'x' variable has been shadowed.
testDeep "var x = 1", "result = x", "assertEquals(1, result)"
