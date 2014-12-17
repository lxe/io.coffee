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
fnGlobalObject = ->
  (->
    this
  )()
ES5Harness = (->
  Test262Error = (id, path, description, codeString, preconditionString, result, error) ->
    @id = id
    @path = path
    @description = description
    @result = result
    @error = error
    @code = codeString
    @pre = preconditionString
    return
  registerTest = (test) ->
    unless test.precondition and not test.precondition()
      error = undefined
      try
        res = test.test.call($this)
      catch e
        res = "fail"
        error = e
      retVal = (if /^s/i.test(test.id) then ((if res is true or typeof res is "undefined" then "pass" else "fail")) else ((if res is true then "pass" else "fail")))
      unless retVal is "pass"
        precondition = (if (test.precondition isnt `undefined`) then test.precondition.toString() else "")
        throw new Test262Error(test.id, test.path, test.description, test.test.toString(), precondition, retVal, error)
    return
  currentTest = {}
  $this = this
  Test262Error::toString = ->
    @result + " " + @error

  registerTest: registerTest
)()
