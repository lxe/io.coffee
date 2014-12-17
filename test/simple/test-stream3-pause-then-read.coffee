# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
push = ->
  chunk = (if chunks-- > 0 then new Buffer(chunkSize) else null)
  if chunk
    totalPushed += chunk.length
    chunk.fill "x"
  r.push chunk
  return

# first we read 100 bytes
read100 = ->
  readn 100, onData
  return
readn = (n, then_) ->
  console.error "read %d", n
  expectEndingData -= n
  (read = ->
    c = r.read(n)
    unless c
      r.once "readable", read
    else
      assert.equal c.length, n
      assert not r._readableState.flowing
      then_()
    return
  )()
  return

# then we listen to some data events
onData = ->
  expectEndingData -= 100
  console.error "onData"
  seen = 0
  r.on "data", od = (c) ->
    seen += c.length
    if seen >= 100
      
      # seen enough
      r.removeListener "data", od
      r.pause()
      if seen > 100
        
        # oh no, seen too much!
        # put the extra back.
        diff = seen - 100
        r.unshift c.slice(c.length - diff)
        console.error "seen too much", seen, diff
      
      # Nothing should be lost in between
      setImmediate pipeLittle
    return

  return

# Just pipe 200 bytes, then unshift the extra and unpipe
pipeLittle = ->
  expectEndingData -= 200
  console.error "pipe a little"
  w = new Writable()
  written = 0
  w.on "finish", ->
    assert.equal written, 200
    setImmediate read1234
    return

  w._write = (chunk, encoding, cb) ->
    written += chunk.length
    if written >= 200
      r.unpipe w
      w.end()
      cb()
      if written > 200
        diff = written - 200
        written -= diff
        r.unshift chunk.slice(chunk.length - diff)
    else
      setImmediate cb
    return

  r.pipe w
  return

# now read 1234 more bytes
read1234 = ->
  readn 1234, resumePause
  return
resumePause = ->
  console.error "resumePause"
  
  # don't read anything, just resume and re-pause a whole bunch
  r.resume()
  r.pause()
  r.resume()
  r.pause()
  r.resume()
  r.pause()
  r.resume()
  r.pause()
  r.resume()
  r.pause()
  setImmediate pipe
  return
pipe = ->
  console.error "pipe the rest"
  w = new Writable()
  written = 0
  w._write = (chunk, encoding, cb) ->
    written += chunk.length
    cb()
    return

  w.on "finish", ->
    console.error "written", written, totalPushed
    assert.equal written, expectEndingData
    assert.equal totalPushed, expectTotalData
    console.log "ok"
    return

  r.pipe w
  return
common = require("../common")
assert = require("assert")
stream = require("stream")
Readable = stream.Readable
Writable = stream.Writable
totalChunks = 100
chunkSize = 99
expectTotalData = totalChunks * chunkSize
expectEndingData = expectTotalData
r = new Readable(highWaterMark: 1000)
chunks = totalChunks
r._read = (n) ->
  unless chunks % 2
    setImmediate push
  else unless chunks % 3
    process.nextTick push
  else
    push()
  return

totalPushed = 0
read100()
