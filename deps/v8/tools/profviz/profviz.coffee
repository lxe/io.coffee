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
plotWorker = ->
  initialize = ->
    ui.freeze()
    worker = new Worker("worker.js")
    running = false
    worker.postMessage
      call: "load scripts"
      args: worker_scripts

    worker.addEventListener "message", (event) ->
      call = delegateList[event.data["call"]]
      call event.data["args"]
      return

    return
  scriptLoaded = ->
    ui.thaw()
    return
  worker = null
  
  # Public methods.
  @run = (filename, resx, resy, distortion, range_start, range_end) ->
    args =
      file: filename
      resx: resx
      resy: resy
      distortion: distortion
      range_start: range_start
      range_end: range_end

    worker.postMessage
      call: "run"
      args: args

    return

  @reset = ->
    worker.terminate()  if worker
    initialize()
    return

  delegateList =
    log: log
    error: logError
    displayplot: displayplot
    displayprof: displayprof
    range: setRange
    script: scriptLoaded
    reset: @reset

  return
UIWrapper = ->
  input_elements = [
    "range_start"
    "range_end"
    "distortion"
    "start"
    "file"
  ]
  other_elements = [
    "log"
    "plot"
    "prof"
    "instructions"
    "credits"
    "toggledisplay"
  ]
  for i of input_elements
    id = input_elements[i]
    this[id] = document.getElementById(id)
  for i of other_elements
    id = other_elements[i]
    this[id] = document.getElementById(id)
  @freeze = ->
    @plot.style.webkitFilter = "grayscale(1)"
    @prof.style.color = "#bbb"
    for i of input_elements
      this[input_elements[i]].disabled = true
    return

  @thaw = ->
    @plot.style.webkitFilter = ""
    @prof.style.color = "#000"
    for i of input_elements
      this[input_elements[i]].disabled = false
    return

  @reset = ->
    @thaw()
    @log.value = ""
    @range_start.value = "automatic"
    @range_end.value = "automatic"
    @toggle "plot"
    @plot.src = ""
    @prof.value = ""
    return

  @toggle = (mode) ->
    @toggledisplay.next_mode = mode  if mode
    if @toggledisplay.next_mode is "plot"
      @toggledisplay.next_mode = "prof"
      @plot.style.display = "block"
      @prof.style.display = "none"
      @toggledisplay.innerHTML = "Show profile"
    else
      @toggledisplay.next_mode = "plot"
      @plot.style.display = "none"
      @prof.style.display = "block"
      @toggledisplay.innerHTML = "Show plot"
    return

  @info = (field) ->
    down_arrow = "▼"
    right_arrow = "▶"
    field = null  if field and this[field].style.display isnt "none" # Toggle.
    @credits.style.display = "none"
    @instructions.style.display = "none"
    return  unless field
    this[field].style.display = "block"
    return

  return
log = (text) ->
  ui.log.value += text
  ui.log.scrollTop = ui.log.scrollHeight
  return
logError = (text) ->
  ui.log.value += "\n"  if ui.log.value.length > 0 and ui.log.value[ui.log.value.length - 1] isnt "\n"
  ui.log.value += "ERROR: " + text + "\n"
  ui.log.scrollTop = ui.log.scrollHeight
  error_logged = true
  return
displayplot = (args) ->
  if error_logged
    log "Plot failed.\n\n"
  else
    log "Displaying plot. Total time: " + (Date.now() - timer) / 1000 + "ms.\n\n"
    blob = new Blob([new Uint8Array(args.contents).buffer],
      type: "image/svg+xml"
    )
    window.URL = window.URL or window.webkitURL
    ui.plot.src = window.URL.createObjectURL(blob)
  ui.thaw()
  ui.toggle "plot"
  return
displayprof = (args) ->
  return  if error_logged
  ui.prof.value = args
  @prof.style.color = ""
  ui.toggle "prof"
  return
start = (event) ->
  error_logged = false
  ui.freeze()
  try
    file = getSelectedFile()
    distortion = getDistortion()
    range = getRange()
  catch e
    logError e.message
    display()
    return
  timer = Date.now()
  worker.run file, kResX, kResY, distortion, range[0], range[1]
  return
getSelectedFile = ->
  file = ui.file.files[0]
  throw Error("No valid file selected.")  unless file
  file
getDistortion = ->
  input_distortion = parseInt(ui.distortion.value, 10)
  input_distortion = ui.distortion.value = 4500  if isNaN(input_distortion)
  input_distortion / 1000000
getRange = ->
  input_start = parseInt(ui.range_start.value, 10)
  input_start = `undefined`  if isNaN(input_start)
  input_end = parseInt(ui.range_end.value, 10)
  input_end = `undefined`  if isNaN(input_end)
  [
    input_start
    input_end
  ]
setRange = (args) ->
  ui.range_start.value = args.start.toFixed(1)
  ui.range_end.value = args.end.toFixed(1)
  return
onload = ->
  kResX = 1200
  kResY = 600
  error_logged = false
  ui = new UIWrapper()
  ui.reset()
  ui.info null
  worker = new plotWorker()
  worker.reset()
  return
worker_scripts = [
  "../csvparser.js"
  "../splaytree.js"
  "../codemap.js"
  "../consarray.js"
  "../profile.js"
  "../profile_view.js"
  "../logreader.js"
  "../tickprocessor.js"
  "composer.js"
  "gnuplot-4.6.3-emscripten.js"
]
kResX = undefined
kResY = undefined
error_logged = undefined
ui = undefined
worker = undefined
timer = undefined
