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

# A bit simpler than readable streams.
# Implement an async ._write(chunk, cb), and it'll handle all
# the drain event emission and buffering.
WriteReq = (chunk, encoding, cb) ->
  @chunk = chunk
  @encoding = encoding
  @callback = cb
  return
WritableState = (options, stream) ->
  options = options or {}
  
  # object stream flag to indicate whether or not this stream
  # contains buffers or objects.
  @objectMode = !!options.objectMode
  @objectMode = @objectMode or !!options.writableObjectMode  if stream instanceof Stream.Duplex
  
  # the point at which write() starts returning false
  # Note: 0 is a valid value, means that we always return false if
  # the entire buffer is not flushed immediately on write()
  hwm = options.highWaterMark
  defaultHwm = (if @objectMode then 16 else 16 * 1024)
  @highWaterMark = (if (hwm or hwm is 0) then hwm else defaultHwm)
  
  # cast to ints.
  @highWaterMark = ~~@highWaterMark
  @needDrain = false
  
  # at the start of calling end()
  @ending = false
  
  # when end() has been called, and returned
  @ended = false
  
  # when 'finish' is emitted
  @finished = false
  
  # should we decode strings into buffers before passing to _write?
  # this is here so that some node-core streams can optimize string
  # handling at a lower level.
  noDecode = options.decodeStrings is false
  @decodeStrings = not noDecode
  
  # Crypto is kind of old and crusty.  Historically, its default string
  # encoding is 'binary' so we have to make this configurable.
  # Everything else in the universe uses 'utf8', though.
  @defaultEncoding = options.defaultEncoding or "utf8"
  
  # not an actual buffer we keep track of, but a measurement
  # of how much we're waiting to get pushed to some underlying
  # socket or file.
  @length = 0
  
  # a flag to see when we're in the middle of a write.
  @writing = false
  
  # when true all writes will be buffered until .uncork() call
  @corked = 0
  
  # a flag to be able to tell if the onwrite cb is called immediately,
  # or on a later tick.  We set this to true at first, because any
  # actions that shouldn't happen until "later" should generally also
  # not happen before the first write call.
  @sync = true
  
  # a flag to know if we're processing previously buffered items, which
  # may call the _write() callback in the same tick, so that we don't
  # end up in an overlapped onwrite situation.
  @bufferProcessing = false
  
  # the callback that's passed to _write(chunk,cb)
  @onwrite = (er) ->
    onwrite stream, er
    return

  
  # the callback that the user supplies to write(chunk,encoding,cb)
  @writecb = null
  
  # the amount that is being written when _write is called.
  @writelen = 0
  @buffer = []
  
  # number of pending user-supplied write callbacks
  # this must be 0 before 'finish' can be emitted
  @pendingcb = 0
  
  # emit prefinish if the only thing we're waiting for is _write cbs
  # This is relevant for synchronous Transform streams
  @prefinished = false
  
  # True if the error was already emitted and should not be thrown again
  @errorEmitted = false
  return
Writable = (options) ->
  
  # Writable ctor is applied to Duplexes, though they're not
  # instanceof Writable, they're instanceof Readable.
  return new Writable(options)  if (this not instanceof Writable) and (this not instanceof Stream.Duplex)
  @_writableState = new WritableState(options, this)
  
  # legacy.
  @writable = true
  Stream.call this
  return

# Otherwise people can pipe Writable streams, which is just wrong.
writeAfterEnd = (stream, state, cb) ->
  er = new Error("write after end")
  
  # TODO: defer error events consistently everywhere, not just the cb
  stream.emit "error", er
  process.nextTick ->
    cb er
    return

  return

# If we get something that is not a buffer, string, null, or undefined,
# and we're not in objectMode, then that's an error.
# Otherwise stream chunks are all considered to be of length=1, and the
# watermarks determine how many objects to keep in the buffer, rather than
# how many bytes or characters.
validChunk = (stream, state, chunk, cb) ->
  valid = true
  if not util.isBuffer(chunk) and not util.isString(chunk) and not util.isNullOrUndefined(chunk) and not state.objectMode
    er = new TypeError("Invalid non-string/buffer chunk")
    stream.emit "error", er
    process.nextTick ->
      cb er
      return

    valid = false
  valid

# node::ParseEncoding() requires lower case.
decodeChunk = (state, chunk, encoding) ->
  chunk = new Buffer(chunk, encoding)  if not state.objectMode and state.decodeStrings isnt false and util.isString(chunk)
  chunk

# if we're already writing something, then just put this
# in the queue, and wait our turn.  Otherwise, call _write
# If we return false, then we need a drain event, so set that flag.
writeOrBuffer = (stream, state, chunk, encoding, cb) ->
  chunk = decodeChunk(state, chunk, encoding)
  encoding = "buffer"  if util.isBuffer(chunk)
  len = (if state.objectMode then 1 else chunk.length)
  state.length += len
  ret = state.length < state.highWaterMark
  
  # we must ensure that previous needDrain will not be reset to false.
  state.needDrain = true  unless ret
  if state.writing or state.corked
    state.buffer.push new WriteReq(chunk, encoding, cb)
  else
    doWrite stream, state, false, len, chunk, encoding, cb
  ret
doWrite = (stream, state, writev, len, chunk, encoding, cb) ->
  state.writelen = len
  state.writecb = cb
  state.writing = true
  state.sync = true
  if writev
    stream._writev chunk, state.onwrite
  else
    stream._write chunk, encoding, state.onwrite
  state.sync = false
  return
onwriteError = (stream, state, sync, er, cb) ->
  if sync
    process.nextTick ->
      state.pendingcb--
      cb er
      return

  else
    state.pendingcb--
    cb er
  stream._writableState.errorEmitted = true
  stream.emit "error", er
  return
onwriteStateUpdate = (state) ->
  state.writing = false
  state.writecb = null
  state.length -= state.writelen
  state.writelen = 0
  return
onwrite = (stream, er) ->
  state = stream._writableState
  sync = state.sync
  cb = state.writecb
  onwriteStateUpdate state
  if er
    onwriteError stream, state, sync, er, cb
  else
    
    # Check if we're actually ready to finish, but don't emit yet
    finished = needFinish(stream, state)
    clearBuffer stream, state  if not finished and not state.corked and not state.bufferProcessing and state.buffer.length
    if sync
      process.nextTick ->
        afterWrite stream, state, finished, cb
        return

    else
      afterWrite stream, state, finished, cb
  return
afterWrite = (stream, state, finished, cb) ->
  onwriteDrain stream, state  unless finished
  state.pendingcb--
  cb()
  finishMaybe stream, state
  return

# Must force callback to be called on nextTick, so that we don't
# emit 'drain' before the write() consumer gets the 'false' return
# value, and has a chance to attach a 'drain' listener.
onwriteDrain = (stream, state) ->
  if state.length is 0 and state.needDrain
    state.needDrain = false
    stream.emit "drain"
  return

# if there's something in the buffer waiting, then process it
clearBuffer = (stream, state) ->
  state.bufferProcessing = true
  if stream._writev and state.buffer.length > 1
    
    # Fast case, write everything using _writev()
    cbs = []
    c = 0

    while c < state.buffer.length
      cbs.push state.buffer[c].callback
      c++
    
    # count the one we are adding, as well.
    # TODO(isaacs) clean this up
    state.pendingcb++
    doWrite stream, state, true, state.length, state.buffer, "", (err) ->
      i = 0

      while i < cbs.length
        state.pendingcb--
        cbs[i] err
        i++
      return

    
    # Clear buffer
    state.buffer = []
  else
    
    # Slow case, write chunks one-by-one
    c = 0

    while c < state.buffer.length
      entry = state.buffer[c]
      chunk = entry.chunk
      encoding = entry.encoding
      cb = entry.callback
      len = (if state.objectMode then 1 else chunk.length)
      doWrite stream, state, false, len, chunk, encoding, cb
      
      # if we didn't call the onwrite immediately, then
      # it means that we need to wait until it does.
      # also, that means that the chunk and cb are currently
      # being processed, so move the buffer counter past them.
      if state.writing
        c++
        break
      c++
    if c < state.buffer.length
      state.buffer = state.buffer.slice(c)
    else
      state.buffer.length = 0
  state.bufferProcessing = false
  return

# .end() fully uncorks

# ignore unnecessary end() calls.
needFinish = (stream, state) ->
  state.ending and state.length is 0 and state.buffer.length is 0 and not state.finished and not state.writing
prefinish = (stream, state) ->
  unless state.prefinished
    state.prefinished = true
    stream.emit "prefinish"
  return
finishMaybe = (stream, state) ->
  need = needFinish(stream, state)
  if need
    if state.pendingcb is 0
      prefinish stream, state
      state.finished = true
      stream.emit "finish"
    else
      prefinish stream, state
  need
endWritable = (stream, state, cb) ->
  state.ending = true
  finishMaybe stream, state
  if cb
    if state.finished
      process.nextTick cb
    else
      stream.once "finish", cb
  state.ended = true
  return
"use strict"
module.exports = Writable
Writable.WritableState = WritableState
util = require("util")
Stream = require("stream")
util.inherits Writable, Stream
Writable::pipe = ->
  @emit "error", new Error("Cannot pipe. Not readable.")
  return

Writable::write = (chunk, encoding, cb) ->
  state = @_writableState
  ret = false
  if util.isFunction(encoding)
    cb = encoding
    encoding = null
  if util.isBuffer(chunk)
    encoding = "buffer"
  else encoding = state.defaultEncoding  unless encoding
  cb = ->  unless util.isFunction(cb)
  if state.ended
    writeAfterEnd this, state, cb
  else if validChunk(this, state, chunk, cb)
    state.pendingcb++
    ret = writeOrBuffer(this, state, chunk, encoding, cb)
  ret

Writable::cork = ->
  state = @_writableState
  state.corked++
  return

Writable::uncork = ->
  state = @_writableState
  if state.corked
    state.corked--
    clearBuffer this, state  if not state.writing and not state.corked and not state.finished and not state.bufferProcessing and state.buffer.length
  return

Writable::setDefaultEncoding = setDefaultEncoding = (encoding) ->
  encoding = encoding.toLowerCase()  if typeof encoding is "string"
  throw new TypeError("Unknown encoding: " + encoding)  unless Buffer.isEncoding(encoding)
  @_writableState.defaultEncoding = encoding
  return

Writable::_write = (chunk, encoding, cb) ->
  cb new Error("not implemented")
  return

Writable::_writev = null
Writable::end = (chunk, encoding, cb) ->
  state = @_writableState
  if util.isFunction(chunk)
    cb = chunk
    chunk = null
    encoding = null
  else if util.isFunction(encoding)
    cb = encoding
    encoding = null
  @write chunk, encoding  unless util.isNullOrUndefined(chunk)
  if state.corked
    state.corked = 1
    @uncork()
  endWritable this, state, cb  if not state.ending and not state.finished
  return
