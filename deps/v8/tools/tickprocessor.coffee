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
inherits = (childCtor, parentCtor) ->
  childCtor::__proto__ = parentCtor::
  return
V8Profile = (separateIc) ->
  Profile.call this
  unless separateIc
    @skipThisFunction = (name) ->
      V8Profile.IC_RE.test name
  return

###*
A thin wrapper around shell's 'read' function showing a file name on error.
###
readFile = (fileName) ->
  try
    return read(fileName)
  catch e
    print fileName + ": " + (e.message or e)
    throw e
  return

###*
Parser for dynamic code optimization state.
###
parseState = (s) ->
  switch s
    when ""
      return Profile.CodeState.COMPILED
    when "~"
      return Profile.CodeState.OPTIMIZABLE
    when "*"
      return Profile.CodeState.OPTIMIZED
  throw new Error("unknown code state: " + s)return
SnapshotLogProcessor = ->
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

    "code-delete":
      parsers: [parseInt]
      processor: @processCodeDelete

    "function-creation": null
    "function-move": null
    "function-delete": null
    "sfi-move": null
    "snapshot-pos":
      parsers: [
        parseInt
        parseInt
      ]
      processor: @processSnapshotPosition

  V8Profile::handleUnknownCode = (operation, addr) ->
    op = Profile.Operation
    switch operation
      when op.MOVE
        print "Snapshot: Code move event for unknown code: 0x" + addr.toString(16)
      when op.DELETE
        print "Snapshot: Code delete event for unknown code: 0x" + addr.toString(16)

  @profile_ = new V8Profile()
  @serializedEntries_ = []
  return
TickProcessor = (cppEntriesProvider, separateIc, callGraphSize, ignoreUnknown, stateFilter, snapshotLogProcessor, distortion, range, sourceMap) ->
  LogReader.call this,
    "shared-library":
      parsers: [
        null
        parseInt
        parseInt
      ]
      processor: @processSharedLibrary

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

    "code-delete":
      parsers: [parseInt]
      processor: @processCodeDelete

    "sfi-move":
      parsers: [
        parseInt
        parseInt
      ]
      processor: @processFunctionMove

    "snapshot-pos":
      parsers: [
        parseInt
        parseInt
      ]
      processor: @processSnapshotPosition

    tick:
      parsers: [
        parseInt
        parseInt
        parseInt
        parseInt
        parseInt
        "var-args"
      ]
      processor: @processTick

    "heap-sample-begin":
      parsers: [
        null
        null
        parseInt
      ]
      processor: @processHeapSampleBegin

    "heap-sample-end":
      parsers: [
        null
        null
      ]
      processor: @processHeapSampleEnd

    "timer-event-start":
      parsers: [
        null
        null
        null
      ]
      processor: @advanceDistortion

    "timer-event-end":
      parsers: [
        null
        null
        null
      ]
      processor: @advanceDistortion

    
    # Ignored events.
    profiler: null
    "function-creation": null
    "function-move": null
    "function-delete": null
    "heap-sample-item": null
    
    # Obsolete row types.
    "code-allocate": null
    "begin-code-region": null
    "end-code-region": null

  @cppEntriesProvider_ = cppEntriesProvider
  @callGraphSize_ = callGraphSize
  @ignoreUnknown_ = ignoreUnknown
  @stateFilter_ = stateFilter
  @snapshotLogProcessor_ = snapshotLogProcessor
  @sourceMap = sourceMap
  @deserializedEntriesNames_ = []
  ticks = @ticks_ =
    total: 0
    unaccounted: 0
    excluded: 0
    gc: 0

  distortion = parseInt(distortion)
  
  # Convert picoseconds to nanoseconds.
  @distortion_per_entry = (if isNaN(distortion) then 0 else (distortion / 1000))
  @distortion = 0
  rangelimits = (if range then range.split(",") else [])
  range_start = parseInt(rangelimits[0])
  range_end = parseInt(rangelimits[1])
  
  # Convert milliseconds to nanoseconds.
  @range_start = (if isNaN(range_start) then -Infinity else (range_start * 1000))
  @range_end = (if isNaN(range_end) then Infinity else (range_end * 1000))
  V8Profile::handleUnknownCode = (operation, addr, opt_stackPos) ->
    op = Profile.Operation
    switch operation
      when op.MOVE
        print "Code move event for unknown code: 0x" + addr.toString(16)
      when op.DELETE
        print "Code delete event for unknown code: 0x" + addr.toString(16)
      when op.TICK
        
        # Only unknown PCs (the first frame) are reported as unaccounted,
        # otherwise tick balance will be corrupted (this behavior is compatible
        # with the original tickprocessor.py script.)
        ticks.unaccounted++  if opt_stackPos is 0

  @profile_ = new V8Profile(separateIc)
  @codeTypes_ = {}
  
  # Count each tick as a time unit.
  @viewBuilder_ = new ViewBuilder(1)
  @lastLogFileName_ = null
  @generation_ = 1
  @currentProducerProfile_ = null
  return

# Otherwise, this is JS-related code. We are not adding it to
# codeTypes_ map because there can be zillions of them.

###*
@override
###

# Hack file name to avoid dealing with platform specifics.

# Don't use PC when in external callback code, as it can point
# inside callback's code, and we will erroneously report
# that a callback calls itself. Instead we use tos_or_external_callback,
# as simply resetting PC will produce unaccounted ticks.

# Find out, if top of stack was pointing inside a JS function
# meaning that we have encountered a frameless invocation.

# Sort by total time, desc, then by name, desc.

# Sort by self time, desc, then by name, desc.

# Count library ticks

# To show the same percentages as in the flat profile.

# Sort by total time, desc, then by name, desc.
padLeft = (s, len) ->
  s = s.toString()
  if s.length < len
    padLength = len - s.length
    padLeft[padLength] = new Array(padLength + 1).join(" ")  unless padLength of padLeft
    s = padLeft[padLength] + s
  s

# in source maps lines and columns are zero based

# Cut off too infrequent callers.

# Limit backtrace depth.

# Delimit top-level functions.
CppEntriesProvider = ->

# Several functions can be mapped onto the same address. To avoid
# creating zero-sized entries, skip such duplicates.
# Also double-check that function belongs to the library address space.
UnixCppEntriesProvider = (nmExec, targetRootFS) ->
  @symbols = []
  @parsePos = 0
  @nmExec = nmExec
  @targetRootFS = targetRootFS
  @FUNC_RE = /^([0-9a-fA-F]{8,16}) ([0-9a-fA-F]{8,16} )?[tTwW] (.*)$/
  return

# If the library cannot be found on this system let's not panic.
MacCppEntriesProvider = (nmExec, targetRootFS) ->
  UnixCppEntriesProvider.call this, nmExec, targetRootFS
  
  # Note an empty group. It is required, as UnixCppEntriesProvider expects 3 groups.
  @FUNC_RE = /^([0-9a-fA-F]{8,16}) ()[iItT] (.*)$/
  return

# If the library cannot be found on this system let's not panic.
WindowsCppEntriesProvider = (_ignored_nmExec, targetRootFS) ->
  @targetRootFS = targetRootFS
  @symbols = ""
  @parsePos = 0
  return

# This is almost a constant on Windows.

# If .map file cannot be found let's not panic.

# Image base entry is above all other symbols, so we can just
# terminate parsing.

###*
Performs very simple unmangling of C++ names.

Does not handle arguments and template arguments. The mangled names have
the form:

?LookupInDescriptor@JSObject@internal@v8@@...arguments info...
###

# Empty or non-mangled name.
ArgumentsProcessor = (args) ->
  @args_ = args
  @result_ = ArgumentsProcessor.DEFAULTS
  @argsDispatch_ =
    "-j": [
      "stateFilter"
      TickProcessor.VmStates.JS
      "Show only ticks from JS VM state"
    ]
    "-g": [
      "stateFilter"
      TickProcessor.VmStates.GC
      "Show only ticks from GC VM state"
    ]
    "-c": [
      "stateFilter"
      TickProcessor.VmStates.COMPILER
      "Show only ticks from COMPILER VM state"
    ]
    "-o": [
      "stateFilter"
      TickProcessor.VmStates.OTHER
      "Show only ticks from OTHER VM state"
    ]
    "-e": [
      "stateFilter"
      TickProcessor.VmStates.EXTERNAL
      "Show only ticks from EXTERNAL VM state"
    ]
    "--call-graph-size": [
      "callGraphSize"
      TickProcessor.CALL_GRAPH_SIZE
      "Set the call graph size"
    ]
    "--ignore-unknown": [
      "ignoreUnknown"
      true
      "Exclude ticks of unknown code entries from processing"
    ]
    "--separate-ic": [
      "separateIc"
      true
      "Separate IC entries"
    ]
    "--unix": [
      "platform"
      "unix"
      "Specify that we are running on *nix platform"
    ]
    "--windows": [
      "platform"
      "windows"
      "Specify that we are running on Windows platform"
    ]
    "--mac": [
      "platform"
      "mac"
      "Specify that we are running on Mac OS X platform"
    ]
    "--nm": [
      "nm"
      "nm"
      "Specify the 'nm' executable to use (e.g. --nm=/my_dir/nm)"
    ]
    "--target": [
      "targetRootFS"
      ""
      "Specify the target root directory for cross environment"
    ]
    "--snapshot-log": [
      "snapshotLogFileName"
      "snapshot.log"
      "Specify snapshot log file to use (e.g. --snapshot-log=snapshot.log)"
    ]
    "--range": [
      "range"
      "auto,auto"
      "Specify the range limit as [start],[end]"
    ]
    "--distortion": [
      "distortion"
      0
      "Specify the logging overhead in picoseconds"
    ]
    "--source-map": [
      "sourceMap"
      null
      "Specify the source map that should be used for output"
    ]

  @argsDispatch_["--js"] = @argsDispatch_["-j"]
  @argsDispatch_["--gc"] = @argsDispatch_["-g"]
  @argsDispatch_["--compiler"] = @argsDispatch_["-c"]
  @argsDispatch_["--other"] = @argsDispatch_["-o"]
  @argsDispatch_["--external"] = @argsDispatch_["-e"]
  return
inherits V8Profile, Profile
V8Profile.IC_RE = /^(?:CallIC|LoadIC|StoreIC)|(?:Builtin: (?:Keyed)?(?:Call|Load|Store)IC_)/
inherits SnapshotLogProcessor, LogReader
SnapshotLogProcessor::processCodeCreation = (type, kind, start, size, name, maybe_func) ->
  if maybe_func.length
    funcAddr = parseInt(maybe_func[0])
    state = parseState(maybe_func[1])
    @profile_.addFuncCode type, name, start, size, funcAddr, state
  else
    @profile_.addCode type, name, start, size
  return

SnapshotLogProcessor::processCodeMove = (from, to) ->
  @profile_.moveCode from, to
  return

SnapshotLogProcessor::processCodeDelete = (start) ->
  @profile_.deleteCode start
  return

SnapshotLogProcessor::processSnapshotPosition = (addr, pos) ->
  @serializedEntries_[pos] = @profile_.findEntry(addr)
  return

SnapshotLogProcessor::processLogFile = (fileName) ->
  contents = readFile(fileName)
  @processLogChunk contents
  return

SnapshotLogProcessor::getSerializedEntryName = (pos) ->
  entry = @serializedEntries_[pos]
  (if entry then entry.getRawName() else null)

inherits TickProcessor, LogReader
TickProcessor.VmStates =
  JS: 0
  GC: 1
  COMPILER: 2
  OTHER: 3
  EXTERNAL: 4
  IDLE: 5

TickProcessor.CodeTypes =
  CPP: 0
  SHARED_LIB: 1

TickProcessor.CALL_PROFILE_CUTOFF_PCT = 2.0
TickProcessor.CALL_GRAPH_SIZE = 5
TickProcessor::printError = (str) ->
  print str
  return

TickProcessor::setCodeType = (name, type) ->
  @codeTypes_[name] = TickProcessor.CodeTypes[type]
  return

TickProcessor::isSharedLibrary = (name) ->
  @codeTypes_[name] is TickProcessor.CodeTypes.SHARED_LIB

TickProcessor::isCppCode = (name) ->
  @codeTypes_[name] is TickProcessor.CodeTypes.CPP

TickProcessor::isJsCode = (name) ->
  (name not of @codeTypes_)

TickProcessor::processLogFile = (fileName) ->
  @lastLogFileName_ = fileName
  line = undefined
  @processLogLine line  while line = readline()
  return

TickProcessor::processLogFileInTest = (fileName) ->
  @lastLogFileName_ = "v8.log"
  contents = readFile(fileName)
  @processLogChunk contents
  return

TickProcessor::processSharedLibrary = (name, startAddr, endAddr) ->
  entry = @profile_.addLibrary(name, startAddr, endAddr)
  @setCodeType entry.getName(), "SHARED_LIB"
  self = this
  libFuncs = @cppEntriesProvider_.parseVmSymbols(name, startAddr, endAddr, (fName, fStart, fEnd) ->
    self.profile_.addStaticCode fName, fStart, fEnd
    self.setCodeType fName, "CPP"
    return
  )
  return

TickProcessor::processCodeCreation = (type, kind, start, size, name, maybe_func) ->
  name = @deserializedEntriesNames_[start] or name
  if maybe_func.length
    funcAddr = parseInt(maybe_func[0])
    state = parseState(maybe_func[1])
    @profile_.addFuncCode type, name, start, size, funcAddr, state
  else
    @profile_.addCode type, name, start, size
  return

TickProcessor::processCodeMove = (from, to) ->
  @profile_.moveCode from, to
  return

TickProcessor::processCodeDelete = (start) ->
  @profile_.deleteCode start
  return

TickProcessor::processFunctionMove = (from, to) ->
  @profile_.moveFunc from, to
  return

TickProcessor::processSnapshotPosition = (addr, pos) ->
  @deserializedEntriesNames_[addr] = @snapshotLogProcessor_.getSerializedEntryName(pos)  if @snapshotLogProcessor_
  return

TickProcessor::includeTick = (vmState) ->
  not @stateFilter_? or @stateFilter_ is vmState

TickProcessor::processTick = (pc, ns_since_start, is_external_callback, tos_or_external_callback, vmState, stack) ->
  @distortion += @distortion_per_entry
  ns_since_start -= @distortion
  return  if ns_since_start < @range_start or ns_since_start > @range_end
  @ticks_.total++
  @ticks_.gc++  if vmState is TickProcessor.VmStates.GC
  unless @includeTick(vmState)
    @ticks_.excluded++
    return
  if is_external_callback
    pc = tos_or_external_callback
    tos_or_external_callback = 0
  else if tos_or_external_callback
    funcEntry = @profile_.findEntry(tos_or_external_callback)
    tos_or_external_callback = 0  if not funcEntry or not funcEntry.isJSFunction or not funcEntry.isJSFunction()
  @profile_.recordTick @processStack(pc, tos_or_external_callback, stack)
  return

TickProcessor::advanceDistortion = ->
  @distortion += @distortion_per_entry
  return

TickProcessor::processHeapSampleBegin = (space, state, ticks) ->
  return  unless space is "Heap"
  @currentProducerProfile_ = new CallTree()
  return

TickProcessor::processHeapSampleEnd = (space, state) ->
  return  if space isnt "Heap" or not @currentProducerProfile_
  print "Generation " + @generation_ + ":"
  tree = @currentProducerProfile_
  tree.computeTotalWeights()
  producersView = @viewBuilder_.buildView(tree)
  producersView.sort (rec1, rec2) ->
    rec2.totalTime - rec1.totalTime or ((if rec2.internalFuncName < rec1.internalFuncName then -1 else 1))

  @printHeavyProfile producersView.head.children
  @currentProducerProfile_ = null
  @generation_++
  return

TickProcessor::printStatistics = ->
  print "Statistical profiling result from " + @lastLogFileName_ + ", (" + @ticks_.total + " ticks, " + @ticks_.unaccounted + " unaccounted, " + @ticks_.excluded + " excluded)."
  return  if @ticks_.total is 0
  flatProfile = @profile_.getFlatProfile()
  flatView = @viewBuilder_.buildView(flatProfile)
  flatView.sort (rec1, rec2) ->
    rec2.selfTime - rec1.selfTime or ((if rec2.internalFuncName < rec1.internalFuncName then -1 else 1))

  totalTicks = @ticks_.total
  totalTicks -= @ticks_.unaccounted  if @ignoreUnknown_
  flatViewNodes = flatView.head.children
  self = this
  libraryTicks = 0
  @printHeader "Shared libraries"
  @printEntries flatViewNodes, totalTicks, null, ((name) ->
    self.isSharedLibrary name
  ), (rec) ->
    libraryTicks += rec.selfTime
    return

  nonLibraryTicks = totalTicks - libraryTicks
  jsTicks = 0
  @printHeader "JavaScript"
  @printEntries flatViewNodes, totalTicks, nonLibraryTicks, ((name) ->
    self.isJsCode name
  ), (rec) ->
    jsTicks += rec.selfTime
    return

  cppTicks = 0
  @printHeader "C++"
  @printEntries flatViewNodes, totalTicks, nonLibraryTicks, ((name) ->
    self.isCppCode name
  ), (rec) ->
    cppTicks += rec.selfTime
    return

  @printHeader "Summary"
  @printLine "JavaScript", jsTicks, totalTicks, nonLibraryTicks
  @printLine "C++", cppTicks, totalTicks, nonLibraryTicks
  @printLine "GC", @ticks_.gc, totalTicks, nonLibraryTicks
  @printLine "Shared libraries", libraryTicks, totalTicks, null
  @printLine "Unaccounted", @ticks_.unaccounted, @ticks_.total, null  if not @ignoreUnknown_ and @ticks_.unaccounted > 0
  print "\n [C++ entry points]:"
  print "   ticks    cpp   total   name"
  c_entry_functions = @profile_.getCEntryProfile()
  total_c_entry = c_entry_functions[0].ticks
  i = 1

  while i < c_entry_functions.length
    c = c_entry_functions[i]
    @printLine c.name, c.ticks, total_c_entry, totalTicks
    i++
  @printHeavyProfHeader()
  heavyProfile = @profile_.getBottomUpProfile()
  heavyView = @viewBuilder_.buildView(heavyProfile)
  heavyView.head.totalTime = totalTicks
  heavyView.sort (rec1, rec2) ->
    rec2.totalTime - rec1.totalTime or ((if rec2.internalFuncName < rec1.internalFuncName then -1 else 1))

  @printHeavyProfile heavyView.head.children
  return

TickProcessor::printHeader = (headerTitle) ->
  print "\n [" + headerTitle + "]:"
  print "   ticks  total  nonlib   name"
  return

TickProcessor::printLine = (entry, ticks, totalTicks, nonLibTicks) ->
  pct = ticks * 100 / totalTicks
  nonLibPct = (if nonLibTicks? then padLeft((ticks * 100 / nonLibTicks).toFixed(1), 5) + "%  " else "        ")
  print "  " + padLeft(ticks, 5) + "  " + padLeft(pct.toFixed(1), 5) + "%  " + nonLibPct + entry
  return

TickProcessor::printHeavyProfHeader = ->
  print "\n [Bottom up (heavy) profile]:"
  print "  Note: percentage shows a share of a particular caller in the " + "total\n" + "  amount of its parent calls."
  print "  Callers occupying less than " + TickProcessor.CALL_PROFILE_CUTOFF_PCT.toFixed(1) + "% are not shown.\n"
  print "   ticks parent  name"
  return

TickProcessor::processProfile = (profile, filterP, func) ->
  i = 0
  n = profile.length

  while i < n
    rec = profile[i]
    continue  unless filterP(rec.internalFuncName)
    func rec
    ++i
  return

TickProcessor::getLineAndColumn = (name) ->
  re = /:([0-9]+):([0-9]+)$/
  array = re.exec(name)
  return null  unless array
  line: array[1]
  column: array[2]

TickProcessor::hasSourceMap = ->
  @sourceMap?

TickProcessor::formatFunctionName = (funcName) ->
  return funcName  unless @hasSourceMap()
  lc = @getLineAndColumn(funcName)
  return funcName  unless lc?
  lineNumber = lc.line - 1
  column = lc.column - 1
  entry = @sourceMap.findEntry(lineNumber, column)
  sourceFile = entry[2]
  sourceLine = entry[3] + 1
  sourceColumn = entry[4] + 1
  sourceFile + ":" + sourceLine + ":" + sourceColumn + " -> " + funcName

TickProcessor::printEntries = (profile, totalTicks, nonLibTicks, filterP, callback) ->
  that = this
  @processProfile profile, filterP, (rec) ->
    return  if rec.selfTime is 0
    callback rec
    funcName = that.formatFunctionName(rec.internalFuncName)
    that.printLine funcName, rec.selfTime, totalTicks, nonLibTicks
    return

  return

TickProcessor::printHeavyProfile = (profile, opt_indent) ->
  self = this
  indent = opt_indent or 0
  indentStr = padLeft("", indent)
  @processProfile profile, (->
    true
  ), (rec) ->
    return  if rec.parentTotalPercent < TickProcessor.CALL_PROFILE_CUTOFF_PCT
    funcName = self.formatFunctionName(rec.internalFuncName)
    print "  " + padLeft(rec.totalTime, 5) + "  " + padLeft(rec.parentTotalPercent.toFixed(1), 5) + "%  " + indentStr + funcName
    self.printHeavyProfile rec.children, indent + 2  if indent < 2 * self.callGraphSize_
    print ""  if indent is 0
    return

  return

CppEntriesProvider::parseVmSymbols = (libName, libStart, libEnd, processorFunc) ->
  addEntry = (funcInfo) ->
    processorFunc prevEntry.name, prevEntry.start, funcInfo.start  if prevEntry and not prevEntry.end and prevEntry.start < funcInfo.start and prevEntry.start >= libStart and funcInfo.start <= libEnd
    processorFunc funcInfo.name, funcInfo.start, funcInfo.end  if funcInfo.end and (not prevEntry or prevEntry.start isnt funcInfo.start) and funcInfo.start >= libStart and funcInfo.end <= libEnd
    prevEntry = funcInfo
    return
  @loadSymbols libName
  prevEntry = undefined
  loop
    funcInfo = @parseNextLine()
    if funcInfo is null
      continue
    else break  if funcInfo is false
    funcInfo.start += libStart  if funcInfo.start < libStart and funcInfo.start < libEnd - libStart
    funcInfo.end = funcInfo.start + funcInfo.size  if funcInfo.size
    addEntry funcInfo
  addEntry
    name: ""
    start: libEnd

  return

CppEntriesProvider::loadSymbols = (libName) ->

CppEntriesProvider::parseNextLine = ->
  false

inherits UnixCppEntriesProvider, CppEntriesProvider
UnixCppEntriesProvider::loadSymbols = (libName) ->
  @parsePos = 0
  libName = @targetRootFS + libName
  try
    @symbols = [
      os.system(@nmExec, [
        "-C"
        "-n"
        "-S"
        libName
      ], -1, -1)
      os.system(@nmExec, [
        "-C"
        "-n"
        "-S"
        "-D"
        libName
      ], -1, -1)
    ]
  catch e
    @symbols = [
      ""
      ""
    ]
  return

UnixCppEntriesProvider::parseNextLine = ->
  return false  if @symbols.length is 0
  lineEndPos = @symbols[0].indexOf("\n", @parsePos)
  if lineEndPos is -1
    @symbols.shift()
    @parsePos = 0
    return @parseNextLine()
  line = @symbols[0].substring(@parsePos, lineEndPos)
  @parsePos = lineEndPos + 1
  fields = line.match(@FUNC_RE)
  funcInfo = null
  if fields
    funcInfo =
      name: fields[3]
      start: parseInt(fields[1], 16)

    funcInfo.size = parseInt(fields[2], 16)  if fields[2]
  funcInfo

inherits MacCppEntriesProvider, UnixCppEntriesProvider
MacCppEntriesProvider::loadSymbols = (libName) ->
  @parsePos = 0
  libName = @targetRootFS + libName
  try
    @symbols = [
      os.system(@nmExec, [
        "-n"
        "-f"
        libName
      ], -1, -1)
      ""
    ]
  catch e
    @symbols = ""
  return

inherits WindowsCppEntriesProvider, CppEntriesProvider
WindowsCppEntriesProvider.FILENAME_RE = /^(.*)\.([^.]+)$/
WindowsCppEntriesProvider.FUNC_RE = /^\s+0001:[0-9a-fA-F]{8}\s+([_\?@$0-9a-zA-Z]+)\s+([0-9a-fA-F]{8}).*$/
WindowsCppEntriesProvider.IMAGE_BASE_RE = /^\s+0000:00000000\s+___ImageBase\s+([0-9a-fA-F]{8}).*$/
WindowsCppEntriesProvider.EXE_IMAGE_BASE = 0x00400000
WindowsCppEntriesProvider::loadSymbols = (libName) ->
  libName = @targetRootFS + libName
  fileNameFields = libName.match(WindowsCppEntriesProvider.FILENAME_RE)
  return  unless fileNameFields
  mapFileName = fileNameFields[1] + ".map"
  @moduleType_ = fileNameFields[2].toLowerCase()
  try
    @symbols = read(mapFileName)
  catch e
    @symbols = ""
  return

WindowsCppEntriesProvider::parseNextLine = ->
  lineEndPos = @symbols.indexOf("\r\n", @parsePos)
  return false  if lineEndPos is -1
  line = @symbols.substring(@parsePos, lineEndPos)
  @parsePos = lineEndPos + 2
  imageBaseFields = line.match(WindowsCppEntriesProvider.IMAGE_BASE_RE)
  if imageBaseFields
    imageBase = parseInt(imageBaseFields[1], 16)
    return false  unless (@moduleType_ is "exe") is (imageBase is WindowsCppEntriesProvider.EXE_IMAGE_BASE)
  fields = line.match(WindowsCppEntriesProvider.FUNC_RE)
  (if fields then
    name: @unmangleName(fields[1])
    start: parseInt(fields[2], 16)
   else null)

WindowsCppEntriesProvider::unmangleName = (name) ->
  return name  if name.length < 1 or name.charAt(0) isnt "?"
  nameEndPos = name.indexOf("@@")
  components = name.substring(1, nameEndPos).split("@")
  components.reverse()
  components.join "::"

ArgumentsProcessor.DEFAULTS =
  logFileName: "v8.log"
  snapshotLogFileName: null
  platform: "unix"
  stateFilter: null
  callGraphSize: 5
  ignoreUnknown: false
  separateIc: false
  targetRootFS: ""
  nm: "nm"
  range: "auto,auto"
  distortion: 0

ArgumentsProcessor::parse = ->
  while @args_.length
    arg = @args_[0]
    break  unless arg.charAt(0) is "-"
    @args_.shift()
    userValue = null
    eqPos = arg.indexOf("=")
    unless eqPos is -1
      userValue = arg.substr(eqPos + 1)
      arg = arg.substr(0, eqPos)
    if arg of @argsDispatch_
      dispatch = @argsDispatch_[arg]
      @result_[dispatch[0]] = (if not userValue? then dispatch[1] else userValue)
    else
      return false
  @result_.logFileName = @args_.shift()  if @args_.length >= 1
  true

ArgumentsProcessor::result = ->
  @result_

ArgumentsProcessor::printUsageAndExit = ->
  padRight = (s, len) ->
    s = s.toString()
    s = s + (new Array(len - s.length + 1).join(" "))  if s.length < len
    s
  print "Cmdline args: [options] [log-file-name]\n" + "Default log file name is \"" + ArgumentsProcessor.DEFAULTS.logFileName + "\".\n"
  print "Options:"
  for arg of @argsDispatch_
    synonims = [arg]
    dispatch = @argsDispatch_[arg]
    for synArg of @argsDispatch_
      if arg isnt synArg and dispatch is @argsDispatch_[synArg]
        synonims.push synArg
        delete @argsDispatch_[synArg]
    print "  " + padRight(synonims.join(", "), 20) + dispatch[2]
  quit 2
  return
