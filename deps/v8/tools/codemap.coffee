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
Constructs a mapper that maps addresses into code entries.

@constructor
###
CodeMap = ->
  
  ###*
  Dynamic code entries. Used for JIT compiled code.
  ###
  @dynamics_ = new SplayTree()
  
  ###*
  Name generator for entries having duplicate names.
  ###
  @dynamicsNameGen_ = new CodeMap.NameGenerator()
  
  ###*
  Static code entries. Used for statically compiled code.
  ###
  @statics_ = new SplayTree()
  
  ###*
  Libraries entries. Used for the whole static code libraries.
  ###
  @libraries_ = new SplayTree()
  
  ###*
  Map of memory pages occupied with static code.
  ###
  @pages_ = []
  return

###*
The number of alignment bits in a page address.
###
CodeMap.PAGE_ALIGNMENT = 12

###*
Page size in bytes.
###
CodeMap.PAGE_SIZE = 1 << CodeMap.PAGE_ALIGNMENT

###*
Adds a dynamic (i.e. moveable and discardable) code entry.

@param {number} start The starting address.
@param {CodeMap.CodeEntry} codeEntry Code entry object.
###
CodeMap::addCode = (start, codeEntry) ->
  @deleteAllCoveredNodes_ @dynamics_, start, start + codeEntry.size
  @dynamics_.insert start, codeEntry
  return


###*
Moves a dynamic code entry. Throws an exception if there is no dynamic
code entry with the specified starting address.

@param {number} from The starting address of the entry being moved.
@param {number} to The destination address.
###
CodeMap::moveCode = (from, to) ->
  removedNode = @dynamics_.remove(from)
  @deleteAllCoveredNodes_ @dynamics_, to, to + removedNode.value.size
  @dynamics_.insert to, removedNode.value
  return


###*
Discards a dynamic code entry. Throws an exception if there is no dynamic
code entry with the specified starting address.

@param {number} start The starting address of the entry being deleted.
###
CodeMap::deleteCode = (start) ->
  removedNode = @dynamics_.remove(start)
  return


###*
Adds a library entry.

@param {number} start The starting address.
@param {CodeMap.CodeEntry} codeEntry Code entry object.
###
CodeMap::addLibrary = (start, codeEntry) ->
  @markPages_ start, start + codeEntry.size
  @libraries_.insert start, codeEntry
  return


###*
Adds a static code entry.

@param {number} start The starting address.
@param {CodeMap.CodeEntry} codeEntry Code entry object.
###
CodeMap::addStaticCode = (start, codeEntry) ->
  @statics_.insert start, codeEntry
  return


###*
@private
###
CodeMap::markPages_ = (start, end) ->
  addr = start

  while addr <= end
    @pages_[addr >>> CodeMap.PAGE_ALIGNMENT] = 1
    addr += CodeMap.PAGE_SIZE
  return


###*
@private
###
CodeMap::deleteAllCoveredNodes_ = (tree, start, end) ->
  to_delete = []
  addr = end - 1
  while addr >= start
    node = tree.findGreatestLessThan(addr)
    break  unless node
    start2 = node.key
    end2 = start2 + node.value.size
    to_delete.push start2  if start2 < end and start < end2
    addr = start2 - 1
  i = 0
  l = to_delete.length

  while i < l
    tree.remove to_delete[i]
    ++i
  return


###*
@private
###
CodeMap::isAddressBelongsTo_ = (addr, node) ->
  addr >= node.key and addr < (node.key + node.value.size)


###*
@private
###
CodeMap::findInTree_ = (tree, addr) ->
  node = tree.findGreatestLessThan(addr)
  (if node and @isAddressBelongsTo_(addr, node) then node.value else null)


###*
Finds a code entry that contains the specified address. Both static and
dynamic code entries are considered.

@param {number} addr Address.
###
CodeMap::findEntry = (addr) ->
  pageAddr = addr >>> CodeMap.PAGE_ALIGNMENT
  
  # Static code entries can contain "holes" of unnamed code.
  # In this case, the whole library is assigned to this address.
  return @findInTree_(@statics_, addr) or @findInTree_(@libraries_, addr)  if pageAddr of @pages_
  min = @dynamics_.findMin()
  max = @dynamics_.findMax()
  if max? and addr < (max.key + max.value.size) and addr >= min.key
    dynaEntry = @findInTree_(@dynamics_, addr)
    return null  unless dynaEntry?
    
    # Dedupe entry name.
    unless dynaEntry.nameUpdated_
      dynaEntry.name = @dynamicsNameGen_.getName(dynaEntry.name)
      dynaEntry.nameUpdated_ = true
    return dynaEntry
  null


###*
Returns a dynamic code entry using its starting address.

@param {number} addr Address.
###
CodeMap::findDynamicEntryByStartAddress = (addr) ->
  node = @dynamics_.find(addr)
  (if node then node.value else null)


###*
Returns an array of all dynamic code entries.
###
CodeMap::getAllDynamicEntries = ->
  @dynamics_.exportValues()


###*
Returns an array of pairs of all dynamic code entries and their addresses.
###
CodeMap::getAllDynamicEntriesWithAddresses = ->
  @dynamics_.exportKeysAndValues()


###*
Returns an array of all static code entries.
###
CodeMap::getAllStaticEntries = ->
  @statics_.exportValues()


###*
Returns an array of all libraries entries.
###
CodeMap::getAllLibrariesEntries = ->
  @libraries_.exportValues()


###*
Creates a code entry object.

@param {number} size Code entry size in bytes.
@param {string} opt_name Code entry name.
@param {string} opt_type Code entry type, e.g. SHARED_LIB, CPP.
@constructor
###
CodeMap.CodeEntry = (size, opt_name, opt_type) ->
  @size = size
  @name = opt_name or ""
  @type = opt_type or ""
  @nameUpdated_ = false
  return

CodeMap.CodeEntry::getName = ->
  @name

CodeMap.CodeEntry::toString = ->
  @name + ": " + @size.toString(16)

CodeMap.NameGenerator = ->
  @knownNames_ = {}
  return

CodeMap.NameGenerator::getName = (name) ->
  unless name of @knownNames_
    @knownNames_[name] = 0
    return name
  count = ++@knownNames_[name]
  name + " {" + count + "}"
