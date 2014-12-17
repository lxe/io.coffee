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

###*
Creates a profile object for processing profiling-related events
and calculating function execution times.

@constructor
###
Profile = ->
  @codeMap_ = new CodeMap()
  @topDownTree_ = new CallTree()
  @bottomUpTree_ = new CallTree()
  @c_entries_ = {}
  return

###*
Returns whether a function with the specified name must be skipped.
Should be overriden by subclasses.

@param {string} name Function name.
###

###*
Enum for profiler operations that involve looking up existing
code entries.

@enum {number}
###

###*
Enum for code state regarding its dynamic optimization.

@enum {number}
###

###*
Called whenever the specified operation has failed finding a function
containing the specified address. Should be overriden by subclasses.
See the Profile.Operation enum for the list of
possible operations.

@param {number} operation Operation.
@param {number} addr Address of the unknown code.
@param {number} opt_stackPos If an unknown address is encountered
during stack strace processing, specifies a position of the frame
containing the address.
###

###*
Registers a library.

@param {string} name Code entry name.
@param {number} startAddr Starting address.
@param {number} endAddr Ending address.
###

###*
Registers statically compiled code entry.

@param {string} name Code entry name.
@param {number} startAddr Starting address.
@param {number} endAddr Ending address.
###

###*
Registers dynamic (JIT-compiled) code entry.

@param {string} type Code entry type.
@param {string} name Code entry name.
@param {number} start Starting address.
@param {number} size Code entry size.
###

###*
Registers dynamic (JIT-compiled) code entry.

@param {string} type Code entry type.
@param {string} name Code entry name.
@param {number} start Starting address.
@param {number} size Code entry size.
@param {number} funcAddr Shared function object address.
@param {Profile.CodeState} state Optimization state.
###

# As code and functions are in the same address space,
# it is safe to put them in a single code map.

# Function object has been overwritten with a new one.

# Entry state has changed.

###*
Reports about moving of a dynamic code entry.

@param {number} from Current code entry address.
@param {number} to New code entry address.
###

###*
Reports about deletion of a dynamic code entry.

@param {number} start Starting address.
###

###*
Reports about moving of a dynamic code entry.

@param {number} from Current code entry address.
@param {number} to New code entry address.
###

###*
Retrieves a code entry by an address.

@param {number} addr Entry address.
###

###*
Records a tick event. Stack must contain a sequence of
addresses starting with the program counter value.

@param {Array<number>} stack Stack sample.
###

###*
Translates addresses into function names and filters unneeded
functions.

@param {Array<number>} stack Stack sample.
###
# Found it, we're done.

###*
Performs a BF traversal of the top down call graph.

@param {function(CallTree.Node)} f Visitor function.
###

###*
Performs a BF traversal of the bottom up call graph.

@param {function(CallTree.Node)} f Visitor function.
###

###*
Calculates a top down profile for a node with the specified label.
If no name specified, returns the whole top down calls tree.

@param {string} opt_label Node label.
###

###*
Calculates a bottom up profile for a node with the specified label.
If no name specified, returns the whole bottom up calls tree.

@param {string} opt_label Node label.
###

###*
Helper function for calculating a tree profile.

@param {Profile.CallTree} tree Call tree.
@param {string} opt_label Node label.
###

###*
Calculates a flat profile of callees starting from a node with
the specified label. If no name specified, starts from the root.

@param {string} opt_label Starting node label.
###

# If we have created a flat profile for the whole program, we don't
# need an explicit root in it. Thus, replace the counters tree
# root with the node corresponding to the whole program.

# Propagate weights so percents can be calculated correctly.
# Sorting will keep this at index 0.

###*
Cleans up function entries that are not referenced by code entries.
###

###*
Creates a dynamic code entry.

@param {number} size Code size.
@param {string} type Code type.
@param {string} name Function name.
@constructor
###

###*
Returns node name.
###

###*
Returns raw node name (without type decoration).
###

###*
Creates a dynamic code entry.

@param {number} size Code size.
@param {string} type Code type.
@param {Profile.FunctionEntry} func Shared function entry.
@param {Profile.CodeState} state Code optimization state.
@constructor
###

###*
Returns node name.
###

###*
Returns raw node name (without type decoration).
###

###*
Creates a shared function object entry.

@param {string} name Function name.
@constructor
###

###*
Returns node name.
###

# An anonymous function with location: " aaa.js:10".

###*
Constructs a call graph.

@constructor
###
CallTree = ->
  @root_ = new CallTree.Node(CallTree.ROOT_NODE_LABEL)
  return
Profile::skipThisFunction = (name) ->
  false

Profile.Operation =
  MOVE: 0
  DELETE: 1
  TICK: 2

Profile.CodeState =
  COMPILED: 0
  OPTIMIZABLE: 1
  OPTIMIZED: 2

Profile::handleUnknownCode = (operation, addr, opt_stackPos) ->

Profile::addLibrary = (name, startAddr, endAddr) ->
  entry = new CodeMap.CodeEntry(endAddr - startAddr, name, "SHARED_LIB")
  @codeMap_.addLibrary startAddr, entry
  entry

Profile::addStaticCode = (name, startAddr, endAddr) ->
  entry = new CodeMap.CodeEntry(endAddr - startAddr, name, "CPP")
  @codeMap_.addStaticCode startAddr, entry
  entry

Profile::addCode = (type, name, start, size) ->
  entry = new Profile.DynamicCodeEntry(size, type, name)
  @codeMap_.addCode start, entry
  entry

Profile::addFuncCode = (type, name, start, size, funcAddr, state) ->
  func = @codeMap_.findDynamicEntryByStartAddress(funcAddr)
  unless func
    func = new Profile.FunctionEntry(name)
    @codeMap_.addCode funcAddr, func
  else func.name = name  if func.name isnt name
  entry = @codeMap_.findDynamicEntryByStartAddress(start)
  if entry
    entry.state = state  if entry.size is size and entry.func is func
  else
    entry = new Profile.DynamicFuncCodeEntry(size, type, func, state)
    @codeMap_.addCode start, entry
  entry

Profile::moveCode = (from, to) ->
  try
    @codeMap_.moveCode from, to
  catch e
    @handleUnknownCode Profile.Operation.MOVE, from
  return

Profile::deleteCode = (start) ->
  try
    @codeMap_.deleteCode start
  catch e
    @handleUnknownCode Profile.Operation.DELETE, start
  return

Profile::moveFunc = (from, to) ->
  @codeMap_.moveCode from, to  if @codeMap_.findDynamicEntryByStartAddress(from)
  return

Profile::findEntry = (addr) ->
  @codeMap_.findEntry addr

Profile::recordTick = (stack) ->
  processedStack = @resolveAndFilterFuncs_(stack)
  @bottomUpTree_.addPath processedStack
  processedStack.reverse()
  @topDownTree_.addPath processedStack
  return

Profile::resolveAndFilterFuncs_ = (stack) ->
  result = []
  last_seen_c_function = ""
  look_for_first_c_function = false
  i = 0

  while i < stack.length
    entry = @codeMap_.findEntry(stack[i])
    if entry
      name = entry.getName()
      look_for_first_c_function = true  if i is 0 and (entry.type is "CPP" or entry.type is "SHARED_LIB")
      if look_for_first_c_function
        if entry.type is "CPP"
          last_seen_c_function = name
        else if i > 0 and last_seen_c_function isnt ""
          @c_entries_[last_seen_c_function] = 0  if @c_entries_[last_seen_c_function] is `undefined`
          @c_entries_[last_seen_c_function]++
          look_for_first_c_function = false
      result.push name  unless @skipThisFunction(name)
    else
      @handleUnknownCode Profile.Operation.TICK, stack[i], i
    ++i
  result

Profile::traverseTopDownTree = (f) ->
  @topDownTree_.traverse f
  return

Profile::traverseBottomUpTree = (f) ->
  @bottomUpTree_.traverse f
  return

Profile::getTopDownProfile = (opt_label) ->
  @getTreeProfile_ @topDownTree_, opt_label

Profile::getBottomUpProfile = (opt_label) ->
  @getTreeProfile_ @bottomUpTree_, opt_label

Profile::getTreeProfile_ = (tree, opt_label) ->
  unless opt_label
    tree.computeTotalWeights()
    tree
  else
    subTree = tree.cloneSubtree(opt_label)
    subTree.computeTotalWeights()
    subTree

Profile::getFlatProfile = (opt_label) ->
  counters = new CallTree()
  rootLabel = opt_label or CallTree.ROOT_NODE_LABEL
  precs = {}
  precs[rootLabel] = 0
  root = counters.findOrAddChild(rootLabel)
  @topDownTree_.computeTotalWeights()
  @topDownTree_.traverseInDepth (onEnter = (node) ->
    precs[node.label] = 0  unless node.label of precs
    nodeLabelIsRootLabel = node.label is rootLabel
    if nodeLabelIsRootLabel or precs[rootLabel] > 0
      if precs[rootLabel] is 0
        root.selfWeight += node.selfWeight
        root.totalWeight += node.totalWeight
      else
        rec = root.findOrAddChild(node.label)
        rec.selfWeight += node.selfWeight
        rec.totalWeight += node.totalWeight  if nodeLabelIsRootLabel or precs[node.label] is 0
      precs[node.label]++
    return
  ), (onExit = (node) ->
    precs[node.label]--  if node.label is rootLabel or precs[rootLabel] > 0
    return
  ), null
  unless opt_label
    counters.root_ = root
  else
    counters.getRoot().selfWeight = root.selfWeight
    counters.getRoot().totalWeight = root.totalWeight
  counters

Profile.CEntryNode = (name, ticks) ->
  @name = name
  @ticks = ticks
  return

Profile::getCEntryProfile = ->
  result = [new Profile.CEntryNode("TOTAL", 0)]
  total_ticks = 0
  for f of @c_entries_
    ticks = @c_entries_[f]
    total_ticks += ticks
    result.push new Profile.CEntryNode(f, ticks)
  result[0].ticks = total_ticks
  result.sort (n1, n2) ->
    n2.ticks - n1.ticks or ((if n2.name < n1.name then -1 else 1))

  result

Profile::cleanUpFuncEntries = ->
  referencedFuncEntries = []
  entries = @codeMap_.getAllDynamicEntriesWithAddresses()
  i = 0
  l = entries.length

  while i < l
    entries[i][1].used = false  if entries[i][1].constructor is Profile.FunctionEntry
    ++i
  i = 0
  l = entries.length

  while i < l
    entries[i][1].func.used = true  if "func" of entries[i][1]
    ++i
  i = 0
  l = entries.length

  while i < l
    @codeMap_.deleteCode entries[i][0]  if entries[i][1].constructor is Profile.FunctionEntry and not entries[i][1].used
    ++i
  return

Profile.DynamicCodeEntry = (size, type, name) ->
  CodeMap.CodeEntry.call this, size, name, type
  return

Profile.DynamicCodeEntry::getName = ->
  @type + ": " + @name

Profile.DynamicCodeEntry::getRawName = ->
  @name

Profile.DynamicCodeEntry::isJSFunction = ->
  false

Profile.DynamicCodeEntry::toString = ->
  @getName() + ": " + @size.toString(16)

Profile.DynamicFuncCodeEntry = (size, type, func, state) ->
  CodeMap.CodeEntry.call this, size, "", type
  @func = func
  @state = state
  return

Profile.DynamicFuncCodeEntry.STATE_PREFIX = [
  ""
  "~"
  "*"
]
Profile.DynamicFuncCodeEntry::getName = ->
  name = @func.getName()
  @type + ": " + Profile.DynamicFuncCodeEntry.STATE_PREFIX[@state] + name

Profile.DynamicFuncCodeEntry::getRawName = ->
  @func.getName()

Profile.DynamicFuncCodeEntry::isJSFunction = ->
  true

Profile.DynamicFuncCodeEntry::toString = ->
  @getName() + ": " + @size.toString(16)

Profile.FunctionEntry = (name) ->
  CodeMap.CodeEntry.call this, 0, name
  return

Profile.FunctionEntry::getName = ->
  name = @name
  if name.length is 0
    name = "<anonymous>"
  else name = "<anonymous>" + name  if name.charAt(0) is " "
  name

Profile.FunctionEntry::toString = CodeMap.CodeEntry::toString

###*
The label of the root node.
###
CallTree.ROOT_NODE_LABEL = ""

###*
@private
###
CallTree::totalsComputed_ = false

###*
Returns the tree root.
###
CallTree::getRoot = ->
  @root_


###*
Adds the specified call path, constructing nodes as necessary.

@param {Array<string>} path Call path.
###
CallTree::addPath = (path) ->
  return  if path.length is 0
  curr = @root_
  i = 0

  while i < path.length
    curr = curr.findOrAddChild(path[i])
    ++i
  curr.selfWeight++
  @totalsComputed_ = false
  return


###*
Finds an immediate child of the specified parent with the specified
label, creates a child node if necessary. If a parent node isn't
specified, uses tree root.

@param {string} label Child node label.
###
CallTree::findOrAddChild = (label) ->
  @root_.findOrAddChild label


###*
Creates a subtree by cloning and merging all subtrees rooted at nodes
with a given label. E.g. cloning the following call tree on label 'A'
will give the following result:

<A>--<B>                                     <B>
/                                            /
<root>             == clone on 'A' ==>  <root>--<A>
\                                            \
<C>--<A>--<D>                                <D>

And <A>'s selfWeight will be the sum of selfWeights of <A>'s from the
source call tree.

@param {string} label The label of the new root node.
###
CallTree::cloneSubtree = (label) ->
  subTree = new CallTree()
  @traverse (node, parent) ->
    return null  if not parent and node.label isnt label
    child = ((if parent then parent else subTree)).findOrAddChild(node.label)
    child.selfWeight += node.selfWeight
    child

  subTree


###*
Computes total weights in the call graph.
###
CallTree::computeTotalWeights = ->
  return  if @totalsComputed_
  @root_.computeTotalWeight()
  @totalsComputed_ = true
  return


###*
Traverses the call graph in preorder. This function can be used for
building optionally modified tree clones. This is the boilerplate code
for this scenario:

callTree.traverse(function(node, parentClone) {
var nodeClone = cloneNode(node);
if (parentClone)
parentClone.addChild(nodeClone);
return nodeClone;
});

@param {function(CallTree.Node, *)} f Visitor function.
The second parameter is the result of calling 'f' on the parent node.
###
CallTree::traverse = (f) ->
  pairsToProcess = new ConsArray()
  pairsToProcess.concat [
    node: @root_
    param: null
  ]
  until pairsToProcess.atEnd()
    pair = pairsToProcess.next()
    node = pair.node
    newParam = f(node, pair.param)
    morePairsToProcess = []
    node.forEachChild (child) ->
      morePairsToProcess.push
        node: child
        param: newParam

      return

    pairsToProcess.concat morePairsToProcess
  return


###*
Performs an indepth call graph traversal.

@param {function(CallTree.Node)} enter A function called
prior to visiting node's children.
@param {function(CallTree.Node)} exit A function called
after visiting node's children.
###
CallTree::traverseInDepth = (enter, exit) ->
  traverse = (node) ->
    enter node
    node.forEachChild traverse
    exit node
    return
  traverse @root_
  return


###*
Constructs a call graph node.

@param {string} label Node label.
@param {CallTree.Node} opt_parent Node parent.
###
CallTree.Node = (label, opt_parent) ->
  @label = label
  @parent = opt_parent
  @children = {}
  return


###*
Node self weight (how many times this node was the last node in
a call path).
@type {number}
###
CallTree.Node::selfWeight = 0

###*
Node total weight (includes weights of all children).
@type {number}
###
CallTree.Node::totalWeight = 0

###*
Adds a child node.

@param {string} label Child node label.
###
CallTree.Node::addChild = (label) ->
  child = new CallTree.Node(label, this)
  @children[label] = child
  child


###*
Computes node's total weight.
###
CallTree.Node::computeTotalWeight = ->
  totalWeight = @selfWeight
  @forEachChild (child) ->
    totalWeight += child.computeTotalWeight()
    return

  @totalWeight = totalWeight


###*
Returns all node's children as an array.
###
CallTree.Node::exportChildren = ->
  result = []
  @forEachChild (node) ->
    result.push node
    return

  result


###*
Finds an immediate child with the specified label.

@param {string} label Child node label.
###
CallTree.Node::findChild = (label) ->
  @children[label] or null


###*
Finds an immediate child with the specified label, creates a child
node if necessary.

@param {string} label Child node label.
###
CallTree.Node::findOrAddChild = (label) ->
  @findChild(label) or @addChild(label)


###*
Calls the specified function for every child.

@param {function(CallTree.Node)} f Visitor function.
###
CallTree.Node::forEachChild = (f) ->
  for c of @children
    f @children[c]
  return


###*
Walks up from the current node up to the call tree root.

@param {function(CallTree.Node)} f Visitor function.
###
CallTree.Node::walkUpToRoot = (f) ->
  curr = this

  while curr?
    f curr
    curr = curr.parent
  return


###*
Tries to find a node with the specified path.

@param {Array<string>} labels The path.
@param {function(CallTree.Node)} opt_f Visitor function.
###
CallTree.Node::descendToChild = (labels, opt_f) ->
  pos = 0
  curr = this

  while pos < labels.length and curr?
    child = curr.findChild(labels[pos])
    opt_f child, pos  if opt_f
    curr = child
    pos++
  curr
