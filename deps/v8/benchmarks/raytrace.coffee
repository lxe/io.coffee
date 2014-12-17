# The ray tracer code in this file is written by Adam Burmister. It
# is available in its original form from:
#
#   http://labs.flog.nz.co/raytracer/
#
# It has been modified slightly by Google to work as a standalone
# benchmark, but the all the computational code remains
# untouched. This file also contains a copy of parts of the Prototype
# JavaScript framework which is used by the ray tracer.

# Variable used to hold a number that can be used to verify that
# the scene was ray traced correctly.

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

# The following is a copy of parts of the Prototype JavaScript library:

# Prototype JavaScript framework, version 1.5.0
# (c) 2005-2007 Sam Stephenson
#
# Prototype is freely distributable under the terms of an MIT-style license.
# For details, see the Prototype web site: http://prototype.conio.net/

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

# The rest of this file is the actual ray tracer written by Adam
# Burmister. It's a concatenation of the following files:
#
#   flog/color.js
#   flog/light.js
#   flog/vector.js
#   flog/ray.js
#   flog/scene.js
#   flog/material/basematerial.js
#   flog/material/solid.js
#   flog/material/chessboard.js
#   flog/shape/baseshape.js
#   flog/shape/sphere.js
#   flog/shape/plane.js
#   flog/intersectioninfo.js
#   flog/camera.js
#   flog/background.js
#   flog/engine.js

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 
# [0...infinity] 0 = matt
# 0=opaque
# [0...infinity] 0 = no reflection

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 
# intersection!

# Fake a Flog.* namespace 
# no intersection

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 

# Fake a Flog.* namespace 
# 2d context we can render to 

# TODO: dynamically include other scripts 

# print(x * pxW, y * pxH, pxW, pxH);

# Get canvas 

# Calc ambient

# Calc diffuse lighting

# The greater the depth the more accurate the colours, but
# this is exponentially (!) expensive

# calculate reflection ray

# Refraction
# TODO 

# Render shadows and highlights 
#&& shadowInfo.shape.type != 'PLANE'

# Phong specular highlights
renderScene = ->
  scene = new Flog.RayTracer.Scene()
  scene.camera = new Flog.RayTracer.Camera(new Flog.RayTracer.Vector(0, 0, -15), new Flog.RayTracer.Vector(-0.2, 0, 5), new Flog.RayTracer.Vector(0, 1, 0))
  scene.background = new Flog.RayTracer.Background(new Flog.RayTracer.Color(0.5, 0.5, 0.5), 0.4)
  sphere = new Flog.RayTracer.Shape.Sphere(new Flog.RayTracer.Vector(-1.5, 1.5, 2), 1.5, new Flog.RayTracer.Material.Solid(new Flog.RayTracer.Color(0, 0.5, 0.5), 0.3, 0.0, 0.0, 2.0))
  sphere1 = new Flog.RayTracer.Shape.Sphere(new Flog.RayTracer.Vector(1, 0.25, 1), 0.5, new Flog.RayTracer.Material.Solid(new Flog.RayTracer.Color(0.9, 0.9, 0.9), 0.1, 0.0, 0.0, 1.5))
  plane = new Flog.RayTracer.Shape.Plane(new Flog.RayTracer.Vector(0.1, 0.9, -0.5).normalize(), 1.2, new Flog.RayTracer.Material.Chessboard(new Flog.RayTracer.Color(1, 1, 1), new Flog.RayTracer.Color(0, 0, 0), 0.2, 0.0, 1.0, 0.7))
  scene.shapes.push plane
  scene.shapes.push sphere
  scene.shapes.push sphere1
  light = new Flog.RayTracer.Light(new Flog.RayTracer.Vector(5, 10, -1), new Flog.RayTracer.Color(0.8, 0.8, 0.8))
  light1 = new Flog.RayTracer.Light(new Flog.RayTracer.Vector(-3, 5, -15), new Flog.RayTracer.Color(0.8, 0.8, 0.8), 100)
  scene.lights.push light
  scene.lights.push light1
  imageWidth = 100 # $F('imageWidth');
  imageHeight = 100 # $F('imageHeight');
  pixelSize = "5,5".split(",") #  $F('pixelSize').split(',');
  renderDiffuse = true # $F('renderDiffuse');
  renderShadows = true # $F('renderShadows');
  renderHighlights = true # $F('renderHighlights');
  renderReflections = true # $F('renderReflections');
  rayDepth = 2 #$F('rayDepth');
  raytracer = new Flog.RayTracer.Engine(
    canvasWidth: imageWidth
    canvasHeight: imageHeight
    pixelWidth: pixelSize[0]
    pixelHeight: pixelSize[1]
    renderDiffuse: renderDiffuse
    renderHighlights: renderHighlights
    renderShadows: renderShadows
    renderReflections: renderReflections
    rayDepth: rayDepth
  )
  raytracer.renderScene scene, null, 0
  return
RayTrace = new BenchmarkSuite("RayTrace", 739989, [new Benchmark("RayTrace", renderScene)])
checkNumber = undefined
Class = create: ->
  ->
    @initialize.apply this, arguments
    return

Object.extend = (destination, source) ->
  for property of source
    destination[property] = source[property]
  destination

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Color = Class.create()
Flog.RayTracer.Color:: =
  red: 0.0
  green: 0.0
  blue: 0.0
  initialize: (r, g, b) ->
    r = 0.0  unless r
    g = 0.0  unless g
    b = 0.0  unless b
    @red = r
    @green = g
    @blue = b
    return

  add: (c1, c2) ->
    result = new Flog.RayTracer.Color(0, 0, 0)
    result.red = c1.red + c2.red
    result.green = c1.green + c2.green
    result.blue = c1.blue + c2.blue
    result

  addScalar: (c1, s) ->
    result = new Flog.RayTracer.Color(0, 0, 0)
    result.red = c1.red + s
    result.green = c1.green + s
    result.blue = c1.blue + s
    result.limit()
    result

  subtract: (c1, c2) ->
    result = new Flog.RayTracer.Color(0, 0, 0)
    result.red = c1.red - c2.red
    result.green = c1.green - c2.green
    result.blue = c1.blue - c2.blue
    result

  multiply: (c1, c2) ->
    result = new Flog.RayTracer.Color(0, 0, 0)
    result.red = c1.red * c2.red
    result.green = c1.green * c2.green
    result.blue = c1.blue * c2.blue
    result

  multiplyScalar: (c1, f) ->
    result = new Flog.RayTracer.Color(0, 0, 0)
    result.red = c1.red * f
    result.green = c1.green * f
    result.blue = c1.blue * f
    result

  divideFactor: (c1, f) ->
    result = new Flog.RayTracer.Color(0, 0, 0)
    result.red = c1.red / f
    result.green = c1.green / f
    result.blue = c1.blue / f
    result

  limit: ->
    @red = (if (@red > 0.0) then ((if (@red > 1.0) then 1.0 else @red)) else 0.0)
    @green = (if (@green > 0.0) then ((if (@green > 1.0) then 1.0 else @green)) else 0.0)
    @blue = (if (@blue > 0.0) then ((if (@blue > 1.0) then 1.0 else @blue)) else 0.0)
    return

  distance: (color) ->
    d = Math.abs(@red - color.red) + Math.abs(@green - color.green) + Math.abs(@blue - color.blue)
    d

  blend: (c1, c2, w) ->
    result = new Flog.RayTracer.Color(0, 0, 0)
    result = Flog.RayTracer.Color::add(Flog.RayTracer.Color::multiplyScalar(c1, 1 - w), Flog.RayTracer.Color::multiplyScalar(c2, w))
    result

  brightness: ->
    r = Math.floor(@red * 255)
    g = Math.floor(@green * 255)
    b = Math.floor(@blue * 255)
    (r * 77 + g * 150 + b * 29) >> 8

  toString: ->
    r = Math.floor(@red * 255)
    g = Math.floor(@green * 255)
    b = Math.floor(@blue * 255)
    "rgb(" + r + "," + g + "," + b + ")"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Light = Class.create()
Flog.RayTracer.Light:: =
  position: null
  color: null
  intensity: 10.0
  initialize: (pos, color, intensity) ->
    @position = pos
    @color = color
    @intensity = ((if intensity then intensity else 10.0))
    return

  toString: ->
    "Light [" + @position.x + "," + @position.y + "," + @position.z + "]"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Vector = Class.create()
Flog.RayTracer.Vector:: =
  x: 0.0
  y: 0.0
  z: 0.0
  initialize: (x, y, z) ->
    @x = ((if x then x else 0))
    @y = ((if y then y else 0))
    @z = ((if z then z else 0))
    return

  copy: (vector) ->
    @x = vector.x
    @y = vector.y
    @z = vector.z
    return

  normalize: ->
    m = @magnitude()
    new Flog.RayTracer.Vector(@x / m, @y / m, @z / m)

  magnitude: ->
    Math.sqrt (@x * @x) + (@y * @y) + (@z * @z)

  cross: (w) ->
    new Flog.RayTracer.Vector(-@z * w.y + @y * w.z, @z * w.x - @x * w.z, -@y * w.x + @x * w.y)

  dot: (w) ->
    @x * w.x + @y * w.y + @z * w.z

  add: (v, w) ->
    new Flog.RayTracer.Vector(w.x + v.x, w.y + v.y, w.z + v.z)

  subtract: (v, w) ->
    throw "Vectors must be defined [" + v + "," + w + "]"  if not w or not v
    new Flog.RayTracer.Vector(v.x - w.x, v.y - w.y, v.z - w.z)

  multiplyVector: (v, w) ->
    new Flog.RayTracer.Vector(v.x * w.x, v.y * w.y, v.z * w.z)

  multiplyScalar: (v, w) ->
    new Flog.RayTracer.Vector(v.x * w, v.y * w, v.z * w)

  toString: ->
    "Vector [" + @x + "," + @y + "," + @z + "]"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Ray = Class.create()
Flog.RayTracer.Ray:: =
  position: null
  direction: null
  initialize: (pos, dir) ->
    @position = pos
    @direction = dir
    return

  toString: ->
    "Ray [" + @position + "," + @direction + "]"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Scene = Class.create()
Flog.RayTracer.Scene:: =
  camera: null
  shapes: []
  lights: []
  background: null
  initialize: ->
    @camera = new Flog.RayTracer.Camera(new Flog.RayTracer.Vector(0, 0, -5), new Flog.RayTracer.Vector(0, 0, 1), new Flog.RayTracer.Vector(0, 1, 0))
    @shapes = new Array()
    @lights = new Array()
    @background = new Flog.RayTracer.Background(new Flog.RayTracer.Color(0, 0, 0.5), 0.2)
    return

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Material = {}  if typeof (Flog.RayTracer.Material) is "undefined"
Flog.RayTracer.Material.BaseMaterial = Class.create()
Flog.RayTracer.Material.BaseMaterial:: =
  gloss: 2.0
  transparency: 0.0
  reflection: 0.0
  refraction: 0.50
  hasTexture: false
  initialize: ->

  getColor: (u, v) ->

  wrapUp: (t) ->
    t = t % 2.0
    t += 2.0  if t < -1
    t -= 2.0  if t >= 1
    t

  toString: ->
    "Material [gloss=" + @gloss + ", transparency=" + @transparency + ", hasTexture=" + @hasTexture + "]"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Material.Solid = Class.create()
Flog.RayTracer.Material.Solid:: = Object.extend(new Flog.RayTracer.Material.BaseMaterial(),
  initialize: (color, reflection, refraction, transparency, gloss) ->
    @color = color
    @reflection = reflection
    @transparency = transparency
    @gloss = gloss
    @hasTexture = false
    return

  getColor: (u, v) ->
    @color

  toString: ->
    "SolidMaterial [gloss=" + @gloss + ", transparency=" + @transparency + ", hasTexture=" + @hasTexture + "]"
)
Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Material.Chessboard = Class.create()
Flog.RayTracer.Material.Chessboard:: = Object.extend(new Flog.RayTracer.Material.BaseMaterial(),
  colorEven: null
  colorOdd: null
  density: 0.5
  initialize: (colorEven, colorOdd, reflection, transparency, gloss, density) ->
    @colorEven = colorEven
    @colorOdd = colorOdd
    @reflection = reflection
    @transparency = transparency
    @gloss = gloss
    @density = density
    @hasTexture = true
    return

  getColor: (u, v) ->
    t = @wrapUp(u * @density) * @wrapUp(v * @density)
    if t < 0.0
      @colorEven
    else
      @colorOdd

  toString: ->
    "ChessMaterial [gloss=" + @gloss + ", transparency=" + @transparency + ", hasTexture=" + @hasTexture + "]"
)
Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Shape = {}  if typeof (Flog.RayTracer.Shape) is "undefined"
Flog.RayTracer.Shape.Sphere = Class.create()
Flog.RayTracer.Shape.Sphere:: =
  initialize: (pos, radius, material) ->
    @radius = radius
    @position = pos
    @material = material
    return

  intersect: (ray) ->
    info = new Flog.RayTracer.IntersectionInfo()
    info.shape = this
    dst = Flog.RayTracer.Vector::subtract(ray.position, @position)
    B = dst.dot(ray.direction)
    C = dst.dot(dst) - (@radius * @radius)
    D = (B * B) - C
    if D > 0
      info.isHit = true
      info.distance = (-B) - Math.sqrt(D)
      info.position = Flog.RayTracer.Vector::add(ray.position, Flog.RayTracer.Vector::multiplyScalar(ray.direction, info.distance))
      info.normal = Flog.RayTracer.Vector::subtract(info.position, @position).normalize()
      info.color = @material.getColor(0, 0)
    else
      info.isHit = false
    info

  toString: ->
    "Sphere [position=" + @position + ", radius=" + @radius + "]"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Shape = {}  if typeof (Flog.RayTracer.Shape) is "undefined"
Flog.RayTracer.Shape.Plane = Class.create()
Flog.RayTracer.Shape.Plane:: =
  d: 0.0
  initialize: (pos, d, material) ->
    @position = pos
    @d = d
    @material = material
    return

  intersect: (ray) ->
    info = new Flog.RayTracer.IntersectionInfo()
    Vd = @position.dot(ray.direction)
    return info  if Vd is 0
    t = -(@position.dot(ray.position) + @d) / Vd
    return info  if t <= 0
    info.shape = this
    info.isHit = true
    info.position = Flog.RayTracer.Vector::add(ray.position, Flog.RayTracer.Vector::multiplyScalar(ray.direction, t))
    info.normal = @position
    info.distance = t
    if @material.hasTexture
      vU = new Flog.RayTracer.Vector(@position.y, @position.z, -@position.x)
      vV = vU.cross(@position)
      u = info.position.dot(vU)
      v = info.position.dot(vV)
      info.color = @material.getColor(u, v)
    else
      info.color = @material.getColor(0, 0)
    info

  toString: ->
    "Plane [" + @position + ", d=" + @d + "]"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.IntersectionInfo = Class.create()
Flog.RayTracer.IntersectionInfo:: =
  isHit: false
  hitCount: 0
  shape: null
  position: null
  normal: null
  color: null
  distance: null
  initialize: ->
    @color = new Flog.RayTracer.Color(0, 0, 0)
    return

  toString: ->
    "Intersection [" + @position + "]"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Camera = Class.create()
Flog.RayTracer.Camera:: =
  position: null
  lookAt: null
  equator: null
  up: null
  screen: null
  initialize: (pos, lookAt, up) ->
    @position = pos
    @lookAt = lookAt
    @up = up
    @equator = lookAt.normalize().cross(@up)
    @screen = Flog.RayTracer.Vector::add(@position, @lookAt)
    return

  getRay: (vx, vy) ->
    pos = Flog.RayTracer.Vector::subtract(@screen, Flog.RayTracer.Vector::subtract(Flog.RayTracer.Vector::multiplyScalar(@equator, vx), Flog.RayTracer.Vector::multiplyScalar(@up, vy)))
    pos.y = pos.y * -1
    dir = Flog.RayTracer.Vector::subtract(pos, @position)
    ray = new Flog.RayTracer.Ray(pos, dir.normalize())
    ray

  toString: ->
    "Ray []"

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Background = Class.create()
Flog.RayTracer.Background:: =
  color: null
  ambience: 0.0
  initialize: (color, ambience) ->
    @color = color
    @ambience = ambience
    return

Flog = {}  if typeof (Flog) is "undefined"
Flog.RayTracer = {}  if typeof (Flog.RayTracer) is "undefined"
Flog.RayTracer.Engine = Class.create()
Flog.RayTracer.Engine:: =
  canvas: null
  initialize: (options) ->
    @options = Object.extend(
      canvasHeight: 100
      canvasWidth: 100
      pixelWidth: 2
      pixelHeight: 2
      renderDiffuse: false
      renderShadows: false
      renderHighlights: false
      renderReflections: false
      rayDepth: 2
    , options or {})
    @options.canvasHeight /= @options.pixelHeight
    @options.canvasWidth /= @options.pixelWidth
    return

  setPixel: (x, y, color) ->
    pxW = undefined
    pxH = undefined
    pxW = @options.pixelWidth
    pxH = @options.pixelHeight
    if @canvas
      @canvas.fillStyle = color.toString()
      @canvas.fillRect x * pxW, y * pxH, pxW, pxH
    else
      checkNumber += color.brightness()  if x is y
    return

  renderScene: (scene, canvas) ->
    checkNumber = 0
    if canvas
      @canvas = canvas.getContext("2d")
    else
      @canvas = null
    canvasHeight = @options.canvasHeight
    canvasWidth = @options.canvasWidth
    y = 0

    while y < canvasHeight
      x = 0

      while x < canvasWidth
        yp = y * 1.0 / canvasHeight * 2 - 1
        xp = x * 1.0 / canvasWidth * 2 - 1
        ray = scene.camera.getRay(xp, yp)
        color = @getPixelColor(ray, scene)
        @setPixel x, y, color
        x++
      y++
    throw new Error("Scene rendered incorrectly")  if checkNumber isnt 2321
    return

  getPixelColor: (ray, scene) ->
    info = @testIntersection(ray, scene, null)
    if info.isHit
      color = @rayTrace(info, ray, scene, 0)
      return color
    scene.background.color

  testIntersection: (ray, scene, exclude) ->
    hits = 0
    best = new Flog.RayTracer.IntersectionInfo()
    best.distance = 2000
    i = 0

    while i < scene.shapes.length
      shape = scene.shapes[i]
      unless shape is exclude
        info = shape.intersect(ray)
        if info.isHit and info.distance >= 0 and info.distance < best.distance
          best = info
          hits++
      i++
    best.hitCount = hits
    best

  getReflectionRay: (P, N, V) ->
    c1 = -N.dot(V)
    R1 = Flog.RayTracer.Vector::add(Flog.RayTracer.Vector::multiplyScalar(N, 2 * c1), V)
    new Flog.RayTracer.Ray(P, R1)

  rayTrace: (info, ray, scene, depth) ->
    color = Flog.RayTracer.Color::multiplyScalar(info.color, scene.background.ambience)
    oldColor = color
    shininess = Math.pow(10, info.shape.material.gloss + 1)
    i = 0

    while i < scene.lights.length
      light = scene.lights[i]
      v = Flog.RayTracer.Vector::subtract(light.position, info.position).normalize()
      if @options.renderDiffuse
        L = v.dot(info.normal)
        color = Flog.RayTracer.Color::add(color, Flog.RayTracer.Color::multiply(info.color, Flog.RayTracer.Color::multiplyScalar(light.color, L)))  if L > 0.0
      if depth <= @options.rayDepth
        if @options.renderReflections and info.shape.material.reflection > 0
          reflectionRay = @getReflectionRay(info.position, info.normal, ray.direction)
          refl = @testIntersection(reflectionRay, scene, info.shape)
          if refl.isHit and refl.distance > 0
            refl.color = @rayTrace(refl, reflectionRay, scene, depth + 1)
          else
            refl.color = scene.background.color
          color = Flog.RayTracer.Color::blend(color, refl.color, info.shape.material.reflection)
      shadowInfo = new Flog.RayTracer.IntersectionInfo()
      if @options.renderShadows
        shadowRay = new Flog.RayTracer.Ray(info.position, v)
        shadowInfo = @testIntersection(shadowRay, scene, info.shape)
        if shadowInfo.isHit and shadowInfo.shape isnt info.shape
          vA = Flog.RayTracer.Color::multiplyScalar(color, 0.5)
          dB = (0.5 * Math.pow(shadowInfo.shape.material.transparency, 0.5))
          color = Flog.RayTracer.Color::addScalar(vA, dB)
      if @options.renderHighlights and not shadowInfo.isHit and info.shape.material.gloss > 0
        Lv = Flog.RayTracer.Vector::subtract(info.shape.position, light.position).normalize()
        E = Flog.RayTracer.Vector::subtract(scene.camera.position, info.shape.position).normalize()
        H = Flog.RayTracer.Vector::subtract(E, Lv).normalize()
        glossWeight = Math.pow(Math.max(info.normal.dot(H), 0), shininess)
        color = Flog.RayTracer.Color::add(Flog.RayTracer.Color::multiplyScalar(light.color, glossWeight), color)
      i++
    color.limit()
    color
