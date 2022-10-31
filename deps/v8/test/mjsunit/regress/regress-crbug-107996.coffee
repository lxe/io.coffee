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

# Flags: --expose-debug-as debug
# Flags: --turbo-deoptimization
listener = (event, exec_state, event_data, data) ->
  if event is Debug.DebugEvent.Break
    i = 0

    while i < exec_state.frameCount()
      frame = exec_state.frame(i)
      four_in_debugger[i] = frame.evaluate("four", false).value()
      i++
  return
f1 = ->
  three = 3
  four = 4
  (f2 = ->
    seven = 7
    (f3 = ->
      debugger
      fourteen = three + four + seven
      return
    )()
    return
  )()
  return
Debug = debug.Debug
Debug.setListener listener
fourteen = undefined
four_in_debugger = []
f1()
assertEquals 14, fourteen
assertEquals 4, four_in_debugger[0]
assertEquals 4, four_in_debugger[1]
assertEquals 4, four_in_debugger[2]
Debug.setListener null