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

# emit random bytes, and keep a shasum
RandomReadStream = (opt) ->
  Stream.call this
  @readable = true
  @_paused = false
  @_processing = false
  @_hasher = crypto.createHash("sha1")
  opt = opt or {}
  
  # base block size.
  opt.block = opt.block or 256 * 1024
  
  # total number of bytes to emit
  opt.total = opt.total or 256 * 1024 * 1024
  @_remaining = opt.total
  
  # how variable to make the block sizes
  opt.jitter = opt.jitter or 1024
  @_opt = opt
  @_process = @_process.bind(this)
  process.nextTick @_process
  return

# console.error("rrs resume");

# figure out how many bytes to output
# if finished, then just emit end.

# a filter that just verifies a shasum
HashStream = ->
  Stream.call this
  @readable = @writable = true
  @_hasher = crypto.createHash("sha1")
  return
common = require("../common")
crypto = require("crypto")
stream = require("stream")
Stream = stream.Stream
util = require("util")
assert = require("assert")
zlib = require("zlib")
util.inherits RandomReadStream, Stream
RandomReadStream::pause = ->
  @_paused = true
  @emit "pause"
  return

RandomReadStream::resume = ->
  @_paused = false
  @emit "resume"
  @_process()
  return

RandomReadStream::_process = ->
  return  if @_processing
  return  if @_paused
  @_processing = true
  unless @_remaining
    @_hash = @_hasher.digest("hex").toLowerCase().trim()
    @_processing = false
    @emit "end"
    return
  block = @_opt.block
  jitter = @_opt.jitter
  block += Math.ceil(Math.random() * jitter - (jitter / 2))  if jitter
  block = Math.min(block, @_remaining)
  buf = new Buffer(block)
  i = 0

  while i < block
    buf[i] = Math.random() * 256
    i++
  @_hasher.update buf
  @_remaining -= block
  console.error "block=%d\nremain=%d\n", block, @_remaining
  @_processing = false
  @emit "data", buf
  process.nextTick @_process
  return

util.inherits HashStream, Stream
HashStream::write = (c) ->
  
  # Simulate the way that an fs.ReadStream returns false
  # on *every* write like a jerk, only to resume a
  # moment later.
  @_hasher.update c
  process.nextTick @resume.bind(this)
  false

HashStream::resume = ->
  @emit "resume"
  process.nextTick @emit.bind(this, "drain")
  return

HashStream::end = (c) ->
  @write c  if c
  @_hash = @_hasher.digest("hex").toLowerCase().trim()
  @emit "data", @_hash
  @emit "end"
  return

inp = new RandomReadStream(
  total: 1024
  block: 256
  jitter: 16
)
out = new HashStream()
gzip = zlib.createGzip()
gunz = zlib.createGunzip()
inp.pipe(gzip).pipe(gunz).pipe out
inp.on "data", (c) ->
  console.error "inp data", c.length
  return

gzip.on "data", (c) ->
  console.error "gzip data", c.length
  return

gunz.on "data", (c) ->
  console.error "gunz data", c.length
  return

out.on "data", (c) ->
  console.error "out data", c.length
  return

didSomething = false
out.on "data", (c) ->
  didSomething = true
  console.error "hash=%s", c
  assert.equal c, inp._hash, "hashes should match"
  return

process.on "exit", ->
  assert didSomething, "should have done something"
  return

