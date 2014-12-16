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
SlabBuffer = ->
  @create()
  return

# Base class of both CleartextStream and EncryptedStream
CryptoStream = (pair, options) ->
  stream.Duplex.call this, options
  @pair = pair
  @_pending = null
  @_pendingEncoding = ""
  @_pendingCallback = null
  @_doneFlag = false
  @_retryAfterPartial = false
  @_halfRead = false
  @_sslOutCb = null
  @_resumingSession = false
  @_reading = true
  @_destroyed = false
  @_ended = false
  @_finished = false
  @_opposite = null
  slabBuffer = new SlabBuffer()  if util.isNull(slabBuffer)
  @_buffer = slabBuffer
  @once "finish", onCryptoStreamFinish
  
  # net.Socket calls .onend too
  @once "end", onCryptoStreamEnd
  return
onCryptoStreamFinish = ->
  @_finished = true
  if this is @pair.cleartext
    debug "cleartext.onfinish"
    if @pair.ssl
      
      # Generate close notify
      # NOTE: first call checks if client has sent us shutdown,
      # second call enqueues shutdown into the BIO.
      if @pair.ssl.shutdown() isnt 1
        return @pair.error()  if @pair.ssl and @pair.ssl.error
        @pair.ssl.shutdown()
      return @pair.error()  if @pair.ssl and @pair.ssl.error
  else
    debug "encrypted.onfinish"
  
  # Try to read just to get sure that we won't miss EOF
  @_opposite.read 0  if @_opposite.readable
  if @_opposite._ended
    @_done()
    
    # No half-close, sorry
    @_opposite._done()  if this is @pair.cleartext
  return
onCryptoStreamEnd = ->
  @_ended = true
  if this is @pair.cleartext
    debug "cleartext.onend"
  else
    debug "encrypted.onend"
  return

# NOTE: Called once `this._opposite` is set.

# Black-hole data

# When resuming session don't accept any new data.
# And do not put too much data into openssl, before writing it from encrypted
# side.
#
# TODO(indutny): Remove magic number, use watermark based limits

# Write current buffer now

# Handle and report errors

# Force SSL_read call to cycle some states/data inside OpenSSL

# Cycle encrypted data

# Get NPN and Server name when ready

# Whole buffer was written

# Invoke callback only when all data read from opposite stream

# Force SSL_read call to cycle some states/data inside OpenSSL

# No write has happened

# XXX: EOF?!

# Wait for session to be resumed
# Mark that we're done reading, but don't provide data or EOF

# Handle and report errors

# Get NPN and Server name when ready

# Create new buffer if previous was filled up

# Try writing pending data

# EOF when cleartext has finished and we have nothing to read

# Perform graceful shutdown

# No half-open, sorry!

# EOF

# EOF

# Bail out

# Give them requested data

# Let users know that we've some internal data to read

# Smart check to avoid invoking 'sslOutEnd' in the most of the cases

# Notify listeners about internal data end

# Write pending data first

# Wait for both `finish` and `end` events to ensure that all data that
# was written on this side was read from the other side.

# Destroy both ends

# Force EOF

# Emit 'close' event

# If both streams are done:

# readyState is deprecated. Don't use it.
CleartextStream = (pair, options) ->
  CryptoStream.call this, pair, options
  
  # This is a fake kludge to support how the http impl sits
  # on top of net Sockets
  self = this
  @_handle =
    readStop: ->
      self._reading = false
      return

    readStart: ->
      return  if self._reading and self._readableState.length > 0
      self._reading = true
      self.read 0
      self._opposite.read 0  if self._opposite.readable
      return

  return
EncryptedStream = (pair, options) ->
  CryptoStream.call this, pair, options
  return
onhandshakestart = ->
  debug "onhandshakestart"
  self = this
  ssl = self.ssl
  now = Timer.now()
  assert now >= ssl.lastHandshakeTime
  ssl.handshakes = 0  if (now - ssl.lastHandshakeTime) >= tls.CLIENT_RENEG_WINDOW * 1000
  first = (ssl.lastHandshakeTime is 0)
  ssl.lastHandshakeTime = now
  return  if first
  if ++ssl.handshakes > tls.CLIENT_RENEG_LIMIT
    
    # Defer the error event to the next tick. We're being called from OpenSSL's
    # state machine and OpenSSL is not re-entrant. We cannot allow the user's
    # callback to destroy the connection right now, it would crash and burn.
    setImmediate ->
      err = new Error("TLS session renegotiation attack detected.")
      self.cleartext.emit "error", err  if self.cleartext
      return

  return
onhandshakedone = ->
  
  # for future use
  debug "onhandshakedone"
  return
onclienthello = (hello) ->
  callback = (err, session) ->
    return  if once
    once = true
    return self.socket.destroy(err)  if err
    self.ssl.loadSession session
    self.ssl.endParser()
    
    # Cycle data
    self._resumingSession = false
    self.cleartext.read 0
    self.encrypted.read 0
    return
  self = this
  once = false
  @_resumingSession = true
  callback null, null  if hello.sessionId.length <= 0 or not @server or not @server.emit("resumeSession", hello.sessionId, callback)
  return
onnewsession = (key, session) ->
  done = ->
    return  if once
    once = true
    self.ssl.newSessionDone()  if self.ssl
    return
  return  unless @server
  self = this
  once = false
  done()  unless self.server.emit("newSession", key, session, done)
  return
onocspresponse = (resp) ->
  @emit "OCSPResponse", resp
  return

###*
Provides a pair of streams to do encrypted communication.
###
SecurePair = (context, isServer, requestCert, rejectUnauthorized, options) ->
  return new SecurePair(context, isServer, requestCert, rejectUnauthorized, options)  unless this instanceof SecurePair
  self = this
  options or (options = {})
  events.EventEmitter.call this
  @server = options.server
  @_secureEstablished = false
  @_isServer = (if isServer then true else false)
  @_encWriteState = true
  @_clearWriteState = true
  @_doneFlag = false
  @_destroying = false
  unless context
    @credentials = tls.createSecureContext()
  else
    @credentials = context
  
  # For clients, we will always have either a given ca list or be using
  # default one
  requestCert = true  unless @_isServer
  @_rejectUnauthorized = (if rejectUnauthorized then true else false)
  @_requestCert = (if requestCert then true else false)
  @ssl = new Connection(@credentials.context, (if @_isServer then true else false), (if @_isServer then @_requestCert else options.servername), @_rejectUnauthorized)
  if @_isServer
    @ssl.onhandshakestart = onhandshakestart.bind(this)
    @ssl.onhandshakedone = onhandshakedone.bind(this)
    @ssl.onclienthello = onclienthello.bind(this)
    @ssl.onnewsession = onnewsession.bind(this)
    @ssl.lastHandshakeTime = 0
    @ssl.handshakes = 0
  else
    @ssl.onocspresponse = onocspresponse.bind(this)
  if process.features.tls_sni
    @ssl.setSNICallback options.SNICallback  if @_isServer and options.SNICallback
    @servername = null
  if process.features.tls_npn and options.NPNProtocols
    @ssl.setNPNProtocols options.NPNProtocols
    @npnProtocol = null
  
  # Acts as a r/w stream to the cleartext side of the stream. 
  @cleartext = new CleartextStream(this, options.cleartext)
  
  # Acts as a r/w stream to the encrypted side of the stream. 
  @encrypted = new EncryptedStream(this, options.encrypted)
  
  # Let streams know about each other 
  @cleartext._opposite = @encrypted
  @encrypted._opposite = @cleartext
  @cleartext.init()
  @encrypted.init()
  process.nextTick ->
    
    # The Connection may be destroyed by an abort call 
    if self.ssl
      self.ssl.start()
      self.ssl.requestOCSP()  if options.requestOCSP
      
      # In case of cipher suite failures - SSL_accept/SSL_connect may fail 
      self.error()  if self.ssl and self.ssl.error
    return

  return
"use strict"
assert = require("assert")
events = require("events")
stream = require("stream")
tls = require("tls")
util = require("util")
common = require("_tls_common")
Timer = process.binding("timer_wrap").Timer
Connection = null
try
  Connection = process.binding("crypto").Connection
catch e
  throw new Error("node.js not compiled with openssl crypto support.")
debug = util.debuglog("tls-legacy")
SlabBuffer::create = create = ->
  @isFull = false
  @pool = new Buffer(tls.SLAB_BUFFER_SIZE)
  @offset = 0
  @remaining = @pool.length
  return

SlabBuffer::use = use = (context, fn, size) ->
  if @remaining is 0
    @isFull = true
    return 0
  actualSize = @remaining
  actualSize = Math.min(size, actualSize)  unless util.isNull(size)
  bytes = fn.call(context, @pool, @offset, actualSize)
  if bytes > 0
    @offset += bytes
    @remaining -= bytes
  assert @remaining >= 0
  bytes

slabBuffer = null
util.inherits CryptoStream, stream.Duplex
CryptoStream::init = init = ->
  self = this
  @_opposite.on "sslOutEnd", ->
    if self._sslOutCb
      cb = self._sslOutCb
      self._sslOutCb = null
      cb null
    return

  return

CryptoStream::_write = write = (data, encoding, cb) ->
  assert util.isNull(@_pending)
  return cb(null)  unless @pair.ssl
  if not @_resumingSession and @_opposite._internallyPendingBytes() < 128 * 1024
    written = undefined
    if this is @pair.cleartext
      debug "cleartext.write called with %d bytes", data.length
      written = @pair.ssl.clearIn(data, 0, data.length)
    else
      debug "encrypted.write called with %d bytes", data.length
      written = @pair.ssl.encIn(data, 0, data.length)
    return cb(@pair.error(true))  if @pair.ssl and @pair.ssl.error
    @pair.cleartext.read 0
    @pair.encrypted.read 0  if @pair.encrypted._internallyPendingBytes()
    @pair.maybeInitFinished()
    if written is data.length
      if this is @pair.cleartext
        debug "cleartext.write succeed with " + written + " bytes"
      else
        debug "encrypted.write succeed with " + written + " bytes"
      if @_opposite._halfRead
        assert util.isNull(@_sslOutCb)
        @_sslOutCb = cb
      else
        cb null
      return
    else if written isnt 0 and written isnt -1
      assert not @_retryAfterPartial
      @_retryAfterPartial = true
      @_write data.slice(written), encoding, cb
      @_retryAfterPartial = false
      return
  else
    debug "cleartext.write queue is full"
    @pair.cleartext.read 0
  @_pending = data
  @_pendingEncoding = encoding
  @_pendingCallback = cb
  if this is @pair.cleartext
    debug "cleartext.write queued with %d bytes", data.length
  else
    debug "encrypted.write queued with %d bytes", data.length
  return

CryptoStream::_writePending = writePending = ->
  data = @_pending
  encoding = @_pendingEncoding
  cb = @_pendingCallback
  @_pending = null
  @_pendingEncoding = ""
  @_pendingCallback = null
  @_write data, encoding, cb
  return

CryptoStream::_read = read = (size) ->
  return @push(null)  unless @pair.ssl
  return @push("")  if @_resumingSession or not @_reading
  out = undefined
  if this is @pair.cleartext
    debug "cleartext.read called with %d bytes", size
    out = @pair.ssl.clearOut
  else
    debug "encrypted.read called with %d bytes", size
    out = @pair.ssl.encOut
  bytesRead = 0
  start = @_buffer.offset
  last = start
  loop
    assert last is @_buffer.offset
    read = @_buffer.use(@pair.ssl, out, size - bytesRead)
    bytesRead += read  if read > 0
    last = @_buffer.offset
    if @pair.ssl and @pair.ssl.error
      @pair.error()
      break
    break unless read > 0 and not @_buffer.isFull and bytesRead < size and @pair.ssl isnt null
  @pair.maybeInitFinished()
  pool = @_buffer.pool
  @_buffer.create()  if @_buffer.isFull
  assert bytesRead >= 0
  if this is @pair.cleartext
    debug "cleartext.read succeed with %d bytes", bytesRead
  else
    debug "encrypted.read succeed with %d bytes", bytesRead
  @_writePending()  unless util.isNull(@_pending)
  @_opposite._writePending()  unless util.isNull(@_opposite._pending)
  if bytesRead is 0
    if @_opposite._finished and @_internallyPendingBytes() is 0 or @pair.ssl and @pair.ssl.receivedShutdown
      @_done()
      if this is @pair.cleartext
        @_opposite._done()
        @push null
      else @push null  if not @pair.ssl or not @pair.ssl.receivedShutdown
    else
      @push ""
  else
    @push pool.slice(start, start + bytesRead)
  halfRead = @_internallyPendingBytes() isnt 0
  if @_halfRead isnt halfRead
    @_halfRead = halfRead
    unless halfRead
      if this is @pair.cleartext
        debug "cleartext.sslOutEnd"
      else
        debug "encrypted.sslOutEnd"
      @emit "sslOutEnd"
  return

CryptoStream::setTimeout = (timeout, callback) ->
  @socket.setTimeout timeout, callback  if @socket
  return

CryptoStream::setNoDelay = (noDelay) ->
  @socket.setNoDelay noDelay  if @socket
  return

CryptoStream::setKeepAlive = (enable, initialDelay) ->
  @socket.setKeepAlive enable, initialDelay  if @socket
  return

CryptoStream::__defineGetter__ "bytesWritten", ->
  (if @socket then @socket.bytesWritten else 0)

CryptoStream::getPeerCertificate = (detailed) ->
  return common.translatePeerCertificate(@pair.ssl.getPeerCertificate(detailed))  if @pair.ssl
  null

CryptoStream::getSession = ->
  return @pair.ssl.getSession()  if @pair.ssl
  null

CryptoStream::isSessionReused = ->
  return @pair.ssl.isSessionReused()  if @pair.ssl
  null

CryptoStream::getCipher = (err) ->
  if @pair.ssl
    @pair.ssl.getCurrentCipher()
  else
    null

CryptoStream::end = (chunk, encoding) ->
  if this is @pair.cleartext
    debug "cleartext.end"
  else
    debug "encrypted.end"
  @_writePending()  unless util.isNull(@_pending)
  @writable = false
  stream.Duplex::end.call this, chunk, encoding
  return

CryptoStream::destroySoon = (err) ->
  if this is @pair.cleartext
    debug "cleartext.destroySoon"
  else
    debug "encrypted.destroySoon"
  @end()  if @writable
  if @_writableState.finished and @_opposite._ended
    @destroy()
  else
    self = this
    waiting = 1
    finish = ->
      self.destroy()  if --waiting is 0
      return

    @_opposite.once "end", finish
    unless @_finished
      @once "finish", finish
      ++waiting
  return

CryptoStream::destroy = (err) ->
  return  if @_destroyed
  @_destroyed = true
  @readable = @writable = false
  if this is @pair.cleartext
    debug "cleartext.destroy"
  else
    debug "encrypted.destroy"
  @_opposite.destroy()
  self = this
  process.nextTick ->
    self.push null
    self.emit "close", (if err then true else false)
    return

  return

CryptoStream::_done = ->
  @_doneFlag = true
  return @pair.error()  if this is @pair.encrypted and not @pair._secureEstablished
  @pair.destroy()  if @pair.cleartext._doneFlag and @pair.encrypted._doneFlag and not @pair._doneFlag
  return

Object.defineProperty CryptoStream::, "readyState",
  get: ->
    if @_connecting
      "opening"
    else if @readable and @writable
      "open"
    else if @readable and not @writable
      "readOnly"
    else if not @readable and @writable
      "writeOnly"
    else
      "closed"

util.inherits CleartextStream, CryptoStream
CleartextStream::_internallyPendingBytes = ->
  if @pair.ssl
    @pair.ssl.clearPending()
  else
    0

CleartextStream::address = ->
  @socket and @socket.address()

CleartextStream::__defineGetter__ "remoteAddress", ->
  @socket and @socket.remoteAddress

CleartextStream::__defineGetter__ "remoteFamily", ->
  @socket and @socket.remoteFamily

CleartextStream::__defineGetter__ "remotePort", ->
  @socket and @socket.remotePort

CleartextStream::__defineGetter__ "localAddress", ->
  @socket and @socket.localAddress

CleartextStream::__defineGetter__ "localPort", ->
  @socket and @socket.localPort

util.inherits EncryptedStream, CryptoStream
EncryptedStream::_internallyPendingBytes = ->
  if @pair.ssl
    @pair.ssl.encPending()
  else
    0

util.inherits SecurePair, events.EventEmitter
exports.createSecurePair = (context, isServer, requestCert, rejectUnauthorized) ->
  pair = new SecurePair(context, isServer, requestCert, rejectUnauthorized)
  pair

SecurePair::maybeInitFinished = ->
  if @ssl and not @_secureEstablished and @ssl.isInitFinished()
    @npnProtocol = @ssl.getNegotiatedProtocol()  if process.features.tls_npn
    @servername = @ssl.getServername()  if process.features.tls_sni
    @_secureEstablished = true
    debug "secure established"
    @emit "secure"
  return

SecurePair::destroy = ->
  return  if @_destroying
  unless @_doneFlag
    debug "SecurePair.destroy"
    @_destroying = true
    
    # SecurePair should be destroyed only after it's streams
    @cleartext.destroy()
    @encrypted.destroy()
    @_doneFlag = true
    @ssl.error = null
    @ssl.close()
    @ssl = null
  return

SecurePair::error = (returnOnly) ->
  err = @ssl.error
  @ssl.error = null
  unless @_secureEstablished
    
    # Emit ECONNRESET instead of zero return
    if not err or err.message is "ZERO_RETURN"
      connReset = new Error("socket hang up")
      connReset.code = "ECONNRESET"
      connReset.sslError = err and err.message
      err = connReset
    @destroy()
    @emit "error", err  unless returnOnly
  else if @_isServer and @_rejectUnauthorized and /peer did not return a certificate/.test(err.message)
    
    # Not really an error.
    @destroy()
  else
    @cleartext.emit "error", err  unless returnOnly
  err

exports.pipe = pipe = (pair, socket) ->
  
  # Encrypted should be unpiped from socket to prevent possible
  # write after destroy.
  
  # cycle the data whenever the socket drains, so that
  # we can pull some more into it.  normally this would
  # be handled by the fact that pipe() triggers read() calls
  # on writable.drain, but CryptoStreams are a bit more
  # complicated.  Since the encrypted side actually gets
  # its data from the cleartext side, we have to give it a
  # light kick to get in motion again.
  onerror = (e) ->
    cleartext.emit "error", e  if cleartext._controlReleased
    return
  onclose = ->
    socket.removeListener "error", onerror
    socket.removeListener "timeout", ontimeout
    return
  ontimeout = ->
    cleartext.emit "timeout"
    return
  pair.encrypted.pipe socket
  socket.pipe pair.encrypted
  pair.encrypted.on "close", ->
    process.nextTick ->
      pair.encrypted.unpipe socket
      socket.destroySoon()
      return

    return

  pair.fd = socket.fd
  cleartext = pair.cleartext
  cleartext.socket = socket
  cleartext.encrypted = pair.encrypted
  cleartext.authorized = false
  socket.on "drain", ->
    pair.encrypted._writePending()  if pair.encrypted._pending
    pair.cleartext._writePending()  if pair.cleartext._pending
    pair.encrypted.read 0
    pair.cleartext.read 0
    return

  socket.on "error", onerror
  socket.on "close", onclose
  socket.on "timeout", ontimeout
  cleartext
