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

# how fast to trickle through the slowstream

# tunable options for zlib classes.

# several different chunk sizes

# this is every possible value.

# it's nice in theory to test every combination, but it
# takes WAY too long.  Maybe a pummel test could do this?

# stream that saves everything
BufferStream = ->
  @chunks = []
  @length = 0
  @writable = true
  @readable = true
  return

# flatten
SlowStream = (trickle) ->
  @trickle = trickle
  @offset = 0
  @readable = @writable = true
  return
common = require("../common.js")
assert = require("assert")
zlib = require("zlib")
path = require("path")
zlibPairs = [
  [
    zlib.Deflate
    zlib.Inflate
  ]
  [
    zlib.Gzip
    zlib.Gunzip
  ]
  [
    zlib.Deflate
    zlib.Unzip
  ]
  [
    zlib.Gzip
    zlib.Unzip
  ]
  [
    zlib.DeflateRaw
    zlib.InflateRaw
  ]
]
trickle = [
  128
  1024
  1024 * 1024
]
chunkSize = [
  128
  1024
  1024 * 16
  1024 * 1024
]
level = [
  -1
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
windowBits = [
  8
  9
  10
  11
  12
  13
  14
  15
]
memLevel = [
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
strategy = [
  0
  1
  2
  3
  4
]
unless process.env.PUMMEL
  trickle = [1024]
  chunkSize = [1024 * 16]
  level = [6]
  memLevel = [8]
  windowBits = [15]
  strategy = [0]
fs = require("fs")
testFiles = [
  "person.jpg"
  "elipses.txt"
  "empty.txt"
]
if process.env.FAST
  zlibPairs = [[
    zlib.Gzip
    zlib.Unzip
  ]]
  testFiles = ["person.jpg"]
tests = {}
testFiles.forEach (file) ->
  tests[file] = fs.readFileSync(path.resolve(common.fixturesDir, file))
  return

util = require("util")
stream = require("stream")
util.inherits BufferStream, stream.Stream
BufferStream::write = (c) ->
  @chunks.push c
  @length += c.length
  true

BufferStream::end = (c) ->
  @write c  if c
  buf = new Buffer(@length)
  i = 0
  @chunks.forEach (c) ->
    c.copy buf, i
    i += c.length
    return

  @emit "data", buf
  @emit "end"
  true

util.inherits SlowStream, stream.Stream
SlowStream::write = ->
  throw new Error("not implemented, just call ss.end(chunk)")return

SlowStream::pause = ->
  @paused = true
  @emit "pause"
  return

SlowStream::resume = ->
  emit = ->
    return  if self.paused
    if self.offset >= self.length
      self.ended = true
      return self.emit("end")
    end = Math.min(self.offset + self.trickle, self.length)
    c = self.chunk.slice(self.offset, end)
    self.offset += c.length
    self.emit "data", c
    process.nextTick emit
    return
  self = this
  return  if self.ended
  self.emit "resume"
  return  unless self.chunk
  self.paused = false
  emit()
  return

SlowStream::end = (chunk) ->
  
  # walk over the chunk in blocks.
  self = this
  self.chunk = chunk
  self.length = chunk.length
  self.resume()
  self.ended


# for each of the files, make sure that compressing and
# decompressing results in the same data, for every combination
# of the options set above.
failures = 0
total = 0
done = 0
Object.keys(tests).forEach (file) ->
  test = tests[file]
  chunkSize.forEach (chunkSize) ->
    trickle.forEach (trickle) ->
      windowBits.forEach (windowBits) ->
        level.forEach (level) ->
          memLevel.forEach (memLevel) ->
            strategy.forEach (strategy) ->
              zlibPairs.forEach (pair) ->
                Def = pair[0]
                Inf = pair[1]
                opts =
                  level: level
                  windowBits: windowBits
                  memLevel: memLevel
                  strategy: strategy

                total++
                def = new Def(opts)
                inf = new Inf(opts)
                ss = new SlowStream(trickle)
                buf = new BufferStream()
                
                # verify that the same exact buffer comes out the other end.
                buf.on "data", (c) ->
                  msg = file + " " + chunkSize + " " + JSON.stringify(opts) + " " + Def.name + " -> " + Inf.name
                  ok = true
                  testNum = ++done
                  i = 0

                  while i < Math.max(c.length, test.length)
                    if c[i] isnt test[i]
                      ok = false
                      failures++
                      break
                    i++
                  if ok
                    console.log "ok " + (testNum) + " " + msg
                  else
                    console.log "not ok " + (testNum) + " " + msg
                    console.log "  ..."
                    console.log "  testfile: " + file
                    console.log "  type: " + Def.name + " -> " + Inf.name
                    console.log "  position: " + i
                    console.log "  options: " + JSON.stringify(opts)
                    console.log "  expect: " + test[i]
                    console.log "  actual: " + c[i]
                    console.log "  chunkSize: " + chunkSize
                    console.log "  ---"
                  return

                
                # the magic happens here.
                ss.pipe(def).pipe(inf).pipe buf
                ss.end test
                return

              return

            return

          return

        return

      return

    return

  return

# sad stallman is sad.
process.on "exit", (code) ->
  console.log "1.." + done
  assert.equal done, total, (total - done) + " tests left unfinished"
  assert.ok not failures, "some test failures"
  return

