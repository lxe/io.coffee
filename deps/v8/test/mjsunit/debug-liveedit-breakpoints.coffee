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

# Flags: --expose-debug-as debug
# Get the Debug object exposed from the debug context global object.
Debug = debug.Debug
# Breakpoint line ( #6 )
function_z_text = "  function Z() {\n" + "    return 'Z';\n" + "  }\n"
# Breakpoint line ( #1 )
# function takes exactly 3 lines
#                 // Breakpoint line ( #6 )
#
# Breakpoint line ( #14 )
eval "function F25() {\n" + "  return 25;\n" + "}\n" + "function F26 () {\n" + "  var x = 20;\n" + function_z_text + "  var y = 6;\n" + "  return x + y;\n" + "}\n" + "function Nested() {\n" + "  var a = 30;\n" + "  return function F27() {\n" + "    var b = 3;\n" + "    return a - b;\n" + "  }\n" + "}\n"
assertEquals 25, F25()
assertEquals 26, F26()
script = Debug.findScript(F25)
assertEquals 0, Debug.scriptBreakPoints().length
Debug.setScriptBreakPoint Debug.ScriptBreakPointType.ScriptId, script.id, 1, 1, "true || false || false"
Debug.setScriptBreakPoint Debug.ScriptBreakPointType.ScriptId, script.id, 6, 1, "true || false || false"
Debug.setScriptBreakPoint Debug.ScriptBreakPointType.ScriptId, script.id, 14, 1, "true || false || false"
assertEquals 3, Debug.scriptBreakPoints().length
new_source = script.source.replace(function_z_text, "")
print "new source: " + new_source
change_log = new Array()
result = Debug.LiveEdit.SetScriptSource(script, new_source, false, change_log)
print "Result: " + JSON.stringify(result) + "\n"
print "Change log: " + JSON.stringify(change_log) + "\n"
breaks = Debug.scriptBreakPoints()

# One breakpoint gets duplicated in a old version of script.
assertTrue breaks.length > 3 + 1
breakpoints_in_script = 0
break_position_map = {}
i = 0

while i < breaks.length
  if breaks[i].script_id() is script.id
    break_position_map[breaks[i].line()] = true
    breakpoints_in_script++
  i++
assertEquals 3, breakpoints_in_script

# Check 2 breakpoints. The one in deleted function should have been moved somewhere.
assertTrue break_position_map[1]
assertTrue break_position_map[11]

# Delete all breakpoints to make this test reentrant.
breaks = Debug.scriptBreakPoints()
breaks_ids = []
i = 0

while i < breaks.length
  breaks_ids.push breaks[i].number()
  i++
i = 0

while i < breaks_ids.length
  Debug.clearBreakPoint breaks_ids[i]
  i++
assertEquals 0, Debug.scriptBreakPoints().length
