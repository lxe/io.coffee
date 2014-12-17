# Copyright 2013 the V8 project authors. All rights reserved.
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
PlotScriptComposer = (kResX, kResY, error_output) ->
  
  # Constants.
  # Stack frames to display in the plot.
  # Width of each timeline.
  # Width of the top stack frame line.
  # Width of the lower stack frame lines.
  # Gap between stack frame lines.
  # Offset for stack frame vs. event lines.
  # Row displaying deopts.
  # Height of marker displaying timed part.
  # Draw size of the largest deopt.
  # Padding for pause time labels.
  # Number of biggest pauses to label.
  # Padding for code kind labels.
  # Duration of half a tick in ms.
  # Minimum length for an event in ms.
  # Number of threads.
  # ID of main thread.
  
  # Init values.
  
  # Data structures.
  TimerEvent = (label, color, pause, thread_id) ->
    assert thread_id >= 0 and thread_id < kNumThreads, "invalid thread id"
    @label = label
    @color = color
    @pause = pause
    @ranges = []
    @thread_id = thread_id
    @index = ++num_timer_event
    return
  CodeKind = (color, kinds) ->
    @color = color
    @in_execution = []
    @stack_frames = []
    i = 0

    while i < kStackFrames
      @stack_frames.push []
      i++
    @kinds = kinds
    return
  Range = (start, end) ->
    @start = start # In milliseconds.
    @end = end # In milliseconds.
    return
  Deopt = (time, size) ->
    @time = time # In milliseconds.
    @size = size # In bytes.
    return
  Tick = (tick) ->
    @tick = tick
    return
  # Milliseconds.
  
  # Utility functions.
  assert = (something, message) ->
    unless something
      error = new Error(message)
      error_output error.stack
    return
  FindCodeKind = (kind) ->
    for name of CodeKinds
      return CodeKinds[name]  if CodeKinds[name].kinds.indexOf(kind) >= 0
    return
  TicksToRanges = (ticks) ->
    ranges = []
    i = 0

    while i < ticks.length
      tick = ticks[i].tick
      ranges.push new Range(tick - kTickHalfDuration, tick + kTickHalfDuration)
      i++
    ranges
  MergeRanges = (ranges) ->
    ranges.sort (a, b) ->
      a.start - b.start

    result = []
    j = 0
    i = 0

    while i < ranges.length
      merge_start = ranges[i].start
      break  if merge_start > range_end # Out of plot range.
      merge_end = ranges[i].end
      j = i + 1
      while j < ranges.length
        next_range = ranges[j]
        
        # Don't merge ranges if there is no overlap (incl. merge tolerance).
        break  if next_range.start > merge_end + pause_tolerance
        
        # Merge ranges.
        # Extend range end.
        merge_end = next_range.end  if next_range.end > merge_end
        j++
      continue  if merge_end < range_start # Out of plot range.
      continue  if merge_end < merge_start # Not an actual range.
      result.push new Range(merge_start, merge_end)
      i = j
    result
  RestrictRangesTo = (ranges, start, end) ->
    result = []
    i = 0

    while i < ranges.length
      result.push new Range(Math.max(ranges[i].start, start), Math.min(ranges[i].end, end))  if ranges[i].start <= end and ranges[i].end >= start
      i++
    result
  kV8BinarySuffixes = [
    "/d8"
    "/libv8.so"
  ]
  kStackFrames = 8
  kTimerEventWidth = 0.33
  kExecutionFrameWidth = 0.2
  kStackFrameWidth = 0.1
  kGapWidth = 0.05
  kY1Offset = 11
  kDeoptRow = 7
  kGetTimeHeight = 0.5
  kMaxDeoptLength = 4
  kPauseLabelPadding = 5
  kNumPauseLabels = 7
  kCodeKindLabelPadding = 100
  kTickHalfDuration = 0.5
  kMinRangeLength = 0.0005
  kNumThreads = 2
  kExecutionThreadId = 0
  num_timer_event = kY1Offset + 0.5
  Range::duration = ->
    @end - @start

  TimerEvents =
    "V8.Execute": new TimerEvent("execution", "#000000", false, 0)
    "V8.External": new TimerEvent("external", "#3399FF", false, 0)
    "V8.CompileFullCode": new TimerEvent("compile unopt", "#CC0000", true, 0)
    "V8.RecompileSynchronous": new TimerEvent("recompile sync", "#CC0044", true, 0)
    "V8.RecompileConcurrent": new TimerEvent("recompile async", "#CC4499", false, 1)
    "V8.CompileEval": new TimerEvent("compile eval", "#CC4400", true, 0)
    "V8.IcMiss": new TimerEvent("ic miss", "#CC9900", false, 0)
    "V8.Parse": new TimerEvent("parse", "#00CC00", true, 0)
    "V8.PreParse": new TimerEvent("preparse", "#44CC00", true, 0)
    "V8.ParseLazy": new TimerEvent("lazy parse", "#00CC44", true, 0)
    "V8.GCScavenger": new TimerEvent("gc scavenge", "#0044CC", true, 0)
    "V8.GCCompactor": new TimerEvent("gc compaction", "#4444CC", true, 0)
    "V8.GCContext": new TimerEvent("gc context", "#4400CC", true, 0)

  CodeKinds =
    "external ": new CodeKind("#3399FF", [-2])
    "runtime  ": new CodeKind("#000000", [-1])
    "full code": new CodeKind("#DD0000", [0])
    "opt code ": new CodeKind("#00EE00", [1])
    "code stub": new CodeKind("#FF00FF", [2])
    "built-in ": new CodeKind("#AA00AA", [3])
    "inl.cache": new CodeKind("#4444AA", [
      4
      5
      6
      7
      8
      9
      10
      11
      12
      13
      14
    ])
    "reg.exp. ": new CodeKind("#0000FF", [15])

  code_map = new CodeMap()
  execution_pauses = []
  deopts = []
  gettime = []
  event_stack = []
  last_time_stamp = []
  i = 0

  while i < kNumThreads
    event_stack[i] = []
    last_time_stamp[i] = -1
    i++
  range_start = `undefined`
  range_end = `undefined`
  obj_index = 0
  pause_tolerance = 0.005
  distortion = 0
  
  # Public methods.
  @collectData = (input, distortion_per_entry) ->
    last_timestamp = 0
    
    # Parse functions.
    parseTimeStamp = (timestamp) ->
      int_timestamp = parseInt(timestamp)
      assert int_timestamp >= last_timestamp, "Inconsistent timestamps."
      last_timestamp = int_timestamp
      distortion += distortion_per_entry
      int_timestamp / 1000 - distortion

    processTimerEventStart = (name, start) ->
      
      # Find out the thread id.
      new_event = TimerEvents[name]
      return  if new_event is `undefined`
      thread_id = new_event.thread_id
      start = Math.max(last_time_stamp[thread_id] + kMinRangeLength, start)
      
      # Last event on this thread is done with the start of this event.
      last_event = event_stack[thread_id].top()
      if last_event isnt `undefined`
        new_range = new Range(last_time_stamp[thread_id], start)
        last_event.ranges.push new_range
      event_stack[thread_id].push new_event
      last_time_stamp[thread_id] = start
      return

    processTimerEventEnd = (name, end) ->
      
      # Find out about the thread_id.
      finished_event = TimerEvents[name]
      thread_id = finished_event.thread_id
      assert finished_event is event_stack[thread_id].pop(), "inconsistent event stack"
      end = Math.max(last_time_stamp[thread_id] + kMinRangeLength, end)
      new_range = new Range(last_time_stamp[thread_id], end)
      finished_event.ranges.push new_range
      last_time_stamp[thread_id] = end
      return

    processCodeCreateEvent = (type, kind, address, size, name) ->
      code_entry = new CodeMap.CodeEntry(size, name)
      code_entry.kind = kind
      code_map.addCode address, code_entry
      return

    processCodeMoveEvent = (from, to) ->
      code_map.moveCode from, to
      return

    processCodeDeleteEvent = (address) ->
      code_map.deleteCode address
      return

    processCodeDeoptEvent = (time, size) ->
      deopts.push new Deopt(time, size)
      return

    processCurrentTimeEvent = (time) ->
      gettime.push time
      return

    processSharedLibrary = (name, start, end) ->
      code_entry = new CodeMap.CodeEntry(end - start, name)
      code_entry.kind = -3 # External code kind.
      i = 0

      while i < kV8BinarySuffixes.length
        suffix = kV8BinarySuffixes[i]
        if name.indexOf(suffix, name.length - suffix.length) >= 0
          code_entry.kind = -1 # V8 runtime code kind.
          break
        i++
      code_map.addLibrary start, code_entry
      return

    processTickEvent = (pc, timer, unused_x, unused_y, vmstate, stack) ->
      tick = new Tick(timer)
      entry = code_map.findEntry(pc)
      FindCodeKind(entry.kind).in_execution.push tick  if entry
      i = 0

      while i < kStackFrames
        break  unless stack[i]
        entry = code_map.findEntry(stack[i])
        FindCodeKind(entry.kind).stack_frames[i].push tick  if entry
        i++
      return

    
    # Collect data from log.
    logreader = new LogReader(
      "timer-event-start":
        parsers: [
          null
          parseTimeStamp
        ]
        processor: processTimerEventStart

      "timer-event-end":
        parsers: [
          null
          parseTimeStamp
        ]
        processor: processTimerEventEnd

      "shared-library":
        parsers: [
          null
          parseInt
          parseInt
        ]
        processor: processSharedLibrary

      "code-creation":
        parsers: [
          null
          parseInt
          parseInt
          parseInt
          null
        ]
        processor: processCodeCreateEvent

      "code-move":
        parsers: [
          parseInt
          parseInt
        ]
        processor: processCodeMoveEvent

      "code-delete":
        parsers: [parseInt]
        processor: processCodeDeleteEvent

      "code-deopt":
        parsers: [
          parseTimeStamp
          parseInt
        ]
        processor: processCodeDeoptEvent

      "current-time":
        parsers: [parseTimeStamp]
        processor: processCurrentTimeEvent

      tick:
        parsers: [
          parseInt
          parseTimeStamp
          null
          null
          parseInt
          "var-args"
        ]
        processor: processTickEvent
    )
    line = undefined
    logreader.processLogLine line  while line = input()
    
    # Collect execution pauses.
    for name of TimerEvents
      event = TimerEvents[name]
      continue  unless event.pause
      ranges = event.ranges
      j = 0

      while j < ranges.length
        execution_pauses.push ranges[j]
        j++
    execution_pauses = MergeRanges(execution_pauses)
    return

  @findPlotRange = (range_start_override, range_end_override, result_callback) ->
    start_found = (range_start_override or range_start_override is 0)
    end_found = (range_end_override or range_end_override is 0)
    range_start = (if start_found then range_start_override else Infinity)
    range_end = (if end_found then range_end_override else -Infinity)
    if not start_found or not end_found
      for name of TimerEvents
        ranges = TimerEvents[name].ranges
        i = 0

        while i < ranges.length
          range_start = ranges[i].start  if ranges[i].start < range_start and not start_found
          range_end = ranges[i].end  if ranges[i].end > range_end and not end_found
          i++
      for codekind of CodeKinds
        ticks = CodeKinds[codekind].in_execution
        i = 0

        while i < ticks.length
          range_start = ticks[i].tick  if ticks[i].tick < range_start and not start_found
          range_end = ticks[i].tick  if ticks[i].tick > range_end and not end_found
          i++
    
    # Set pause tolerance to something appropriate for the plot resolution
    # to make it easier for gnuplot.
    pause_tolerance = (range_end - range_start) / kResX / 10
    result_callback range_start, range_end  if typeof result_callback is "function"
    return

  @assembleOutput = (output) ->
    # Draw thin border box.
    DrawBarBase = (color, start, end, top, bottom, transparency) ->
      obj_index++
      command = "set object " + obj_index + " rect"
      command += " from " + start + ", " + top
      command += " to " + end + ", " + bottom
      command += " fc rgb \"" + color + "\""
      command += " fs transparent solid " + transparency  if transparency
      output command
      return
    DrawBar = (row, color, start, end, width) ->
      DrawBarBase color, start, end, row + width, row - width
      return
    DrawHalfBar = (row, color, start, end, width) ->
      DrawBarBase color, start, end, row, row - width
      return
    output "set yrange [0:" + (num_timer_event + 1) + "]"
    output "set xlabel \"execution time in ms\""
    output "set xrange [" + range_start + ":" + range_end + "]"
    output "set style fill pattern 2 bo 1"
    output "set style rect fs solid 1 noborder"
    output "set style line 1 lt 1 lw 1 lc rgb \"#000000\""
    output "set border 15 lw 0.2"
    output "set style line 2 lt 1 lw 1 lc rgb \"#9944CC\""
    output "set xtics out nomirror"
    output "unset key"
    percentages = {}
    total = 0
    for name of TimerEvents
      event = TimerEvents[name]
      ranges = RestrictRangesTo(event.ranges, range_start, range_end)
      sum = ranges.map((range) ->
        range.duration()
      ).reduce((a, b) ->
        a + b
      , 0)
      percentages[name] = (sum / (range_end - range_start) * 100).toFixed(1)
    
    # Plot deopts.
    deopts.sort (a, b) ->
      b.size - a.size

    max_deopt_size = (if deopts.length > 0 then deopts[0].size else Infinity)
    i = 0

    while i < deopts.length
      deopt = deopts[i]
      DrawHalfBar kDeoptRow, "#9944CC", deopt.time, deopt.time + 10 * pause_tolerance, deopt.size / max_deopt_size * kMaxDeoptLength
      i++
    
    # Plot current time polls.
    if gettime.length > 1
      start = gettime[0]
      end = gettime.pop()
      DrawBarBase "#0000BB", start, end, kGetTimeHeight, 0, 0.2
    
    # Name Y-axis.
    ytics = []
    for name of TimerEvents
      index = TimerEvents[name].index
      label = TimerEvents[name].label
      ytics.push "\"" + label + " (" + percentages[name] + "%)\" " + index
    ytics.push "\"code kind color coding\" " + kY1Offset
    ytics.push "\"code kind in execution\" " + (kY1Offset - 1)
    ytics.push "\"top " + kStackFrames + " js stack frames\"" + " " + (kY1Offset - 2)
    ytics.push "\"pause times\" 0"
    ytics.push "\"max deopt size: " + (max_deopt_size / 1024).toFixed(1) + " kB\" " + kDeoptRow
    output "set ytics out nomirror (" + ytics.join(", ") + ")"
    
    # Plot timeline.
    for name of TimerEvents
      event = TimerEvents[name]
      ranges = MergeRanges(event.ranges)
      i = 0

      while i < ranges.length
        DrawBar event.index, event.color, ranges[i].start, ranges[i].end, kTimerEventWidth
        i++
    
    # Plot code kind gathered from ticks.
    for name of CodeKinds
      code_kind = CodeKinds[name]
      offset = kY1Offset - 1
      
      # Top most frame.
      row = MergeRanges(TicksToRanges(code_kind.in_execution))
      j = 0

      while j < row.length
        DrawBar offset, code_kind.color, row[j].start, row[j].end, kExecutionFrameWidth
        j++
      offset = offset - 2 * kExecutionFrameWidth - kGapWidth
      
      # Javascript frames.
      i = 0

      while i < kStackFrames
        offset = offset - 2 * kStackFrameWidth - kGapWidth
        row = MergeRanges(TicksToRanges(code_kind.stack_frames[i]))
        j = 0

        while j < row.length
          DrawBar offset, code_kind.color, row[j].start, row[j].end, kStackFrameWidth
          j++
        i++
    
    # Add labels as legend for code kind colors.
    padding = kCodeKindLabelPadding * (range_end - range_start) / kResX
    label_x = range_start
    label_y = kY1Offset
    for name of CodeKinds
      label_x += padding
      output "set label \"" + name + "\" at " + label_x + "," + label_y + " textcolor rgb \"" + CodeKinds[name].color + "\"" + " font \"Helvetica,9'\""
      obj_index++
    if execution_pauses.length is 0
      
      # Force plot and return without plotting execution pause impulses.
      output "plot 1/0"
      return
    
    # Label the longest pauses.
    execution_pauses = RestrictRangesTo(execution_pauses, range_start, range_end)
    execution_pauses.sort (a, b) ->
      b.duration() - a.duration()

    max_pause_time = (if execution_pauses.length > 0 then execution_pauses[0].duration() else 0)
    padding = kPauseLabelPadding * (range_end - range_start) / kResX
    y_scale = kY1Offset / max_pause_time / 2
    i = 0

    while i < execution_pauses.length and i < kNumPauseLabels
      pause = execution_pauses[i]
      label_content = (pause.duration() | 0) + " ms"
      label_x = pause.end + padding
      label_y = Math.max(1, (pause.duration() * y_scale))
      output "set label \"" + label_content + "\" at " + label_x + "," + label_y + " font \"Helvetica,7'\""
      obj_index++
      i++
    
    # Scale second Y-axis appropriately.
    y2range = max_pause_time * num_timer_event / kY1Offset * 2
    output "set y2range [0:" + y2range + "]"
    
    # Plot graph with impulses as data set.
    output "plot '-' using 1:2 axes x1y2 with impulses ls 1"
    i = 0

    while i < execution_pauses.length
      pause = execution_pauses[i]
      output pause.end + " " + pause.duration()
      obj_index++
      i++
    output "e"
    obj_index

  return
Array::top = ->
  return `undefined`  if @length is 0
  this[@length - 1]
