# Copyright 2014 the V8 project authors. All rights reserved.
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

# This file emulates Mocha test framework used in promises-aplus tests.
describe = undefined
it = undefined
specify = undefined
before = undefined
after = undefined
beforeEach = undefined
afterEach = undefined
RunAllTests = undefined
assert = require("assert")
(->
  PostMicrotask = (fn) ->
    o = {}
    Object.observe o, ->
      fn()
      return

    
    # Change something to enqueue a microtask.
    o.x = "hello"
    return
  Run = ->
    current = ->
      ++context.currentSuiteIndex  while context.currentSuiteIndex < context.suites.length and context.suites[context.currentSuiteIndex].hasRun
      return `undefined`  if context.suites.length is context.currentSuiteIndex
      context.suites[context.currentSuiteIndex]
    suite = current()
    unless suite
      
      # done
      print "All tests have run."
      return
    suite.Run()
    return
  TestCase = (name, before, fn, after, isRegular) ->
    @name = name
    @before = before
    @fn = fn
    @after = after
    @isRegular = isRegular
    @hasDone = false
    return
  
  # synchronous
  
  # asynchronous
  TestSuite = (described) ->
    @description = described.description
    @cases = []
    @currentIndex = 0
    @hasRun = false
    @cases.push new TestCase(@description + " :before", `undefined`, described.before, `undefined`, false)  if described.before
    i = 0

    while i < described.cases.length
      @cases.push new TestCase(described.cases[i].description, described.beforeEach, described.cases[i].fn, described.afterEach, true)
      ++i
    @cases.push new TestCase(@description + " :after", `undefined`, described.after, `undefined`, false)  if described.after
    return
  TIMEOUT = 1000
  context =
    beingDescribed: `undefined`
    currentSuiteIndex: 0
    suites: []

  RunAllTests = ->
    context.currentSuiteIndex = 0
    numRegularTestCases = 0
    i = 0

    while i < context.suites.length
      numRegularTestCases += context.suites[i].numRegularTestCases()
      ++i
    print context.suites.length + " suites and " + numRegularTestCases + " test cases are found"
    Run()
    return

  TestCase::RunFunction = (suite, fn, postAction) ->
    unless fn
      postAction()
      return
    try
      if fn.length is 0
        fn()
        postAction()
      else
        fn postAction
    catch e
      suite.ReportError this, e
    return

  TestCase::MarkAsDone = ->
    @hasDone = true
    clearTimeout @timer
    return

  TestCase::Run = (suite, postAction) ->
    print "Running " + suite.description + "#" + @name + " ..."
    assert.clear()
    @timer = setTimeout((->
      suite.ReportError this, Error("timeout")
      return
    ).bind(this), TIMEOUT)
    @RunFunction suite, @before, ((e) ->
      return  if @hasDone
      return suite.ReportError(this, e)  if e instanceof Error
      return suite.ReportError(this, assert.fails[0])  if assert.fails.length > 0
      @RunFunction suite, @fn, ((e) ->
        return  if @hasDone
        return suite.ReportError(this, e)  if e instanceof Error
        return suite.ReportError(this, assert.fails[0])  if assert.fails.length > 0
        @RunFunction suite, @after, ((e) ->
          return  if @hasDone
          return suite.ReportError(this, e)  if e instanceof Error
          return suite.ReportError(this, assert.fails[0])  if assert.fails.length > 0
          @MarkAsDone()
          print "PASS: " + suite.description + "#" + @name  if @isRegular
          PostMicrotask postAction
          return
        ).bind(this)
        return
      ).bind(this)
      return
    ).bind(this)
    return

  TestSuite::Run = ->
    @hasRun = @currentIndex is @cases.length
    if @hasRun
      PostMicrotask Run
      return
    
    # TestCase.prototype.Run cannot throw an exception.
    @cases[@currentIndex].Run this, (->
      ++@currentIndex
      PostMicrotask Run
      return
    ).bind(this)
    return

  TestSuite::numRegularTestCases = ->
    n = 0
    i = 0

    while i < @cases.length
      ++n  if @cases[i].isRegular
      ++i
    n

  TestSuite::ReportError = (testCase, e) ->
    return  if testCase.hasDone
    testCase.MarkAsDone()
    @hasRun = @currentIndex is @cases.length
    print "FAIL: " + @description + "#" + testCase.name + ": " + e.name + " (" + e.message + ")"
    ++@currentIndex
    PostMicrotask Run
    return

  describe = (description, fn) ->
    parent = context.beingDescribed
    incomplete =
      cases: []
      description: (if parent then parent.description + " " + description else description)
      parent: parent

    context.beingDescribed = incomplete
    fn()
    context.beingDescribed = parent
    context.suites.push new TestSuite(incomplete)
    return

  specify = it = (description, fn) ->
    context.beingDescribed.cases.push
      description: description
      fn: fn

    return

  before = (fn) ->
    context.beingDescribed.before = fn
    return

  after = (fn) ->
    context.beingDescribed.after = fn
    return

  beforeEach = (fn) ->
    context.beingDescribed.beforeEach = fn
    return

  afterEach = (fn) ->
    context.beingDescribed.afterEach = fn
    return

  return
)()
