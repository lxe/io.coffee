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
log = (text) ->
  self.postMessage
    call: "log"
    args: text

  return
displayplot = (content) ->
  self.postMessage
    call: "displayplot"
    args: content

  return
displayprof = (content) ->
  self.postMessage
    call: "displayprof"
    args: content

  return
setRange = (start, end) ->
  self.postMessage
    call: "range"
    args:
      start: start
      end: end

  return
time = (name, fun) ->
  log name + "..."
  start = Date.now()
  fun()
  log " took " + (Date.now() - start) / 1000 + "s.\n"
  return
load_scripts = (scripts) ->
  time "Loading scripts", ->
    for i of scripts
      importScripts scripts[i]
    return

  self.postMessage call: "script"
  return
log_error = (text) ->
  self.postMessage
    call: "error"
    args: text

  self.postMessage call: "reset"
  return
run = (args) ->
  file = args["file"]
  resx = args["resx"]
  resy = args["resy"]
  distortion = args["distortion"]
  range_start_override = args["range_start"]
  range_end_override = args["range_end"]
  reader = new FileReaderSync()
  content_lines = undefined
  time "Reading log file (" + (file.size / 1024).toFixed(1) + " kB)", ->
    content = reader.readAsText(file)
    content_lines = content.split("\n")
    return

  time "Producing statistical profile", ->
    profile = ""
    print = (text) ->
      profile += text + "\n"
      return

    
    # Dummy entries provider, as we cannot call nm.
    entriesProvider = new UnixCppEntriesProvider("", "")
    targetRootFS = ""
    separateIc = false
    callGraphSize = 5
    ignoreUnknown = true
    stateFilter = null
    snapshotLogProcessor = null
    range = range_start_override + "," + range_end_override
    tickProcessor = new TickProcessor(entriesProvider, separateIc, callGraphSize, ignoreUnknown, stateFilter, snapshotLogProcessor, distortion, range)
    i = 0

    while i < content_lines.length
      tickProcessor.processLogLine content_lines[i]
      i++
    tickProcessor.printStatistics()
    displayprof profile
    return

  input_file_name = "input_temp"
  output_file_name = "output.svg"
  psc = new PlotScriptComposer(resx, resy, log_error)
  objects = 0
  time "Collecting events (" + content_lines.length + " entries)", ->
    line_cursor = 0
    input = ->
      content_lines[line_cursor++]

    psc.collectData input, distortion
    psc.findPlotRange range_start_override, range_end_override, setRange
    return

  time "Assembling plot script", ->
    plot_script = ""
    output = (text) ->
      plot_script += text + "\n"
      return

    output "set terminal svg size " + resx + "," + resy + " enhanced font \"Helvetica,10\""
    output "set output \"" + output_file_name + "\""
    objects = psc.assembleOutput(output)
    FS.deleteFile input_file_name  if FS.findObject(input_file_name)
    arrc = Module["intArrayFromString"](plot_script, true)
    FS.createDataFile "/", input_file_name, arrc
    return

  time "Running gnuplot (" + objects + " objects)", ->
    Module.run [input_file_name]
    return

  displayplot FS.findObject(output_file_name)
  return
delegateList =
  "load scripts": load_scripts
  run: run

self.addEventListener "message", ((event) ->
  call = delegateList[event.data["call"]]
  result = call(event.data["args"])
  return
), false
Module =
  noInitialRun: true
  print: (text) ->
    self.postMessage
      call: "error"
      args: text

    return

  printErr: (text) ->
    self.postMessage
      call: "error"
      args: text

    return
