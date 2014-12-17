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

# This is a supplementary file for test-log/EquivalenceOfLoggingAndTraversal.
parseState = (s) ->
  switch s
    when ""
      return Profile.CodeState.COMPILED
    when "~"
      return Profile.CodeState.OPTIMIZABLE
    when "*"
      return Profile.CodeState.OPTIMIZED
  throw new Error("unknown code state: " + s)return
LogProcessor = ->
  LogReader.call this,
    "code-creation":
      parsers: [
        null
        parseInt
        parseInt
        parseInt
        null
        "var-args"
      ]
      processor: @processCodeCreation

    "code-move":
      parsers: [
        parseInt
        parseInt
      ]
      processor: @processCodeMove

    "code-delete": null
    "sfi-move":
      parsers: [
        parseInt
        parseInt
      ]
      processor: @processFunctionMove

    "shared-library": null
    profiler: null
    tick: null

  @profile = new Profile()
  return

# Scripts will compile into anonymous functions starting at 1:1. Adjust the
# name here so that it matches corrsponding function's name during the heap
# traversal.

# Discard types to avoid discrepancies in "LazyCompile" vs. "Function".
RunTest = ->
  
  # _log must be provided externally.
  addressComparator = (entryA, entryB) ->
    (if entryA[0] < entryB[0] then -1 else ((if entryA[0] > entryB[0] then 1 else 0)))
  entityNamesEqual = (entityA, entityB) ->
    return true  if "getRawName" of entityB and entityNamesEqual.builtins.indexOf(entityB.getRawName()) isnt -1
    return true  if entityNamesEqual.builtins.indexOf(entityB.getName()) isnt -1
    entityA.getName() is entityB.getName()
  entitiesEqual = (entityA, entityB) ->
    return true  if (entityA is null and entityB isnt null) or (entityA isnt null and entityB is null)
    entityA.size is entityB.size and entityNamesEqual(entityA, entityB)
  log_lines = _log.split("\n")
  line = undefined
  pos = 0
  log_lines_length = log_lines.length
  return "log_lines_length < 2"  if log_lines_length < 2
  logging_processor = new LogProcessor()
  while pos < log_lines_length
    line = log_lines[pos]
    if line is "test-logging-done,\"\""
      ++pos
      break
    logging_processor.processLogLine line
    ++pos
  logging_processor.profile.cleanUpFuncEntries()
  logging_entries = logging_processor.profile.codeMap_.getAllDynamicEntriesWithAddresses()
  return "logging_entries.length === 0"  if logging_entries.length is 0
  traversal_processor = new LogProcessor()
  while pos < log_lines_length
    line = log_lines[pos]
    break  if line is "test-traversal-done,\"\""
    traversal_processor.processLogLine line
    ++pos
  traversal_entries = traversal_processor.profile.codeMap_.getAllDynamicEntriesWithAddresses()
  return "traversal_entries.length === 0"  if traversal_entries.length is 0
  logging_entries.sort addressComparator
  traversal_entries.sort addressComparator
  entityNamesEqual.builtins = [
    "Boolean"
    "Function"
    "Number"
    "Object"
    "Script"
    "String"
    "RegExp"
    "Date"
    "Error"
  ]
  l_pos = 0
  t_pos = 0
  l_len = logging_entries.length
  t_len = traversal_entries.length
  comparison = []
  equal = true
  
  # Do a merge-like comparison of entries. At the same address we expect to
  # find the same entries. We skip builtins during log parsing, but compiled
  # functions traversal may erroneously recognize them as functions, so we are
  # expecting more functions in traversal vs. logging.
  # Since we don't track code deletions, logging can also report more entries
  # than traversal.
  while l_pos < l_len and t_pos < t_len
    entryA = logging_entries[l_pos]
    entryB = traversal_entries[t_pos]
    cmp = addressComparator(entryA, entryB)
    entityA = entryA[1]
    entityB = entryB[1]
    address = entryA[0]
    if cmp < 0
      ++l_pos
      entityB = null
    else if cmp > 0
      ++t_pos
      entityA = null
      address = entryB[0]
    else
      ++l_pos
      ++t_pos
    entities_equal = entitiesEqual(entityA, entityB)
    equal = false  unless entities_equal
    comparison.push [
      entities_equal
      address
      entityA
      entityB
    ]
  [
    equal
    comparison
  ]
LogProcessor::__proto__ = LogReader::
LogProcessor::processCodeCreation = (type, kind, start, size, name, maybe_func) ->
  return  if type isnt "LazyCompile" and type isnt "Script" and type isnt "Function"
  name = " :1:1"  if type is "Script"
  type = ""
  if maybe_func.length
    funcAddr = parseInt(maybe_func[0])
    state = parseState(maybe_func[1])
    @profile.addFuncCode type, name, start, size, funcAddr, state
  else
    @profile.addCode type, name, start, size
  return

LogProcessor::processCodeMove = (from, to) ->
  @profile.moveCode from, to
  return

LogProcessor::processFunctionMove = (from, to) ->
  @profile.moveFunc from, to
  return

result = RunTest()
if typeof result isnt "string"
  out = []
  unless result[0]
    comparison = result[1]
    i = 0
    l = comparison.length

    while i < l
      c = comparison[i]
      out.push ((if c[0] then "  " else "* ")) + c[1].toString(16) + " " + ((if c[2] then c[2] else "---")) + " " + ((if c[3] then c[3] else "---"))
      ++i
  (if result[0] then true else out.join("\n"))
else
  result
