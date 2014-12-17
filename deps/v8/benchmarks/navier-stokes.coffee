###*
Copyright 2012 the V8 project authors. All rights reserved.
Copyright 2009 Oliver Hunt <http://nerget.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
###
runNavierStokes = ->
  solver.update()
  return
setupNavierStokes = ->
  solver = new FluidField(null)
  solver.setResolution 128, 128
  solver.setIterations 20
  solver.setDisplayFunction ->

  solver.setUICallback prepareFrame
  solver.reset()
  return
tearDownNavierStokes = ->
  solver = null
  return
addPoints = (field) ->
  n = 64
  i = 1

  while i <= n
    field.setVelocity i, i, n, n
    field.setDensity i, i, 5
    field.setVelocity i, n - i, -n, -n
    field.setDensity i, n - i, 20
    field.setVelocity 128 - i, n + i, -n, -n
    field.setDensity 128 - i, n + i, 30
    i++
  return
prepareFrame = (field) ->
  if framesTillAddingPoints is 0
    addPoints field
    framesTillAddingPoints = framesBetweenAddingPoints
    framesBetweenAddingPoints++
  else
    framesTillAddingPoints--
  return

# Code from Oliver Hunt (http://nerget.com/fluidSim/pressure.js) starts here.
FluidField = (canvas) ->
  addFields = (x, s, dt) ->
    i = 0

    while i < size
      x[i] += dt * s[i]
      i++
    return
  set_bnd = (b, x) ->
    if b is 1
      i = 1

      while i <= width
        x[i] = x[i + rowSize]
        x[i + (height + 1) * rowSize] = x[i + height * rowSize]
        i++
      j = 1

      while i <= height
        x[j * rowSize] = -x[1 + j * rowSize]
        x[(width + 1) + j * rowSize] = -x[width + j * rowSize]
        i++
    else if b is 2
      i = 1

      while i <= width
        x[i] = -x[i + rowSize]
        x[i + (height + 1) * rowSize] = -x[i + height * rowSize]
        i++
      j = 1

      while j <= height
        x[j * rowSize] = x[1 + j * rowSize]
        x[(width + 1) + j * rowSize] = x[width + j * rowSize]
        j++
    else
      i = 1

      while i <= width
        x[i] = x[i + rowSize]
        x[i + (height + 1) * rowSize] = x[i + height * rowSize]
        i++
      j = 1

      while j <= height
        x[j * rowSize] = x[1 + j * rowSize]
        x[(width + 1) + j * rowSize] = x[width + j * rowSize]
        j++
    maxEdge = (height + 1) * rowSize
    x[0] = 0.5 * (x[1] + x[rowSize])
    x[maxEdge] = 0.5 * (x[1 + maxEdge] + x[height * rowSize])
    x[(width + 1)] = 0.5 * (x[width] + x[(width + 1) + rowSize])
    x[(width + 1) + maxEdge] = 0.5 * (x[width + maxEdge] + x[(width + 1) + height * rowSize])
    return
  lin_solve = (b, x, x0, a, c) ->
    if a is 0 and c is 1
      j = 1

      while j <= height
        currentRow = j * rowSize
        ++currentRow
        i = 0

        while i < width
          x[currentRow] = x0[currentRow]
          ++currentRow
          i++
        j++
      set_bnd b, x
    else
      invC = 1 / c
      k = 0

      while k < iterations
        j = 1

        while j <= height
          lastRow = (j - 1) * rowSize
          currentRow = j * rowSize
          nextRow = (j + 1) * rowSize
          lastX = x[currentRow]
          ++currentRow
          i = 1

          while i <= width
            lastX = x[currentRow] = (x0[currentRow] + a * (lastX + x[++currentRow] + x[++lastRow] + x[++nextRow])) * invC
            i++
          j++
        set_bnd b, x
        k++
    return
  diffuse = (b, x, x0, dt) ->
    a = 0
    lin_solve b, x, x0, a, 1 + 4 * a
    return
  lin_solve2 = (x, x0, y, y0, a, c) ->
    if a is 0 and c is 1
      j = 1

      while j <= height
        currentRow = j * rowSize
        ++currentRow
        i = 0

        while i < width
          x[currentRow] = x0[currentRow]
          y[currentRow] = y0[currentRow]
          ++currentRow
          i++
        j++
      set_bnd 1, x
      set_bnd 2, y
    else
      invC = 1 / c
      k = 0

      while k < iterations
        j = 1

        while j <= height
          lastRow = (j - 1) * rowSize
          currentRow = j * rowSize
          nextRow = (j + 1) * rowSize
          lastX = x[currentRow]
          lastY = y[currentRow]
          ++currentRow
          i = 1

          while i <= width
            lastX = x[currentRow] = (x0[currentRow] + a * (lastX + x[currentRow] + x[lastRow] + x[nextRow])) * invC
            lastY = y[currentRow] = (y0[currentRow] + a * (lastY + y[++currentRow] + y[++lastRow] + y[++nextRow])) * invC
            i++
          j++
        set_bnd 1, x
        set_bnd 2, y
        k++
    return
  diffuse2 = (x, x0, y, y0, dt) ->
    a = 0
    lin_solve2 x, x0, y, y0, a, 1 + 4 * a
    return
  advect = (b, d, d0, u, v, dt) ->
    Wdt0 = dt * width
    Hdt0 = dt * height
    Wp5 = width + 0.5
    Hp5 = height + 0.5
    j = 1

    while j <= height
      pos = j * rowSize
      i = 1

      while i <= width
        x = i - Wdt0 * u[++pos]
        y = j - Hdt0 * v[pos]
        if x < 0.5
          x = 0.5
        else x = Wp5  if x > Wp5
        i0 = x | 0
        i1 = i0 + 1
        if y < 0.5
          y = 0.5
        else y = Hp5  if y > Hp5
        j0 = y | 0
        j1 = j0 + 1
        s1 = x - i0
        s0 = 1 - s1
        t1 = y - j0
        t0 = 1 - t1
        row1 = j0 * rowSize
        row2 = j1 * rowSize
        d[pos] = s0 * (t0 * d0[i0 + row1] + t1 * d0[i0 + row2]) + s1 * (t0 * d0[i1 + row1] + t1 * d0[i1 + row2])
        i++
      j++
    set_bnd b, d
    return
  project = (u, v, p, div) ->
    h = -0.5 / Math.sqrt(width * height)
    j = 1

    while j <= height
      row = j * rowSize
      previousRow = (j - 1) * rowSize
      prevValue = row - 1
      currentRow = row
      nextValue = row + 1
      nextRow = (j + 1) * rowSize
      i = 1

      while i <= width
        div[++currentRow] = h * (u[++nextValue] - u[++prevValue] + v[++nextRow] - v[++previousRow])
        p[currentRow] = 0
        i++
      j++
    set_bnd 0, div
    set_bnd 0, p
    lin_solve 0, p, div, 1, 4
    wScale = 0.5 * width
    hScale = 0.5 * height
    j = 1

    while j <= height
      prevPos = j * rowSize - 1
      currentPos = j * rowSize
      nextPos = j * rowSize + 1
      prevRow = (j - 1) * rowSize
      currentRow = j * rowSize
      nextRow = (j + 1) * rowSize
      i = 1

      while i <= width
        u[++currentPos] -= wScale * (p[++nextPos] - p[++prevPos])
        v[currentPos] -= hScale * (p[++nextRow] - p[++prevRow])
        i++
      j++
    set_bnd 1, u
    set_bnd 2, v
    return
  dens_step = (x, x0, u, v, dt) ->
    addFields x, x0, dt
    diffuse 0, x0, x, dt
    advect 0, x, x0, u, v, dt
    return
  vel_step = (u, v, u0, v0, dt) ->
    addFields u, u0, dt
    addFields v, v0, dt
    temp = u0
    u0 = u
    u = temp
    temp = v0
    v0 = v
    v = temp
    diffuse2 u, u0, v, v0, dt
    project u, v, u0, v0
    temp = u0
    u0 = u
    u = temp
    temp = v0
    v0 = v
    v = temp
    advect 1, u, u0, u0, v0, dt
    advect 2, v, v0, u0, v0, dt
    project u, v, u0, v0
    return
  Field = (dens, u, v) ->
    
    # Just exposing the fields here rather than using accessors is a measurable win during display (maybe 5%)
    # but makes the code ugly.
    @setDensity = (x, y, d) ->
      dens[(x + 1) + (y + 1) * rowSize] = d
      return

    @getDensity = (x, y) ->
      dens[(x + 1) + (y + 1) * rowSize]

    @setVelocity = (x, y, xv, yv) ->
      u[(x + 1) + (y + 1) * rowSize] = xv
      v[(x + 1) + (y + 1) * rowSize] = yv
      return

    @getXVelocity = (x, y) ->
      u[(x + 1) + (y + 1) * rowSize]

    @getYVelocity = (x, y) ->
      v[(x + 1) + (y + 1) * rowSize]

    @width = ->
      width

    @height = ->
      height

    return
  queryUI = (d, u, v) ->
    i = 0

    while i < size
      u[i] = v[i] = d[i] = 0.0
      i++
    uiCallback new Field(d, u, v)
    return
  reset = ->
    rowSize = width + 2
    size = (width + 2) * (height + 2)
    dens = new Array(size)
    dens_prev = new Array(size)
    u = new Array(size)
    u_prev = new Array(size)
    v = new Array(size)
    v_prev = new Array(size)
    i = 0

    while i < size
      dens_prev[i] = u_prev[i] = v_prev[i] = dens[i] = u[i] = v[i] = 0
      i++
    return
  uiCallback = (d, u, v) ->

  @update = ->
    queryUI dens_prev, u_prev, v_prev
    vel_step u, v, u_prev, v_prev, dt
    dens_step dens, dens_prev, u, v, dt
    displayFunc new Field(dens, u, v)
    return

  @setDisplayFunction = (func) ->
    displayFunc = func
    return

  @iterations = ->
    iterations

  @setIterations = (iters) ->
    iterations = iters  if iters > 0 and iters <= 100
    return

  @setUICallback = (callback) ->
    uiCallback = callback
    return

  iterations = 10
  visc = 0.5
  dt = 0.1
  dens = undefined
  dens_prev = undefined
  u = undefined
  u_prev = undefined
  v = undefined
  v_prev = undefined
  width = undefined
  height = undefined
  rowSize = undefined
  size = undefined
  displayFunc = undefined
  @reset = reset
  @setResolution = (hRes, wRes) ->
    res = wRes * hRes
    if res > 0 and res < 1000000 and (wRes isnt width or hRes isnt height)
      width = wRes
      height = hRes
      reset()
      return true
    false

  @setResolution 64, 64
  return
NavierStokes = new BenchmarkSuite("NavierStokes", 1484000, [new Benchmark("NavierStokes", runNavierStokes, setupNavierStokes, tearDownNavierStokes)])
solver = null
framesTillAddingPoints = 0
framesBetweenAddingPoints = 5
