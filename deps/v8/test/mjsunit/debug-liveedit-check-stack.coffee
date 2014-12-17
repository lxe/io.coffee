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
TestBase = (name) ->
  print "TestBase constructor: " + name
  @ChooseAnimal = eval("/* " + unique_id + "*/\n" + "(function ChooseAnimal(callback) {\n " + "  callback();\n" + "  return 'Cat';\n" + "})\n")
  
  # Prevents eval script caching.
  unique_id++
  script = Debug.findScript(@ChooseAnimal)
  orig_animal = "'Cat'"
  patch_pos = script.source.indexOf(orig_animal)
  new_animal_patch = "'Capybara'"
  got_exception = false
  successfully_changed = false
  
  # Should be called from Debug context.
  @ScriptChanger = ->
    assertEquals false, successfully_changed, "applying patch second time"
    
    # Runs in debugger context.
    change_log = new Array()
    try
      Debug.LiveEdit.TestApi.ApplySingleChunkPatch script, patch_pos, orig_animal.length, new_animal_patch, change_log
    finally
      print "Change log: " + JSON.stringify(change_log) + "\n"
    successfully_changed = true
    return

  return
Noop = ->
WrapInCatcher = (f, holder) ->
  ->
    delete holder[0]

    try
      f()
    catch e
      if e instanceof Debug.LiveEdit.Failure
        holder[0] = e
      else
        throw e
    return
WrapInNativeCall = (f) ->
  ->
    Debug.ExecuteInDebugContext f, true
WrapInDebuggerCall = (f) ->
  ->
    Debug.ExecuteInDebugContext f, false
WrapInRestartProof = (f) ->
  already_called = false
  ->
    return  if already_called
    already_called = true
    f()
    return
WrapInConstructor = (f) ->
  ->
    new ->
      f()
      return
Debug = debug.Debug
unique_id = 1

# A series of tests. In each test we call ChooseAnimal function that calls
# a callback that attempts to modify the function on the fly.
test = new TestBase("First test ChooseAnimal without edit")
assertEquals "Cat", test.ChooseAnimal(Noop)
test = new TestBase("Test without function on stack")
test.ScriptChanger()
assertEquals "Capybara", test.ChooseAnimal(Noop)
test = new TestBase("Test with function on stack")
assertEquals "Capybara", test.ChooseAnimal(WrapInDebuggerCall(WrapInRestartProof(test.ScriptChanger)))
test = new TestBase("Test with function on stack and with constructor frame")
assertEquals "Capybara", test.ChooseAnimal(WrapInConstructor(WrapInDebuggerCall(WrapInRestartProof(test.ScriptChanger))))
test = new TestBase("Test with C++ frame above ChooseAnimal frame")
exception_holder = {}
assertEquals "Cat", test.ChooseAnimal(WrapInNativeCall(WrapInDebuggerCall(WrapInCatcher(test.ScriptChanger, exception_holder))))
assertTrue !!exception_holder[0]
