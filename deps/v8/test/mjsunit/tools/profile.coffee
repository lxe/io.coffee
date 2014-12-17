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

# Load source code files from <project root>/tools.
# Files: tools/splaytree.js tools/codemap.js tools/consarray.js tools/profile.js
stackToString = (stack) ->
  stack.join " -> "
assertPathExists = (root, path, opt_message) ->
  message = (if opt_message then " (" + opt_message + ")" else "")
  assertNotNull root.descendToChild(path, (node, pos) ->
    assertNotNull node, stackToString(path.slice(0, pos)) + " has no child " + path[pos] + message
    return
  ), opt_message
  return
assertNoPathExists = (root, path, opt_message) ->
  message = (if opt_message then " (" + opt_message + ")" else "")
  assertNull root.descendToChild(path), opt_message
  return
countNodes = (profile, traverseFunc) ->
  count = 0
  traverseFunc.call profile, ->
    count++
    return

  count
ProfileTestDriver = ->
  @profile = new Profile()
  @stack_ = []
  @addFunctions_()
  return

# Addresses inside functions.

# Stack looks like this: [pc, caller, ..., main].
# Therefore, we are adding entries at the beginning.
Inherits = (childCtor, parentCtor) ->
  tempCtor = ->
  tempCtor:: = parentCtor::
  childCtor.superClass_ = parentCtor::
  childCtor:: = new tempCtor()
  childCtor::constructor = childCtor
  return

# Must be no changes in tree layout.
assertNodeWeights = (root, path, selfTicks, totalTicks) ->
  node = root.descendToChild(path)
  stack = stackToString(path)
  assertNotNull node, "node not found: " + stack
  assertEquals selfTicks, node.selfWeight, "self of " + stack
  assertEquals totalTicks, node.totalWeight, "total of " + stack
  return
ProfileTestDriver::funcAddrs_ =
  "lib1-f1": 0x11110
  "lib1-f2": 0x11210
  "lib2-f1": 0x21110
  "lib2-f2": 0x21210
  "T: F1": 0x50110
  "T: F2": 0x50210
  "T: F3": 0x50410

ProfileTestDriver::addFunctions_ = ->
  @profile.addLibrary "lib1", 0x11000, 0x12000
  @profile.addStaticCode "lib1-f1", 0x11100, 0x11900
  @profile.addStaticCode "lib1-f2", 0x11200, 0x11500
  @profile.addLibrary "lib2", 0x21000, 0x22000
  @profile.addStaticCode "lib2-f1", 0x21100, 0x21900
  @profile.addStaticCode "lib2-f2", 0x21200, 0x21500
  @profile.addCode "T", "F1", 0x50100, 0x100
  @profile.addCode "T", "F2", 0x50200, 0x100
  @profile.addCode "T", "F3", 0x50400, 0x100
  return

ProfileTestDriver::enter = (funcName) ->
  @stack_.unshift @funcAddrs_[funcName]
  @profile.recordTick @stack_
  return

ProfileTestDriver::stay = ->
  @profile.recordTick @stack_
  return

ProfileTestDriver::leave = ->
  @stack_.shift()
  return

ProfileTestDriver::execute = ->
  @enter "lib1-f1"
  @enter "lib1-f2"
  @enter "T: F1"
  @enter "T: F2"
  @leave()
  @stay()
  @enter "lib2-f1"
  @enter "lib2-f1"
  @leave()
  @stay()
  @leave()
  @enter "T: F3"
  @enter "T: F3"
  @enter "T: F3"
  @leave()
  @enter "T: F2"
  @stay()
  @leave()
  @leave()
  @leave()
  @leave()
  @enter "lib2-f1"
  @enter "lib1-f1"
  @leave()
  @leave()
  @stay()
  @leave()
  return

(testCallTreeBuilding = ->
  Driver = ->
    ProfileTestDriver.call this
    @namesTopDown = []
    @namesBottomUp = []
    return
  Inherits Driver, ProfileTestDriver
  Driver::enter = (func) ->
    @namesTopDown.push func
    @namesBottomUp.unshift func
    assertNoPathExists @profile.getTopDownProfile().getRoot(), @namesTopDown, "pre enter/topDown"
    assertNoPathExists @profile.getBottomUpProfile().getRoot(), @namesBottomUp, "pre enter/bottomUp"
    Driver.superClass_.enter.call this, func
    assertPathExists @profile.getTopDownProfile().getRoot(), @namesTopDown, "post enter/topDown"
    assertPathExists @profile.getBottomUpProfile().getRoot(), @namesBottomUp, "post enter/bottomUp"
    return

  Driver::stay = ->
    preTopDownNodes = countNodes(@profile, @profile.traverseTopDownTree)
    preBottomUpNodes = countNodes(@profile, @profile.traverseBottomUpTree)
    Driver.superClass_.stay.call this
    postTopDownNodes = countNodes(@profile, @profile.traverseTopDownTree)
    postBottomUpNodes = countNodes(@profile, @profile.traverseBottomUpTree)
    assertEquals preTopDownNodes, postTopDownNodes, "stay/topDown"
    assertEquals preBottomUpNodes, postBottomUpNodes, "stay/bottomUp"
    return

  Driver::leave = ->
    Driver.superClass_.leave.call this
    @namesTopDown.pop()
    @namesBottomUp.shift()
    return

  testDriver = new Driver()
  testDriver.execute()
  return
)()
(testTopDownRootProfileTicks = ->
  testDriver = new ProfileTestDriver()
  testDriver.execute()
  pathWeights = [
    [
      ["lib1-f1"]
      1
      16
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
      ]
      2
      15
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "T: F1"
      ]
      2
      11
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "T: F1"
        "T: F2"
      ]
      1
      1
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "T: F1"
        "lib2-f1"
      ]
      2
      3
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "T: F1"
        "lib2-f1"
        "lib2-f1"
      ]
      1
      1
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "T: F1"
        "T: F3"
      ]
      1
      5
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "T: F1"
        "T: F3"
        "T: F3"
      ]
      1
      4
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "T: F1"
        "T: F3"
        "T: F3"
        "T: F3"
      ]
      1
      1
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "T: F1"
        "T: F3"
        "T: F3"
        "T: F2"
      ]
      2
      2
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "lib2-f1"
      ]
      1
      2
    ]
    [
      [
        "lib1-f1"
        "lib1-f2"
        "lib2-f1"
        "lib1-f1"
      ]
      1
      1
    ]
  ]
  root = testDriver.profile.getTopDownProfile().getRoot()
  i = 0

  while i < pathWeights.length
    data = pathWeights[i]
    assertNodeWeights root, data[0], data[1], data[2]
    ++i
  return
)()
(testRootFlatProfileTicks = ->
  Driver = ->
    ProfileTestDriver.call this
    @namesTopDown = [""]
    @counters = {}
    @root = null
    return
  Inherits Driver, ProfileTestDriver
  Driver::increment = (func, self, total) ->
    unless func of @counters
      @counters[func] =
        self: 0
        total: 0
    @counters[func].self += self
    @counters[func].total += total
    return

  Driver::incrementTotals = ->
    
    # Only count each function in the stack once.
    met = {}
    i = 0

    while i < @namesTopDown.length
      name = @namesTopDown[i]
      @increment name, 0, 1  unless name of met
      met[name] = true
      ++i
    return

  Driver::enter = (func) ->
    Driver.superClass_.enter.call this, func
    @namesTopDown.push func
    @increment func, 1, 0
    @incrementTotals()
    return

  Driver::stay = ->
    Driver.superClass_.stay.call this
    @increment @namesTopDown[@namesTopDown.length - 1], 1, 0
    @incrementTotals()
    return

  Driver::leave = ->
    Driver.superClass_.leave.call this
    @namesTopDown.pop()
    return

  Driver::extractRoot = ->
    assertTrue "" of @counters
    @root = @counters[""]
    delete @counters[""]

    return

  testDriver = new Driver()
  testDriver.execute()
  testDriver.extractRoot()
  counted = 0
  for c of testDriver.counters
    counted++
  flatProfileRoot = testDriver.profile.getFlatProfile().getRoot()
  assertEquals testDriver.root.self, flatProfileRoot.selfWeight
  assertEquals testDriver.root.total, flatProfileRoot.totalWeight
  flatProfile = flatProfileRoot.exportChildren()
  assertEquals counted, flatProfile.length, "counted vs. flatProfile"
  i = 0

  while i < flatProfile.length
    rec = flatProfile[i]
    assertTrue rec.label of testDriver.counters, "uncounted: " + rec.label
    reference = testDriver.counters[rec.label]
    assertEquals reference.self, rec.selfWeight, "self of " + rec.label
    assertEquals reference.total, rec.totalWeight, "total of " + rec.label
    ++i
  return
)()
(testFunctionCalleesProfileTicks = ->
  testDriver = new ProfileTestDriver()
  testDriver.execute()
  pathWeights = [
    [
      ["lib2-f1"]
      3
      5
    ]
    [
      [
        "lib2-f1"
        "lib2-f1"
      ]
      1
      1
    ]
    [
      [
        "lib2-f1"
        "lib1-f1"
      ]
      1
      1
    ]
  ]
  profile = testDriver.profile.getTopDownProfile("lib2-f1")
  root = profile.getRoot()
  i = 0

  while i < pathWeights.length
    data = pathWeights[i]
    assertNodeWeights root, data[0], data[1], data[2]
    ++i
  return
)()
(testFunctionFlatProfileTicks = ->
  testDriver = new ProfileTestDriver()
  testDriver.execute()
  flatWeights =
    "lib2-f1": [
      1
      1
    ]
    "lib1-f1": [
      1
      1
    ]

  flatProfileRoot = testDriver.profile.getFlatProfile("lib2-f1").findOrAddChild("lib2-f1")
  assertEquals 3, flatProfileRoot.selfWeight
  assertEquals 5, flatProfileRoot.totalWeight
  flatProfile = flatProfileRoot.exportChildren()
  assertEquals 2, flatProfile.length, "counted vs. flatProfile"
  i = 0

  while i < flatProfile.length
    rec = flatProfile[i]
    assertTrue rec.label of flatWeights, "uncounted: " + rec.label
    reference = flatWeights[rec.label]
    assertEquals reference[0], rec.selfWeight, "self of " + rec.label
    assertEquals reference[1], rec.totalWeight, "total of " + rec.label
    ++i
  return
)()
