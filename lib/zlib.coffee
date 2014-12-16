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

# zlib doesn't provide these, so kludge them in following the same
# const naming scheme zlib uses.

# fewer than 64 bytes per chunk is stupid.
# technically it could work with as few as 8, but even 64 bytes
# is absurdly low.  Usually a MB or more is best.

# expose all the zlib constants

# translation table for return codes.

# Convenience methods.
# compress/decompress a string or buffer in one step.
zlibBuffer = (engine, buffer, callback) ->
  flow = ->
    chunk = undefined
    while null isnt (chunk = engine.read())
      buffers.push chunk
      nread += chunk.length
    engine.once "readable", flow
    return
  onError = (err) ->
    engine.removeListener "end", onEnd
    engine.removeListener "readable", flow
    callback err
    return
  onEnd = ->
    buf = Buffer.concat(buffers, nread)
    buffers = []
    callback null, buf
    engine.close()
    return
  buffers = []
  nread = 0
  engine.on "error", onError
  engine.on "end", onEnd
  engine.end buffer
  flow()
  return
zlibBufferSync = (engine, buffer) ->
  buffer = new Buffer(buffer)  if util.isString(buffer)
  throw new TypeError("Not a string or buffer")  unless util.isBuffer(buffer)
  flushFlag = binding.Z_FINISH
  engine._processChunk buffer, flushFlag

# generic zlib
# minimal 2-byte header
Deflate = (opts) ->
  return new Deflate(opts)  unless this instanceof Deflate
  Zlib.call this, opts, binding.DEFLATE
  return
Inflate = (opts) ->
  return new Inflate(opts)  unless this instanceof Inflate
  Zlib.call this, opts, binding.INFLATE
  return

# gzip - bigger header, same deflate compression
Gzip = (opts) ->
  return new Gzip(opts)  unless this instanceof Gzip
  Zlib.call this, opts, binding.GZIP
  return
Gunzip = (opts) ->
  return new Gunzip(opts)  unless this instanceof Gunzip
  Zlib.call this, opts, binding.GUNZIP
  return

# raw - no header
DeflateRaw = (opts) ->
  return new DeflateRaw(opts)  unless this instanceof DeflateRaw
  Zlib.call this, opts, binding.DEFLATERAW
  return
InflateRaw = (opts) ->
  return new InflateRaw(opts)  unless this instanceof InflateRaw
  Zlib.call this, opts, binding.INFLATERAW
  return

# auto-detect header.
Unzip = (opts) ->
  return new Unzip(opts)  unless this instanceof Unzip
  Zlib.call this, opts, binding.UNZIP
  return

# the Zlib class they all inherit from
# This thing manages the queue of requests, and returns
# true or false if there is anything in the queue when
# you call the .write() method.
Zlib = (opts, mode) ->
  @_opts = opts = opts or {}
  @_chunkSize = opts.chunkSize or exports.Z_DEFAULT_CHUNK
  Transform.call this, opts
  throw new Error("Invalid flush flag: " + opts.flush)  if opts.flush isnt binding.Z_NO_FLUSH and opts.flush isnt binding.Z_PARTIAL_FLUSH and opts.flush isnt binding.Z_SYNC_FLUSH and opts.flush isnt binding.Z_FULL_FLUSH and opts.flush isnt binding.Z_FINISH and opts.flush isnt binding.Z_BLOCK  if opts.flush
  @_flushFlag = opts.flush or binding.Z_NO_FLUSH
  throw new Error("Invalid chunk size: " + opts.chunkSize)  if opts.chunkSize < exports.Z_MIN_CHUNK or opts.chunkSize > exports.Z_MAX_CHUNK  if opts.chunkSize
  throw new Error("Invalid windowBits: " + opts.windowBits)  if opts.windowBits < exports.Z_MIN_WINDOWBITS or opts.windowBits > exports.Z_MAX_WINDOWBITS  if opts.windowBits
  throw new Error("Invalid compression level: " + opts.level)  if opts.level < exports.Z_MIN_LEVEL or opts.level > exports.Z_MAX_LEVEL  if opts.level
  throw new Error("Invalid memLevel: " + opts.memLevel)  if opts.memLevel < exports.Z_MIN_MEMLEVEL or opts.memLevel > exports.Z_MAX_MEMLEVEL  if opts.memLevel
  throw new Error("Invalid strategy: " + opts.strategy)  if opts.strategy isnt exports.Z_FILTERED and opts.strategy isnt exports.Z_HUFFMAN_ONLY and opts.strategy isnt exports.Z_RLE and opts.strategy isnt exports.Z_FIXED and opts.strategy isnt exports.Z_DEFAULT_STRATEGY  if opts.strategy
  throw new Error("Invalid dictionary: it should be a Buffer instance")  unless util.isBuffer(opts.dictionary)  if opts.dictionary
  @_handle = new binding.Zlib(mode)
  self = this
  @_hadError = false
  @_handle.onerror = (message, errno) ->
    
    # there is no way to cleanly recover.
    # continuing only obscures problems.
    self._handle = null
    self._hadError = true
    error = new Error(message)
    error.errno = errno
    error.code = exports.codes[errno]
    self.emit "error", error
    return

  level = exports.Z_DEFAULT_COMPRESSION
  level = opts.level  if util.isNumber(opts.level)
  strategy = exports.Z_DEFAULT_STRATEGY
  strategy = opts.strategy  if util.isNumber(opts.strategy)
  @_handle.init opts.windowBits or exports.Z_DEFAULT_WINDOWBITS, level, opts.memLevel or exports.Z_DEFAULT_MEMLEVEL, strategy, opts.dictionary
  @_buffer = new Buffer(@_chunkSize)
  @_offset = 0
  @_closed = false
  @_level = level
  @_strategy = strategy
  @once "end", @close
  return
"use strict"
Transform = require("_stream_transform")
binding = process.binding("zlib")
util = require("util")
assert = require("assert").ok
binding.Z_MIN_WINDOWBITS = 8
binding.Z_MAX_WINDOWBITS = 15
binding.Z_DEFAULT_WINDOWBITS = 15
binding.Z_MIN_CHUNK = 64
binding.Z_MAX_CHUNK = Infinity
binding.Z_DEFAULT_CHUNK = (16 * 1024)
binding.Z_MIN_MEMLEVEL = 1
binding.Z_MAX_MEMLEVEL = 9
binding.Z_DEFAULT_MEMLEVEL = 8
binding.Z_MIN_LEVEL = -1
binding.Z_MAX_LEVEL = 9
binding.Z_DEFAULT_LEVEL = binding.Z_DEFAULT_COMPRESSION
bkeys = Object.keys(binding)
bk = 0

while bk < bkeys.length
  bkey = bkeys[bk]
  exports[bkey] = binding[bkey]  if bkey.match(/^Z/)
  bk++
exports.codes =
  Z_OK: binding.Z_OK
  Z_STREAM_END: binding.Z_STREAM_END
  Z_NEED_DICT: binding.Z_NEED_DICT
  Z_ERRNO: binding.Z_ERRNO
  Z_STREAM_ERROR: binding.Z_STREAM_ERROR
  Z_DATA_ERROR: binding.Z_DATA_ERROR
  Z_MEM_ERROR: binding.Z_MEM_ERROR
  Z_BUF_ERROR: binding.Z_BUF_ERROR
  Z_VERSION_ERROR: binding.Z_VERSION_ERROR

ckeys = Object.keys(exports.codes)
ck = 0

while ck < ckeys.length
  ckey = ckeys[ck]
  exports.codes[exports.codes[ckey]] = ckey
  ck++
exports.Deflate = Deflate
exports.Inflate = Inflate
exports.Gzip = Gzip
exports.Gunzip = Gunzip
exports.DeflateRaw = DeflateRaw
exports.InflateRaw = InflateRaw
exports.Unzip = Unzip
exports.createDeflate = (o) ->
  new Deflate(o)

exports.createInflate = (o) ->
  new Inflate(o)

exports.createDeflateRaw = (o) ->
  new DeflateRaw(o)

exports.createInflateRaw = (o) ->
  new InflateRaw(o)

exports.createGzip = (o) ->
  new Gzip(o)

exports.createGunzip = (o) ->
  new Gunzip(o)

exports.createUnzip = (o) ->
  new Unzip(o)

exports.deflate = (buffer, opts, callback) ->
  if util.isFunction(opts)
    callback = opts
    opts = {}
  zlibBuffer new Deflate(opts), buffer, callback

exports.deflateSync = (buffer, opts) ->
  zlibBufferSync new Deflate(opts), buffer

exports.gzip = (buffer, opts, callback) ->
  if util.isFunction(opts)
    callback = opts
    opts = {}
  zlibBuffer new Gzip(opts), buffer, callback

exports.gzipSync = (buffer, opts) ->
  zlibBufferSync new Gzip(opts), buffer

exports.deflateRaw = (buffer, opts, callback) ->
  if util.isFunction(opts)
    callback = opts
    opts = {}
  zlibBuffer new DeflateRaw(opts), buffer, callback

exports.deflateRawSync = (buffer, opts) ->
  zlibBufferSync new DeflateRaw(opts), buffer

exports.unzip = (buffer, opts, callback) ->
  if util.isFunction(opts)
    callback = opts
    opts = {}
  zlibBuffer new Unzip(opts), buffer, callback

exports.unzipSync = (buffer, opts) ->
  zlibBufferSync new Unzip(opts), buffer

exports.inflate = (buffer, opts, callback) ->
  if util.isFunction(opts)
    callback = opts
    opts = {}
  zlibBuffer new Inflate(opts), buffer, callback

exports.inflateSync = (buffer, opts) ->
  zlibBufferSync new Inflate(opts), buffer

exports.gunzip = (buffer, opts, callback) ->
  if util.isFunction(opts)
    callback = opts
    opts = {}
  zlibBuffer new Gunzip(opts), buffer, callback

exports.gunzipSync = (buffer, opts) ->
  zlibBufferSync new Gunzip(opts), buffer

exports.inflateRaw = (buffer, opts, callback) ->
  if util.isFunction(opts)
    callback = opts
    opts = {}
  zlibBuffer new InflateRaw(opts), buffer, callback

exports.inflateRawSync = (buffer, opts) ->
  zlibBufferSync new InflateRaw(opts), buffer

util.inherits Zlib, Transform
Zlib::params = (level, strategy, callback) ->
  throw new RangeError("Invalid compression level: " + level)  if level < exports.Z_MIN_LEVEL or level > exports.Z_MAX_LEVEL
  throw new TypeError("Invalid strategy: " + strategy)  if strategy isnt exports.Z_FILTERED and strategy isnt exports.Z_HUFFMAN_ONLY and strategy isnt exports.Z_RLE and strategy isnt exports.Z_FIXED and strategy isnt exports.Z_DEFAULT_STRATEGY
  if @_level isnt level or @_strategy isnt strategy
    self = this
    @flush binding.Z_SYNC_FLUSH, ->
      assert not self._closed, "zlib binding closed"
      self._handle.params level, strategy
      unless self._hadError
        self._level = level
        self._strategy = strategy
        callback()  if callback
      return

  else
    process.nextTick callback
  return

Zlib::reset = ->
  assert not @_closed, "zlib binding closed"
  @_handle.reset()


# This is the _flush function called by the transform class,
# internally, when the last chunk has been written.
Zlib::_flush = (callback) ->
  @_transform new Buffer(0), "", callback
  return

Zlib::flush = (kind, callback) ->
  ws = @_writableState
  if util.isFunction(kind) or (util.isUndefined(kind) and not callback)
    callback = kind
    kind = binding.Z_FULL_FLUSH
  if ws.ended
    process.nextTick callback  if callback
  else if ws.ending
    @once "end", callback  if callback
  else if ws.needDrain
    self = this
    @once "drain", ->
      self.flush callback
      return

  else
    @_flushFlag = kind
    @write new Buffer(0), "", callback
  return

Zlib::close = (callback) ->
  process.nextTick callback  if callback
  return  if @_closed
  @_closed = true
  @_handle.close()
  self = this
  process.nextTick ->
    self.emit "close"
    return

  return

Zlib::_transform = (chunk, encoding, cb) ->
  flushFlag = undefined
  ws = @_writableState
  ending = ws.ending or ws.ended
  last = ending and (not chunk or ws.length is chunk.length)
  return cb(new Error("invalid input"))  if not util.isNull(chunk) and not util.isBuffer(chunk)
  return cb(new Error("zlib binding closed"))  if @_closed
  
  # If it's the last chunk, or a final flush, we use the Z_FINISH flush flag.
  # If it's explicitly flushing at some other time, then we use
  # Z_FULL_FLUSH. Otherwise, use Z_NO_FLUSH for maximum compression
  # goodness.
  if last
    flushFlag = binding.Z_FINISH
  else
    flushFlag = @_flushFlag
    
    # once we've flushed the last of the queue, stop flushing and
    # go back to the normal behavior.
    @_flushFlag = @_opts.flush or binding.Z_NO_FLUSH  if chunk.length >= ws.length
  @_processChunk chunk, flushFlag, cb
  return

Zlib::_processChunk = (chunk, flushFlag, cb) ->
  # in
  # in_off
  # in_len
  # out
  #out_off
  # out_len
  # in
  # in_off
  # in_len
  # out
  #out_off
  # out_len
  callback = (availInAfter, availOutAfter) ->
    return  if self._hadError
    have = availOutBefore - availOutAfter
    assert have >= 0, "have should not go down"
    if have > 0
      out = self._buffer.slice(self._offset, self._offset + have)
      self._offset += have
      
      # serve some output to the consumer.
      if async
        self.push out
      else
        buffers.push out
        nread += out.length
    
    # exhausted the output buffer, or used all the input create a new one.
    if availOutAfter is 0 or self._offset >= self._chunkSize
      availOutBefore = self._chunkSize
      self._offset = 0
      self._buffer = new Buffer(self._chunkSize)
    if availOutAfter is 0 or availInAfter > 0
      
      # Not actually done.  Need to reprocess.
      # Also, update the availInBefore to the availInAfter value,
      # so that if we have to hit it a third (fourth, etc.) time,
      # it'll have the correct byte counts.
      inOff += (availInBefore - availInAfter)
      availInBefore = availInAfter
      if availOutAfter isnt 0
        
        # There is still some data available for reading.
        # This is usually a concatenated stream, so, reset and restart.
        self.reset()
        self._offset = 0
      return true  unless async
      newReq = self._handle.write(flushFlag, chunk, inOff, availInBefore, self._buffer, self._offset, self._chunkSize)
      newReq.callback = callback # this same function
      newReq.buffer = chunk
      return
    return false  unless async
    
    # finished with the chunk.
    cb()
    return
  availInBefore = chunk and chunk.length
  availOutBefore = @_chunkSize - @_offset
  inOff = 0
  self = this
  async = util.isFunction(cb)
  unless async
    buffers = []
    nread = 0
    error = undefined
    @on "error", (er) ->
      error = er
      return

    assert not @_closed, "zlib binding closed"
    loop
      res = @_handle.writeSync(flushFlag, chunk, inOff, availInBefore, @_buffer, @_offset, availOutBefore)
      break unless not @_hadError and callback(res[0], res[1])
    throw error  if @_hadError
    buf = Buffer.concat(buffers, nread)
    @close()
    return buf
  assert not @_closed, "zlib binding closed"
  req = @_handle.write(flushFlag, chunk, inOff, availInBefore, @_buffer, @_offset, availOutBefore)
  req.buffer = chunk
  req.callback = callback
  return

util.inherits Deflate, Zlib
util.inherits Inflate, Zlib
util.inherits Gzip, Zlib
util.inherits Gunzip, Zlib
util.inherits DeflateRaw, Zlib
util.inherits InflateRaw, Zlib
util.inherits Unzip, Zlib
