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
ReadableState = (options, stream) ->
  options = options or {}
  
  # object stream flag. Used to make read(n) ignore n and to
  # make all the buffer merging and length checks go away
  @objectMode = !!options.objectMode
  @objectMode = @objectMode or !!options.readableObjectMode  if stream instanceof Stream.Duplex
  
  # the point at which it stops calling _read() to fill the buffer
  # Note: 0 is a valid value, means "don't call _read preemptively ever"
  hwm = options.highWaterMark
  defaultHwm = (if @objectMode then 16 else 16 * 1024)
  @highWaterMark = (if (hwm or hwm is 0) then hwm else defaultHwm)
  
  # cast to ints.
  @highWaterMark = ~~@highWaterMark
  @buffer = []
  @length = 0
  @pipes = null
  @pipesCount = 0
  @flowing = null
  @ended = false
  @endEmitted = false
  @reading = false
  
  # a flag to be able to tell if the onwrite cb is called immediately,
  # or on a later tick.  We set this to true at first, because any
  # actions that shouldn't happen until "later" should generally also
  # not happen before the first write call.
  @sync = true
  
  # whenever we return null, then we set a flag to say
  # that we're awaiting a 'readable' event emission.
  @needReadable = false
  @emittedReadable = false
  @readableListening = false
  
  # Crypto is kind of old and crusty.  Historically, its default string
  # encoding is 'binary' so we have to make this configurable.
  # Everything else in the universe uses 'utf8', though.
  @defaultEncoding = options.defaultEncoding or "utf8"
  
  # when piping, we only care about 'readable' events that happen
  # after read()ing all the bytes and not getting any pushback.
  @ranOut = false
  
  # the number of writers that are awaiting a drain event in .pipe()s
  @awaitDrain = 0
  
  # if true, a maybeReadMore has been scheduled
  @readingMore = false
  @decoder = null
  @encoding = null
  if options.encoding
    StringDecoder = require("string_decoder").StringDecoder  unless StringDecoder
    @decoder = new StringDecoder(options.encoding)
    @encoding = options.encoding
  return
Readable = (options) ->
  return new Readable(options)  unless this instanceof Readable
  @_readableState = new ReadableState(options, this)
  
  # legacy
  @readable = true
  Stream.call this
  return

# Manually shove something into the read() buffer.
# This returns true if the highWaterMark has not been hit yet,
# similar to how Writable.write() returns true if you should
# write() some more.

# Unshift should *always* be something directly out of read()
readableAddChunk = (stream, state, chunk, encoding, addToFront) ->
  er = chunkInvalid(state, chunk)
  if er
    stream.emit "error", er
  else if chunk is null
    state.reading = false
    onEofChunk stream, state  unless state.ended
  else if state.objectMode or chunk and chunk.length > 0
    if state.ended and not addToFront
      e = new Error("stream.push() after EOF")
      stream.emit "error", e
    else if state.endEmitted and addToFront
      e = new Error("stream.unshift() after end event")
      stream.emit "error", e
    else
      chunk = state.decoder.write(chunk)  if state.decoder and not addToFront and not encoding
      state.reading = false  unless addToFront
      
      # if we want the data now, just emit it.
      if state.flowing and state.length is 0 and not state.sync
        stream.emit "data", chunk
        stream.read 0
      else
        
        # update the buffer info.
        state.length += (if state.objectMode then 1 else chunk.length)
        if addToFront
          state.buffer.unshift chunk
        else
          state.buffer.push chunk
        emitReadable stream  if state.needReadable
      maybeReadMore stream, state
  else state.reading = false  unless addToFront
  needMoreData state

# if it's past the high water mark, we can push in some more.
# Also, if we have no data yet, we can stand some
# more bytes.  This is to work around cases where hwm=0,
# such as the repl.  Also, if the push() triggered a
# readable event, and the user called read(largeNumber) such that
# needReadable was set, then we ought to push more, so that another
# 'readable' event will be triggered.
needMoreData = (state) ->
  not state.ended and (state.needReadable or state.length < state.highWaterMark or state.length is 0)

# backwards compatibility.

# Don't raise the hwm > 128MB
roundUpToNextPowerOf2 = (n) ->
  if n >= MAX_HWM
    n = MAX_HWM
  else
    
    # Get the next highest power of 2
    n--
    p = 1

    while p < 32
      n |= n >> p
      p <<= 1
    n++
  n
howMuchToRead = (n, state) ->
  return 0  if state.length is 0 and state.ended
  return (if n is 0 then 0 else 1)  if state.objectMode
  if util.isNull(n) or isNaN(n)
    
    # only flow one buffer at a time
    if state.flowing and state.buffer.length
      return state.buffer[0].length
    else
      return state.length
  return 0  if n <= 0
  
  # If we're asking for more than the target buffer level,
  # then raise the water mark.  Bump up to the next highest
  # power of 2, to prevent increasing it excessively in tiny
  # amounts.
  state.highWaterMark = roundUpToNextPowerOf2(n)  if n > state.highWaterMark
  
  # don't have that much.  return null, unless we've ended.
  if n > state.length
    unless state.ended
      state.needReadable = true
      return 0
    else
      return state.length
  n

# you can override either this method, or the async _read(n) below.

# if we're doing read(0) to trigger a readable event, but we
# already have a bunch of data in the buffer, then just trigger
# the 'readable' event and move on.

# if we've ended, and we're now clear, then finish it up.

# All the actual chunk generation logic needs to be
# *below* the call to _read.  The reason is that in certain
# synthetic stream cases, such as passthrough streams, _read
# may be a completely synchronous operation which may change
# the state of the read buffer, providing enough data when
# before there was *not* enough.
#
# So, the steps are:
# 1. Figure out what the state of things will be after we do
# a read from the buffer.
#
# 2. If that resulting state will trigger a _read, then call _read.
# Note that this may be asynchronous, or synchronous.  Yes, it is
# deeply ugly to write APIs this way, but that still doesn't mean
# that the Readable class should behave improperly, as streams are
# designed to be sync/async agnostic.
# Take note if the _read call is sync or async (ie, if the read call
# has returned yet), so that we know whether or not it's safe to emit
# 'readable' etc.
#
# 3. Actually pull the requested chunks out of the buffer and return.

# if we need a readable event, then we need to do some reading.

# if we currently have less than the highWaterMark, then also read some

# however, if we've ended, then there's no point, and if we're already
# reading, then it's unnecessary.

# if the length is currently zero, then we *need* a readable event.

# call internal read method

# If _read pushed data synchronously, then `reading` will be false,
# and we need to re-evaluate how much data we can return to the user.

# If we have nothing in the buffer, then we want to know
# as soon as we *do* get something into the buffer.

# If we tried to read() past the EOF, then emit end on the next tick.
chunkInvalid = (state, chunk) ->
  er = null
  er = new TypeError("Invalid non-string/buffer chunk")  if not util.isBuffer(chunk) and not util.isString(chunk) and not util.isNullOrUndefined(chunk) and not state.objectMode
  er
onEofChunk = (stream, state) ->
  if state.decoder and not state.ended
    chunk = state.decoder.end()
    if chunk and chunk.length
      state.buffer.push chunk
      state.length += (if state.objectMode then 1 else chunk.length)
  state.ended = true
  
  # emit 'readable' now to make sure it gets picked up.
  emitReadable stream
  return

# Don't emit readable right away in sync mode, because this can trigger
# another read() call => stack overflow.  This way, it might trigger
# a nextTick recursion warning, but that's not so bad.
emitReadable = (stream) ->
  state = stream._readableState
  state.needReadable = false
  unless state.emittedReadable
    debug "emitReadable", state.flowing
    state.emittedReadable = true
    if state.sync
      process.nextTick ->
        emitReadable_ stream
        return

    else
      emitReadable_ stream
  return
emitReadable_ = (stream) ->
  debug "emit readable"
  stream.emit "readable"
  flow stream
  return

# at this point, the user has presumably seen the 'readable' event,
# and called read() to consume some data.  that may have triggered
# in turn another _read(n) call, in which case reading = true if
# it's in progress.
# However, if we're not ended, or reading, and the length < hwm,
# then go ahead and try to read some more preemptively.
maybeReadMore = (stream, state) ->
  unless state.readingMore
    state.readingMore = true
    process.nextTick ->
      maybeReadMore_ stream, state
      return

  return
maybeReadMore_ = (stream, state) ->
  len = state.length
  while not state.reading and not state.flowing and not state.ended and state.length < state.highWaterMark
    debug "maybeReadMore read 0"
    stream.read 0
    if len is state.length
      
      # didn't get any data, stop spinning.
      break
    else
      len = state.length
  state.readingMore = false
  return

# abstract method.  to be overridden in specific implementation classes.
# call cb(er, data) where data is <= n in length.
# for virtual (non-string, non-buffer) streams, "length" is somewhat
# arbitrary, and perhaps not very meaningful.

# when the dest drains, it reduces the awaitDrain counter
# on the source.  This would be more elegant with a .once()
# handler in flow(), but adding and removing repeatedly is
# too slow.

# cleanup event handlers once the pipe is broken

# if the reader is waiting for a drain event from this
# specific writer, then it would cause it to never start
# flowing again.
# So, if this is awaiting a drain, then we just call it now.
# If we don't know, then assume that we are waiting for one.

# if the dest has an error, then stop piping into it.
# however, don't suppress the throwing behavior for this.

# This is a brutally ugly hack to make sure that our error handler
# is attached before any userland ones.  NEVER DO THIS.

# Both close and finish should trigger unpipe, but only once.

# tell the dest that it's being piped to

# start the flow if it hasn't been started already.
pipeOnDrain = (src) ->
  ->
    state = src._readableState
    debug "pipeOnDrain", state.awaitDrain
    state.awaitDrain--  if state.awaitDrain
    if state.awaitDrain is 0 and EE.listenerCount(src, "data")
      state.flowing = true
      flow src
    return

# if we're not piping anywhere, then do nothing.

# just one destination.  most common case.

# passed in one, but it's not the right one.

# got a match.

# slow case. multiple pipe destinations.

# remove all.

# try to find the right one.

# set up data events if they are asked for
# Ensure readable listeners eventually get something

# If listening to data, and it has not explicitly been paused,
# then call resume to start the flow of data on the next tick.

# pause() and resume() are remnants of the legacy readable stream API
# If the user uses them, then switch into old mode.
resume = (stream, state) ->
  unless state.resumeScheduled
    state.resumeScheduled = true
    process.nextTick ->
      resume_ stream, state
      return

  return
resume_ = (stream, state) ->
  unless state.reading
    debug "resume read 0"
    stream.read 0
  state.resumeScheduled = false
  stream.emit "resume"
  flow stream
  stream.read 0  if state.flowing and not state.reading
  return
flow = (stream) ->
  state = stream._readableState
  debug "flow", state.flowing
  if state.flowing
    loop
      chunk = stream.read()
      break unless null isnt chunk and state.flowing
  return

# wrap an old-style stream as the async data source.
# This is *not* part of the readable stream interface.
# It is an ugly unfortunate mess of history.

# don't skip over falsy values in objectMode
#if (state.objectMode && util.isNullOrUndefined(chunk))

# proxy all the other methods.
# important when wrapping filters and duplexes.

# proxy certain important events.

# when we try to consume some more bytes, simply unpause the
# underlying stream.

# exposed for testing purposes only.

# Pluck off n bytes from an array of buffers.
# Length is the combined lengths of all the buffers in the list.
fromList = (n, state) ->
  list = state.buffer
  length = state.length
  stringMode = !!state.decoder
  objectMode = !!state.objectMode
  ret = undefined
  
  # nothing in the list, definitely empty.
  return null  if list.length is 0
  if length is 0
    ret = null
  else if objectMode
    ret = list.shift()
  else if not n or n >= length
    
    # read it all, truncate the array.
    if stringMode
      ret = list.join("")
    else
      ret = Buffer.concat(list, length)
    list.length = 0
  else
    
    # read just some of it.
    if n < list[0].length
      
      # just take a part of the first list item.
      # slice is the same for buffers and strings.
      buf = list[0]
      ret = buf.slice(0, n)
      list[0] = buf.slice(n)
    else if n is list[0].length
      
      # first list is a perfect match
      ret = list.shift()
    else
      
      # complex case.
      # we have enough to cover it, but it spans past the first buffer.
      if stringMode
        ret = ""
      else
        ret = new Buffer(n)
      c = 0
      i = 0
      l = list.length

      while i < l and c < n
        buf = list[0]
        cpy = Math.min(n - c, buf.length)
        if stringMode
          ret += buf.slice(0, cpy)
        else
          buf.copy ret, c, 0, cpy
        if cpy < buf.length
          list[0] = buf.slice(cpy)
        else
          list.shift()
        c += cpy
        i++
  ret
endReadable = (stream) ->
  state = stream._readableState
  
  # If we get here before consuming all the bytes, then that is a
  # bug in node.  Should never happen.
  throw new Error("endReadable called on non-empty stream")  if state.length > 0
  unless state.endEmitted
    state.ended = true
    process.nextTick ->
      
      # Check that we didn't get one last unshift.
      if not state.endEmitted and state.length is 0
        state.endEmitted = true
        stream.readable = false
        stream.emit "end"
      return

  return
"use strict"
module.exports = Readable
Readable.ReadableState = ReadableState
EE = require("events").EventEmitter
Stream = require("stream")
util = require("util")
StringDecoder = undefined
debug = util.debuglog("stream")
util.inherits Readable, Stream
Readable::push = (chunk, encoding) ->
  state = @_readableState
  if util.isString(chunk) and not state.objectMode
    encoding = encoding or state.defaultEncoding
    if encoding isnt state.encoding
      chunk = new Buffer(chunk, encoding)
      encoding = ""
  readableAddChunk this, state, chunk, encoding, false

Readable::unshift = (chunk) ->
  state = @_readableState
  readableAddChunk this, state, chunk, "", true

Readable::isPaused = ->
  @_readableState.flowing is false

Readable::setEncoding = (enc) ->
  StringDecoder = require("string_decoder").StringDecoder  unless StringDecoder
  @_readableState.decoder = new StringDecoder(enc)
  @_readableState.encoding = enc
  this

MAX_HWM = 0x800000
Readable::read = (n) ->
  debug "read", n
  state = @_readableState
  nOrig = n
  state.emittedReadable = false  if not util.isNumber(n) or n > 0
  if n is 0 and state.needReadable and (state.length >= state.highWaterMark or state.ended)
    debug "read: emitReadable", state.length, state.ended
    if state.length is 0 and state.ended
      endReadable this
    else
      emitReadable this
    return null
  n = howMuchToRead(n, state)
  if n is 0 and state.ended
    endReadable this  if state.length is 0
    return null
  doRead = state.needReadable
  debug "need readable", doRead
  if state.length is 0 or state.length - n < state.highWaterMark
    doRead = true
    debug "length less than watermark", doRead
  if state.ended or state.reading
    doRead = false
    debug "reading or ended", doRead
  if doRead
    debug "do read"
    state.reading = true
    state.sync = true
    state.needReadable = true  if state.length is 0
    @_read state.highWaterMark
    state.sync = false
  n = howMuchToRead(nOrig, state)  if doRead and not state.reading
  ret = undefined
  if n > 0
    ret = fromList(n, state)
  else
    ret = null
  if util.isNull(ret)
    state.needReadable = true
    n = 0
  state.length -= n
  state.needReadable = true  if state.length is 0 and not state.ended
  endReadable this  if nOrig isnt n and state.ended and state.length is 0
  @emit "data", ret  unless util.isNull(ret)
  ret

Readable::_read = (n) ->
  @emit "error", new Error("not implemented")
  return

Readable::pipe = (dest, pipeOpts) ->
  onunpipe = (readable) ->
    debug "onunpipe"
    cleanup()  if readable is src
    return
  onend = ->
    debug "onend"
    dest.end()
    return
  cleanup = ->
    debug "cleanup"
    dest.removeListener "close", onclose
    dest.removeListener "finish", onfinish
    dest.removeListener "drain", ondrain
    dest.removeListener "error", onerror
    dest.removeListener "unpipe", onunpipe
    src.removeListener "end", onend
    src.removeListener "end", cleanup
    src.removeListener "data", ondata
    ondrain()  if state.awaitDrain and (not dest._writableState or dest._writableState.needDrain)
    return
  ondata = (chunk) ->
    debug "ondata"
    ret = dest.write(chunk)
    if false is ret
      debug "false write response, pause", src._readableState.awaitDrain
      src._readableState.awaitDrain++
      src.pause()
    return
  onerror = (er) ->
    debug "onerror", er
    unpipe()
    dest.removeListener "error", onerror
    dest.emit "error", er  if EE.listenerCount(dest, "error") is 0
    return
  onclose = ->
    dest.removeListener "finish", onfinish
    unpipe()
    return
  onfinish = ->
    debug "onfinish"
    dest.removeListener "close", onclose
    unpipe()
    return
  unpipe = ->
    debug "unpipe"
    src.unpipe dest
    return
  src = this
  state = @_readableState
  switch state.pipesCount
    when 0
      state.pipes = dest
    when 1
      state.pipes = [
        state.pipes
        dest
      ]
    else
      state.pipes.push dest
  state.pipesCount += 1
  debug "pipe count=%d opts=%j", state.pipesCount, pipeOpts
  doEnd = (not pipeOpts or pipeOpts.end isnt false) and dest isnt process.stdout and dest isnt process.stderr
  endFn = (if doEnd then onend else cleanup)
  if state.endEmitted
    process.nextTick endFn
  else
    src.once "end", endFn
  dest.on "unpipe", onunpipe
  ondrain = pipeOnDrain(src)
  dest.on "drain", ondrain
  src.on "data", ondata
  if not dest._events or not dest._events.error
    dest.on "error", onerror
  else if Array.isArray(dest._events.error)
    dest._events.error.unshift onerror
  else
    dest._events.error = [
      onerror
      dest._events.error
    ]
  dest.once "close", onclose
  dest.once "finish", onfinish
  dest.emit "pipe", src
  unless state.flowing
    debug "pipe resume"
    src.resume()
  dest

Readable::unpipe = (dest) ->
  state = @_readableState
  return this  if state.pipesCount is 0
  if state.pipesCount is 1
    return this  if dest and dest isnt state.pipes
    dest = state.pipes  unless dest
    state.pipes = null
    state.pipesCount = 0
    state.flowing = false
    dest.emit "unpipe", this  if dest
    return this
  unless dest
    dests = state.pipes
    len = state.pipesCount
    state.pipes = null
    state.pipesCount = 0
    state.flowing = false
    i = 0

    while i < len
      dests[i].emit "unpipe", this
      i++
    return this
  i = state.pipes.indexOf(dest)
  return this  if i is -1
  state.pipes.splice i, 1
  state.pipesCount -= 1
  state.pipes = state.pipes[0]  if state.pipesCount is 1
  dest.emit "unpipe", this
  this

Readable::on = (ev, fn) ->
  res = Stream::on.call(this, ev, fn)
  @resume()  if ev is "data" and false isnt @_readableState.flowing
  if ev is "readable" and @readable
    state = @_readableState
    unless state.readableListening
      state.readableListening = true
      state.emittedReadable = false
      state.needReadable = true
      unless state.reading
        self = this
        process.nextTick ->
          debug "readable nexttick read 0"
          self.read 0
          return

      else emitReadable this, state  if state.length
  res

Readable::addListener = Readable::on
Readable::resume = ->
  state = @_readableState
  unless state.flowing
    debug "resume"
    state.flowing = true
    resume this, state
  this

Readable::pause = ->
  debug "call pause flowing=%j", @_readableState.flowing
  if false isnt @_readableState.flowing
    debug "pause"
    @_readableState.flowing = false
    @emit "pause"
  this

Readable::wrap = (stream) ->
  state = @_readableState
  paused = false
  self = this
  stream.on "end", ->
    debug "wrapped end"
    if state.decoder and not state.ended
      chunk = state.decoder.end()
      self.push chunk  if chunk and chunk.length
    self.push null
    return

  stream.on "data", (chunk) ->
    debug "wrapped data"
    chunk = state.decoder.write(chunk)  if state.decoder
    if state.objectMode and (chunk is null or chunk is `undefined`)
      return
    else return  if not state.objectMode and (not chunk or not chunk.length)
    ret = self.push(chunk)
    unless ret
      paused = true
      stream.pause()
    return

  for i of stream
    if util.isFunction(stream[i]) and util.isUndefined(this[i])
      this[i] = (method) ->
        ->
          stream[method].apply stream, arguments
      (i)
  events = [
    "error"
    "close"
    "destroy"
    "pause"
    "resume"
  ]
  events.forEach (ev) ->
    stream.on ev, self.emit.bind(self, ev)
    return

  self._read = (n) ->
    debug "wrapped _read", n
    if paused
      paused = false
      stream.resume()
    return

  self

Readable._fromList = fromList
