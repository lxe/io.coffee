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
This function provides requestAnimationFrame in a cross browser way.
http://paulirish.com/2011/requestanimationframe-for-smart-animating/
###
Point = (x, y, z, payload) ->
  @x = x
  @y = y
  @z = z
  @next = null
  @prev = null
  @payload = payload
  @lifeForce = kInitialLifeForce
  return
PointsList = ->
  @head = null
  @count = 0
  return
GeneratePayloadTree = (depth, tag) ->
  if depth is 0
    array: [
      0
      1
      2
      3
      4
      5
      6
      7
      8
      9
    ]
    string: "String for key " + tag + " in leaf node"
  else
    left: GeneratePayloadTree(depth - 1, tag)
    right: GeneratePayloadTree(depth - 1, tag)

# To make the benchmark results predictable, we replace Math.random
# with a 100% deterministic alternative.

# Robert Jenkins' 32 bit integer hash function.
GenerateKey = ->
  
  # The benchmark framework guarantees that Math.random is
  # deterministic; see base.js.
  Math.random()
CreateNewPoint = ->
  
  # Insert new node with a unique key.
  key = undefined
  loop
    key = GenerateKey()
    break unless splayTree.find(key)?
  point = new Point(Math.random() * 40 - 20, Math.random() * 40 - 20, Math.random() * 40 - 20, GeneratePayloadTree(5, "" + key))
  livePoints.add point
  splayTree.insert key, point
  key
ModifyPointsSet = ->
  if livePoints.count < kNPoints
    i = 0

    while i < kNModifications
      CreateNewPoint()
      i++
  else if kNModifications is 20
    kNModifications = 80
    kDecay = 30
  i = 0

  while i < kNModifications
    key = CreateNewPoint()
    greatest = splayTree.findGreatestLessThan(key)
    unless greatest?
      point = splayTree.remove(key).value
    else
      point = splayTree.remove(greatest.key).value
    livePoints.remove point
    point.payload = null
    dyingPoints.add point
    i++
  return
PausePlot = (width, height, size, scale) ->
  canvas = document.createElement("canvas")
  canvas.width = @width = width
  canvas.height = @height = height
  document.body.appendChild canvas
  @ctx = canvas.getContext("2d")
  if typeof scale isnt "number"
    @autoScale = true
    @maxPause = 0
  else
    @autoScale = false
    @maxPause = scale
  @size = size
  
  # Initialize cyclic buffer for pauses.
  @pauses = new Array(@size)
  @start = @size
  @idx = 0
  return
Scene = (width, height) ->
  canvas = document.createElement("canvas")
  canvas.width = width
  canvas.height = height
  document.body.appendChild canvas
  @ctx = canvas.getContext("2d")
  @width = canvas.width
  @height = canvas.height
  
  # Projection configuration.
  @x0 = canvas.width / 2
  @y0 = canvas.height / 2
  @z0 = 100
  @f = 1000 # Focal length.
  
  # Camera is rotating around y-axis.
  @angle = 0
  return

# Rotate the camera around y-axis.

# Perform perspective projection.

# Rotate the scene around y-axis.

# Decay the current point and remove it from the list
# if it's life-force ran out.
updateStats = (pause) ->
  numberOfFrames++
  sumOfSquaredPauses += (pause - 20) * (pause - 20)  if pause > 20
  pauseDistribution[Math.floor(pause / 10)] |= 0
  pauseDistribution[Math.floor(pause / 10)]++
  return
renderStats = ->
  msg = document.createElement("p")
  msg.innerHTML = "Score " + Math.round(numberOfFrames * 1000 / sumOfSquaredPauses)
  table = document.createElement("table")
  table.align = "center"
  i = 0

  while i < pauseDistribution.length
    if pauseDistribution[i] > 0
      row = document.createElement("tr")
      time = document.createElement("td")
      count = document.createElement("td")
      time.innerHTML = i * 10 + "-" + (i + 1) * 10 + "ms"
      count.innerHTML = " => " + pauseDistribution[i]
      row.appendChild time
      row.appendChild count
      table.appendChild row
    i++
  div.appendChild msg
  div.appendChild table
  return
render = ->
  if typeof renderingStartTime is "undefined"
    renderingStartTime = Date.now()
    benchmarkStartTime = renderingStartTime
  ModifyPointsSet()
  scene.draw()
  renderingEndTime = Date.now()
  pause = renderingEndTime - renderingStartTime
  pausePlot.addPause pause
  renderingStartTime = renderingEndTime
  pausePlot.draw()
  updateStats pause
  div.innerHTML = livePoints.count + "/" + dyingPoints.count + " " + pause + "(max = " + pausePlot.maxPause + ") ms " + numberOfFrames + " frames"
  if renderingEndTime < benchmarkStartTime + benchmarkTimeLimit
    
    # Schedule next frame.
    requestAnimationFrame render
  else
    renderStats()
  return
Form = ->
  create = (tag) ->
    document.createElement tag
  text = (value) ->
    document.createTextNode value
  col = (a) ->
    td = create("td")
    td.appendChild a
    td
  row = (a, b) ->
    tr = create("tr")
    tr.appendChild col(a)
    tr.appendChild col(b)
    tr
  @form = create("form")
  @form.setAttribute "action", "javascript:start()"
  table = create("table")
  table.setAttribute "style", "margin-left: auto; margin-right: auto;"
  @timelimit = create("input")
  @timelimit.setAttribute "value", "60"
  table.appendChild row(text("Time limit in seconds"), @timelimit)
  @autoscale = create("input")
  @autoscale.setAttribute "type", "checkbox"
  @autoscale.setAttribute "checked", "true"
  table.appendChild row(text("Autoscale pauses plot"), @autoscale)
  button = create("input")
  button.setAttribute "type", "submit"
  button.setAttribute "value", "Start"
  @form.appendChild table
  @form.appendChild button
  document.body.appendChild @form
  return
init = ->
  livePoints = new PointsList
  dyingPoints = new PointsList
  splayTree = new SplayTree()
  scene = new Scene(640, 480)
  div = document.createElement("div")
  document.body.appendChild div
  pausePlot = new PausePlot(480, (if autoScale then 240 else 500), 160, (if autoScale then undefined else 500))
  return
start = ->
  benchmarkTimeLimit = form.timelimit.value * 1000
  autoScale = form.autoscale.checked
  form.remove()
  init()
  render()
  return
unless window.requestAnimationFrame
  window.requestAnimationFrame = (->
    window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
      window.setTimeout callback, 1000 / 60
      return
  )()
kNPoints = 8000
kNModifications = 20
kNVisiblePoints = 200
kDecaySpeed = 20
kPointRadius = 4
kInitialLifeForce = 100
livePoints = undefined
dyingPoints = undefined
scene = undefined
renderingStartTime = undefined
scene = undefined
pausePlot = undefined
splayTree = undefined
numberOfFrames = 0
sumOfSquaredPauses = 0
benchmarkStartTime = undefined
benchmarkTimeLimit = undefined
autoScale = undefined
pauseDistribution = []
Point::color = ->
  "rgba(0, 0, 0, " + (@lifeForce / kInitialLifeForce) + ")"

Point::decay = ->
  @lifeForce -= kDecaySpeed
  @lifeForce <= 0

PointsList::add = (point) ->
  @head.prev = point  if @head isnt null
  point.next = @head
  @head = point
  @count++
  return

PointsList::remove = (point) ->
  point.next.prev = point.prev  if point.next isnt null
  if point.prev isnt null
    point.prev.next = point.next
  else
    @head = point.next
  @count--
  return

Math.random = (->
  seed = 49734321
  ->
    seed = ((seed + 0x7ed55d16) + (seed << 12)) & 0xffffffff
    seed = ((seed ^ 0xc761c23c) ^ (seed >>> 19)) & 0xffffffff
    seed = ((seed + 0x165667b1) + (seed << 5)) & 0xffffffff
    seed = ((seed + 0xd3a2646c) ^ (seed << 9)) & 0xffffffff
    seed = ((seed + 0xfd7046c5) + (seed << 3)) & 0xffffffff
    seed = ((seed ^ 0xb55a4f09) ^ (seed >>> 16)) & 0xffffffff
    (seed & 0xfffffff) / 0x10000000
)()
PausePlot::addPause = (p) ->
  @idx = 0  if @idx is @size
  @start++  if @idx is @start
  @start = 0  if @start is @size
  @pauses[@idx++] = p
  return

PausePlot::iteratePauses = (f) ->
  if @start < @idx
    i = @start

    while i < @idx
      f.call this, i - @start, @pauses[i]
      i++
  else
    i = @start

    while i < @size
      f.call this, i - @start, @pauses[i]
      i++
    offs = @size - @start
    i = 0

    while i < @idx
      f.call this, i + offs, @pauses[i]
      i++
  return

PausePlot::draw = ->
  first = null
  if @autoScale
    @iteratePauses (i, v) ->
      first = v  if first is null
      @maxPause = Math.max(v, @maxPause)
      return

  dx = @width / @size
  dy = @height / @maxPause
  @ctx.save()
  @ctx.clearRect 0, 0, @width, @height
  @ctx.beginPath()
  @ctx.moveTo 1, dy * @pauses[@start]
  p = first
  @iteratePauses (i, v) ->
    delta = v - p
    x = 1 + dx * i
    y = dy * v
    @ctx.lineTo x, y
    if delta > 2 * (p / 3)
      @ctx.font = "bold 12px sans-serif"
      @ctx.textBaseline = "bottom"
      @ctx.fillText v + "ms", x + 2, y
    p = v
    return

  @ctx.strokeStyle = "black"
  @ctx.stroke()
  @ctx.restore()
  return

Scene::drawPoint = (x, y, z, color) ->
  rx = x * Math.cos(@angle) - z * Math.sin(@angle)
  ry = y
  rz = x * Math.sin(@angle) + z * Math.cos(@angle)
  px = (@f * rx) / (rz - @z0) + @x0
  py = (@f * ry) / (rz - @z0) + @y0
  @ctx.save()
  @ctx.fillStyle = color
  @ctx.beginPath()
  @ctx.arc px, py, kPointRadius, 0, 2 * Math.PI, true
  @ctx.fill()
  @ctx.restore()
  return

Scene::drawDyingPoints = ->
  point_next = null
  point = dyingPoints.head

  while point isnt null
    scene.drawPoint point.x, point.y, point.z, point.color()
    point_next = point.next
    dyingPoints.remove point  if point.decay()
    point = point_next
  return

Scene::draw = ->
  @ctx.save()
  @ctx.clearRect 0, 0, @width, @height
  @drawDyingPoints()
  @ctx.restore()
  @angle += Math.PI / 90.0
  return

Form::remove = ->
  document.body.removeChild @form
  return

form = new Form()
