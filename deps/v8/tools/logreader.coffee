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

###*
@fileoverview Log Reader is used to process log file produced by V8.
###

###*
Base class for processing log files.

@param {Array.<Object>} dispatchTable A table used for parsing and processing
log records.
@constructor
###
LogReader = (dispatchTable) ->
  
  ###*
  @type {Array.<Object>}
  ###
  @dispatchTable_ = dispatchTable
  
  ###*
  Current line.
  @type {number}
  ###
  @lineNum_ = 0
  
  ###*
  CSV lines parser.
  @type {CsvParser}
  ###
  @csvParser_ = new CsvParser()
  return

###*
Used for printing error messages.

@param {string} str Error message.
###
LogReader::printError = (str) ->


# Do nothing.

###*
Processes a portion of V8 profiler event log.

@param {string} chunk A portion of log.
###
LogReader::processLogChunk = (chunk) ->
  @processLog_ chunk.split("\n")
  return


###*
Processes a line of V8 profiler event log.

@param {string} line A line of log.
###
LogReader::processLogLine = (line) ->
  @processLog_ [line]
  return


###*
Processes stack record.

@param {number} pc Program counter.
@param {number} func JS Function.
@param {Array.<string>} stack String representation of a stack.
@return {Array.<number>} Processed stack.
###
LogReader::processStack = (pc, func, stack) ->
  fullStack = (if func then [
    pc
    func
  ] else [pc])
  prevFrame = pc
  i = 0
  n = stack.length

  while i < n
    frame = stack[i]
    firstChar = frame.charAt(0)
    if firstChar is "+" or firstChar is "-"
      
      # An offset from the previous frame.
      prevFrame += parseInt(frame, 16)
      fullStack.push prevFrame
    
    # Filter out possible 'overflow' string.
    else unless firstChar is "o"
      fullStack.push parseInt(frame, 16)
    else
      print "dropping: " + frame
    ++i
  fullStack


###*
Returns whether a particular dispatch must be skipped.

@param {!Object} dispatch Dispatch record.
@return {boolean} True if dispatch must be skipped.
###
LogReader::skipDispatch = (dispatch) ->
  false


###*
Does a dispatch of a log record.

@param {Array.<string>} fields Log record.
@private
###
LogReader::dispatchLogRow_ = (fields) ->
  
  # Obtain the dispatch.
  command = fields[0]
  return  unless command of @dispatchTable_
  dispatch = @dispatchTable_[command]
  return  if dispatch is null or @skipDispatch(dispatch)
  
  # Parse fields.
  parsedFields = []
  i = 0

  while i < dispatch.parsers.length
    parser = dispatch.parsers[i]
    if parser is null
      parsedFields.push fields[1 + i]
    else if typeof parser is "function"
      parsedFields.push parser(fields[1 + i])
    else
      
      # var-args
      parsedFields.push fields.slice(1 + i)
      break
    ++i
  
  # Run the processor.
  dispatch.processor.apply this, parsedFields
  return


###*
Processes log lines.

@param {Array.<string>} lines Log lines.
@private
###
LogReader::processLog_ = (lines) ->
  i = 0
  n = lines.length

  while i < n
    line = lines[i]
    continue  unless line
    try
      fields = @csvParser_.parseLine(line)
      @dispatchLogRow_ fields
    catch e
      @printError "line " + (@lineNum_ + 1) + ": " + (e.message or e)
    ++i
    ++@lineNum_
  return
