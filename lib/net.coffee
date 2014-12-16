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
noop = ->

# constructor for lazy loading
createPipe = ->
  new Pipe()

# constructor for lazy loading
createTCP = ->
  TCP = process.binding("tcp_wrap").TCP
  new TCP()
createHandle = (fd) ->
  tty = process.binding("tty_wrap")
  type = tty.guessHandleType(fd)
  return createPipe()  if type is "PIPE"
  return createTCP()  if type is "TCP"
  throw new TypeError("Unsupported fd type: " + type)return
isPipeName = (s) ->
  util.isString(s) and toNumber(s) is false

# format exceptions
detailedException = (err, syscall, address, port, additional) ->
  details = undefined
  if port and port > 0
    details = address + ":" + port
  else
    details = address
  details += " - Local (" + additional + ")"  if additional
  ex = errnoException(err, syscall, details)
  ex.address = address
  ex.port = port  if port
  ex

# Target API:
#
# var s = net.connect({port: 80, host: 'google.com'}, function() {
#   ...
# });
#
# There are various forms:
#
# connect(options, [cb])
# connect(port, [host], [cb])
# connect(path, [cb]);
#

# Returns an array [options] or [options, cb]
# It is the same as the argument of Socket.prototype.connect().
normalizeConnectArgs = (args) ->
  options = {}
  if util.isObject(args[0])
    
    # connect(options, [cb])
    options = args[0]
  else if isPipeName(args[0])
    
    # connect(path, [cb]);
    options.path = args[0]
  else
    
    # connect(port, [host], [cb])
    options.port = args[0]
    options.host = args[1]  if util.isString(args[1])
  cb = args[args.length - 1]
  (if util.isFunction(cb) then [
    options
    cb
  ] else [options])

# called when creating new Socket, or when re-using a closed Socket
initSocketHandle = (self) ->
  self.destroyed = false
  self.bytesRead = 0
  self._bytesDispatched = 0
  
  # Handle creation may be deferred to bind() or connect() time.
  if self._handle
    self._handle.owner = self
    self._handle.onread = onread
    
    # If handle doesn't support writev - neither do we
    self._writev = null  unless self._handle.writev
  return
Socket = (options) ->
  return new Socket(options)  unless this instanceof Socket
  @_connecting = false
  @_hadError = false
  @_handle = null
  @_host = null
  if util.isNumber(options)
    options = fd: options # Legacy interface.
  else options = {}  if util.isUndefined(options)
  stream.Duplex.call this, options
  if options.handle
    @_handle = options.handle # private
  else unless util.isUndefined(options.fd)
    @_handle = createHandle(options.fd)
    @_handle.open options.fd
    if (options.fd is 1 or options.fd is 2) and (@_handle instanceof Pipe) and process.platform is "win32"
      
      # Make stdout and stderr blocking on Windows
      err = @_handle.setBlocking(true)
      throw errnoException(err, "setBlocking")  if err
    @readable = options.readable isnt false
    @writable = options.writable isnt false
  else
    
    # these will be set once there is a connection
    @readable = @writable = false
  
  # shut down the socket when we're finished with it.
  @on "finish", onSocketFinish
  @on "_socketEnd", onSocketEnd
  initSocketHandle this
  @_pendingData = null
  @_pendingEncoding = ""
  
  # handle strings directly
  @_writableState.decodeStrings = false
  
  # default to *not* allowing half open sockets
  @allowHalfOpen = options and options.allowHalfOpen or false
  
  # if we have a handle, then start the flow of data into the
  # buffer.  if not, then this will happen when we connect
  if @_handle and options.readable isnt false
    if options.pauseOnCreate
      
      # stop the handle from reading and pause the stream
      @_handle.reading = false
      @_handle.readStop()
      @_readableState.flowing = false
    else
      @read 0
  return

# the user has called .end(), and all the bytes have been
# sent out to the other side.
# If allowHalfOpen is false, or if the readable side has
# ended already, then destroy.
# If allowHalfOpen is true, then we need to do a shutdown,
# so that only the writable side will be cleaned up.
onSocketFinish = ->
  
  # If still connecting - defer handling 'finish' until 'connect' will happen
  if @_connecting
    debug "osF: not yet connected"
    return @once("connect", onSocketFinish)
  debug "onSocketFinish"
  if not @readable or @_readableState.ended
    debug "oSF: ended, destroy", @_readableState
    return @destroy()
  debug "oSF: not ended, call shutdown()"
  
  # otherwise, just shutdown, or destroy() if not possible
  return @destroy()  if not @_handle or not @_handle.shutdown
  req = new ShutdownWrap()
  req.oncomplete = afterShutdown
  err = @_handle.shutdown(req)
  @_destroy errnoException(err, "shutdown")  if err
afterShutdown = (status, handle, req) ->
  self = handle.owner
  debug "afterShutdown destroyed=%j", self.destroyed, self._readableState
  
  # callback may come after call to destroy.
  return  if self.destroyed
  if self._readableState.ended
    debug "readableState ended, destroying"
    self.destroy()
  else
    self.once "_socketEnd", self.destroy
  return

# the EOF has been received, and no more bytes are coming.
# if the writable side has ended already, then clean everything
# up.
onSocketEnd = ->
  
  # XXX Should not have to do as much crap in this function.
  # ended should already be true, since this is called *after*
  # the EOF errno and onread has eof'ed
  debug "onSocketEnd", @_readableState
  @_readableState.ended = true
  if @_readableState.endEmitted
    @readable = false
    maybeDestroy this
  else
    @once "end", ->
      @readable = false
      maybeDestroy this
      return

    @read 0
  unless @allowHalfOpen
    @write = writeAfterFIN
    @destroySoon()
  return

# Provide a better error message when we call end() as a result
# of the other side sending a FIN.  The standard 'write after end'
# is overly vague, and makes it seem like the user's code is to blame.
writeAfterFIN = (chunk, encoding, cb) ->
  if util.isFunction(encoding)
    cb = encoding
    encoding = null
  er = new Error("This socket has been ended by the other party")
  er.code = "EPIPE"
  self = this
  
  # TODO: defer error events consistently everywhere, not just the cb
  self.emit "error", er
  if util.isFunction(cb)
    process.nextTick ->
      cb er
      return

  return
# Legacy naming.

# backwards compatibility: assume true when `enable` is omitted

# Just call handle.readStart until we have enough in the buffer

# not already reading, start the flow

# just in case we're waiting for an EOF.

# Call whenever we set writable=false or readable=false
maybeDestroy = (socket) ->
  socket.destroy()  if not socket.readable and not socket.writable and not socket.destroyed and not socket._connecting and not socket._writableState.length
  return

# we set destroyed to true before firing error callbacks in order
# to make it re-entrance safe in case Socket.prototype.destroy()
# is called within callbacks

# This function is called whenever the handle gets a
# buffer, or when there's an error reading.
onread = (nread, buffer) ->
  handle = this
  self = handle.owner
  assert handle is self._handle, "handle != self._handle"
  timers._unrefActive self
  debug "onread", nread
  if nread > 0
    debug "got data"
    
    # read success.
    # In theory (and in practice) calling readStop right now
    # will prevent this from being called again until _read() gets
    # called again.
    
    # if it's not enough data, we'll just call handle.readStart()
    # again right away.
    self.bytesRead += nread
    
    # Optimization: emit the original buffer with end points
    ret = self.push(buffer)
    if handle.reading and not ret
      handle.reading = false
      debug "readStop"
      err = handle.readStop()
      self._destroy errnoException(err, "read")  if err
    return
  
  # if we didn't get any bytes, that doesn't necessarily mean EOF.
  # wait for the next one.
  if nread is 0
    debug "not any data, keep waiting"
    return
  
  # Error, possibly EOF.
  return self._destroy(errnoException(nread, "read"))  if nread isnt uv.UV_EOF
  debug "EOF"
  if self._readableState.length is 0
    self.readable = false
    maybeDestroy self
  
  # push a null to signal the end of data.
  self.push null
  
  # internal end event so that we know that the actual socket
  # is no longer readable, and we can start the shutdown
  # procedure. No need to wait for all the data to be consumed.
  self.emit "_socketEnd"
  return
# FIXME(bnoordhuis) Throw?
# FIXME(bnoordhuis) Throw?

# If we are still connecting, then buffer this for later.
# The Writable logic will buffer up any more writes while
# waiting for this one to be done.

# Retain chunks
# Keep reference alive.

# If it was entirely flushed, we can write some more right now.
# However, if more is left in the queue, then wait until that clears.
createWriteReq = (req, handle, data, encoding) ->
  switch encoding
    when "binary"
      handle.writeBinaryString req, data
    when "buffer"
      handle.writeBuffer req, data
    when "utf8", "utf-8"
      handle.writeUtf8String req, data
    when "ascii"
      handle.writeAsciiString req, data
    when "ucs2", "ucs-2", "utf16le", "utf-16le"
      handle.writeUcs2String req, data
    else
      handle.writeBuffer req, new Buffer(data, encoding)
afterWrite = (status, handle, req, err) ->
  self = handle.owner
  debug "afterWrite", status  if self isnt process.stderr and self isnt process.stdout
  
  # callback may come after call to destroy.
  if self.destroyed
    debug "afterWrite destroyed"
    return
  if status < 0
    ex = detailedException(status, "write", req.address, req.port)
    debug "write failure", ex
    self._destroy ex, req.cb
    return
  timers._unrefActive self
  debug "afterWrite call cb"  if self isnt process.stderr and self isnt process.stdout
  req.cb.call self  if req.cb
  return
connect = (self, address, port, addressType, localAddress, localPort) ->
  
  # TODO return promise from Socket.prototype.connect which
  # wraps _connectReq.
  assert.ok self._connecting
  err = undefined
  if localAddress or localPort
    err = new TypeError("localAddress should be a valid IP: " + localAddress)  if localAddress and not exports.isIP(localAddress)
    err = new TypeError("localPort should be a number: " + localPort)  if localPort and not util.isNumber(localPort)
    bind = undefined
    switch addressType
      when 4
        localAddress = "0.0.0.0"  unless localAddress
        bind = self._handle.bind
      when 6
        localAddress = "::"  unless localAddress
        bind = self._handle.bind6
      else
        err = new TypeError("Invalid addressType: " + addressType)
    if err
      self._destroy err
      return
    debug "binding to localAddress: %s and localPort: %d", localAddress, localPort
    bind = bind.bind(self._handle)
    err = bind(localAddress, localPort)
    if err
      ex = detailedException(err, "bind", localAddress, localPort)
      self._destroy ex
      return
  if addressType is 6 or addressType is 4
    req = new TCPConnectWrap()
    req.oncomplete = afterConnect
    port = port | 0
    throw new RangeError("Port should be > 0 and < 65536")  if port <= 0 or port > 65535
    req.port = port
    req.address = address
    if addressType is 6
      err = self._handle.connect6(req, address, port)
    else err = self._handle.connect(req, address, port)  if addressType is 4
  else
    req = new PipeConnectWrap()
    req.address = address
    req.oncomplete = afterConnect
    err = self._handle.connect(req, address, afterConnect)
  if err
    self._getsockname()
    details = undefined
    if self._sockname
      ex.localAddress = self._sockname.address
      ex.localPort = self._sockname.port
      details = ex.localAddress + ":" + ex.localPort
    ex = detailedException(err, "connect", address, port, details)
    self._destroy ex
  return

# Old API:
# connect(port, [host], [cb])
# connect(path, [cb]);

# It's possible we were destroyed while looking this up.
# XXX it would be great if we could cancel the promise returned by
# the look up.

# net.createConnection() creates a net.Socket object and
# immediately calls net.Socket.connect() on it (that's us).
# There are no event listeners registered yet so defer the
# error event to the next tick.

# node_net.cc handles null host names graciously but user land
# expects remoteAddress to have a meaningful value
afterConnect = (status, handle, req, readable, writable) ->
  self = handle.owner
  
  # callback may come after call to destroy
  return  if self.destroyed
  assert handle is self._handle, "handle != self._handle"
  debug "afterConnect"
  assert.ok self._connecting
  self._connecting = false
  if status is 0
    self.readable = readable
    self.writable = writable
    timers._unrefActive self
    self.emit "connect"
    
    # start the first read, or get an immediate EOF.
    # this doesn't actually consume any bytes, because len=0.
    self.read 0  if readable and not self.isPaused()
  else
    self._connecting = false
    details = undefined
    if req.localAddress and req.localPort
      ex.localAddress = req.localAddress
      ex.localPort = req.localPort
      details = ex.localAddress + ":" + ex.localPort
    ex = detailedException(status, "connect", req.address, req.port, details)
    self._destroy ex
  return
Server = -> # [ options, ] listener
  return new Server(arguments[0], arguments[1])  unless this instanceof Server
  events.EventEmitter.call this
  self = this
  options = undefined
  if util.isFunction(arguments[0])
    options = {}
    self.on "connection", arguments[0]
  else
    options = arguments[0] or {}
    self.on "connection", arguments[1]  if util.isFunction(arguments[1])
  @_connections = 0
  Object.defineProperty this, "connections",
    get: util.deprecate(->
      return null  if self._usingSlaves
      self._connections
    , "connections property is deprecated. Use getConnections() method")
    set: util.deprecate((val) ->
      self._connections = val
    , "connections property is deprecated. Use getConnections() method")
    configurable: true
    enumerable: false

  @_handle = null
  @_usingSlaves = false
  @_slaves = []
  @allowHalfOpen = options.allowHalfOpen or false
  @pauseOnConnect = !!options.pauseOnConnect
  return
toNumber = (x) ->
  (if (x = Number(x)) >= 0 then x else false)
_listen = (handle, backlog) ->
  
  # Use a backlog of 512 entries. We pass 511 to the listen() call because
  # the kernel does: backlogsize = roundup_pow_of_two(backlogsize + 1);
  # which will thus give us a backlog of 512 entries.
  handle.listen backlog or 511

# assign handle in listen, and clean up if bind or listen fails

# Not a fd we can listen on.  This will trigger an error.

# Try binding to ipv6 first

# Fallback to ipv4

# If there is not yet a handle, we need to create one and bind.
# In the case of a server sent via IPC, we don't need to do this.

# generate connection key, this should be unique to the connection

# ensure handle hasn't closed
listen = (self, address, port, addressType, backlog, fd, exclusive) ->
  cb = (err, handle) ->
    
    # EADDRINUSE may not be reported until we call listen(). To complicate
    # matters, a failed bind() followed by listen() will implicitly bind to
    # a random port. Ergo, check that the socket is bound to the expected
    # port before calling listen().
    #
    # FIXME(bnoordhuis) Doesn't work for pipe handles, they don't have a
    # getsockname() method. Non-issue for now, the cluster module doesn't
    # really support pipes anyway.
    if err is 0 and port > 0 and handle.getsockname
      out = {}
      err = handle.getsockname(out)
      err = uv.UV_EADDRINUSE  if err is 0 and port isnt out.port
    if err
      ex = detailedException(err, "bind", address, port)
      return self.emit("error", ex)
    self._handle = handle
    self._listen2 address, port, addressType, backlog, fd
    return
  exclusive = !!exclusive
  cluster = require("cluster")  unless cluster
  if cluster.isMaster or exclusive
    self._listen2 address, port, addressType, backlog, fd
    return
  cluster._getServer self, address, port, addressType, fd, cb
  return

# The third optional argument is the backlog size.
# When the ip is omitted it can be the second argument.

# Bind to a random port.

# The first argument is a configuration object

# UNIX socket or Windows pipe.

# The first argument is the port, no IP given.

# The first argument is the port, the second an IP.

# TODO(bnoordhuis) Check err and throw?
onconnection = (err, clientHandle) ->
  handle = this
  self = handle.owner
  debug "onconnection"
  if err
    self.emit "error", errnoException(err, "accept")
    return
  if self.maxConnections and self._connections >= self.maxConnections
    clientHandle.close()
    return
  socket = new Socket(
    handle: clientHandle
    allowHalfOpen: self.allowHalfOpen
    pauseOnCreate: self.pauseOnConnect
  )
  socket.readable = socket.writable = true
  self._connections++
  socket.server = self
  DTRACE_NET_SERVER_CONNECTION socket
  COUNTER_NET_SERVER_CONNECTION socket
  self.emit "connection", socket
  return
"use strict"
events = require("events")
stream = require("stream")
timers = require("timers")
util = require("util")
assert = require("assert")
cares = process.binding("cares_wrap")
uv = process.binding("uv")
Pipe = process.binding("pipe_wrap").Pipe
TCPConnectWrap = process.binding("tcp_wrap").TCPConnectWrap
PipeConnectWrap = process.binding("pipe_wrap").PipeConnectWrap
ShutdownWrap = process.binding("stream_wrap").ShutdownWrap
WriteWrap = process.binding("stream_wrap").WriteWrap
cluster = undefined
errnoException = util._errnoException
debug = util.debuglog("net")
exports.createServer = ->
  new Server(arguments[0], arguments[1])

exports.connect = exports.createConnection = ->
  args = normalizeConnectArgs(arguments)
  debug "createConnection", args
  s = new Socket(args[0])
  Socket::connect.apply s, args

exports._normalizeConnectArgs = normalizeConnectArgs
util.inherits Socket, stream.Duplex
exports.Socket = Socket
exports.Stream = Socket
Socket::read = (n) ->
  return stream.Readable::read.call(this, n)  if n is 0
  @read = stream.Readable::read
  @_consuming = true
  @read n

Socket::listen = ->
  debug "socket.listen"
  self = this
  self.on "connection", arguments[0]
  listen self, null, null, null
  return

Socket::setTimeout = (msecs, callback) ->
  if msecs > 0 and isFinite(msecs)
    timers.enroll this, msecs
    timers._unrefActive this
    @once "timeout", callback  if callback
  else if msecs is 0
    timers.unenroll this
    @removeListener "timeout", callback  if callback
  return

Socket::_onTimeout = ->
  debug "_onTimeout"
  @emit "timeout"
  return

Socket::setNoDelay = (enable) ->
  @_handle.setNoDelay (if util.isUndefined(enable) then true else !!enable)  if @_handle and @_handle.setNoDelay
  return

Socket::setKeepAlive = (setting, msecs) ->
  @_handle.setKeepAlive setting, ~~(msecs / 1000)  if @_handle and @_handle.setKeepAlive
  return

Socket::address = ->
  @_getsockname()

Object.defineProperty Socket::, "readyState",
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

Object.defineProperty Socket::, "bufferSize",
  get: ->
    @_handle.writeQueueSize + @_writableState.length  if @_handle

Socket::_read = (n) ->
  debug "_read"
  if @_connecting or not @_handle
    debug "_read wait for connection"
    @once "connect", @_read.bind(this, n)
  else unless @_handle.reading
    debug "Socket._read readStart"
    @_handle.reading = true
    err = @_handle.readStart()
    @_destroy errnoException(err, "read")  if err
  return

Socket::end = (data, encoding) ->
  stream.Duplex::end.call this, data, encoding
  @writable = false
  DTRACE_NET_STREAM_END this
  if @readable and not @_readableState.endEmitted
    @read 0
  else
    maybeDestroy this
  return

Socket::destroySoon = ->
  @end()  if @writable
  if @_writableState.finished
    @destroy()
  else
    @once "finish", @destroy
  return

Socket::_destroy = (exception, cb) ->
  fireErrorCallbacks = ->
    cb exception  if cb
    if exception and not self._writableState.errorEmitted
      process.nextTick ->
        self.emit "error", exception
        return

      self._writableState.errorEmitted = true
    return
  debug "destroy"
  self = this
  if @destroyed
    debug "already destroyed, fire error callbacks"
    fireErrorCallbacks()
    return
  self._connecting = false
  @readable = @writable = false
  timers.unenroll this
  debug "close"
  if @_handle
    debug "close handle"  if this isnt process.stderr
    isException = (if exception then true else false)
    @_handle.close ->
      debug "emit close"
      self.emit "close", isException
      return

    @_handle.onread = noop
    @_handle = null
  @destroyed = true
  fireErrorCallbacks()
  if @server
    COUNTER_NET_SERVER_CONNECTION_CLOSE this
    debug "has server"
    @server._connections--
    @server._emitCloseIfDrained()  if @server._emitCloseIfDrained
  return

Socket::destroy = (exception) ->
  debug "destroy", exception
  @_destroy exception
  return

Socket::_getpeername = ->
  return {}  if not @_handle or not @_handle.getpeername
  unless @_peername
    out = {}
    err = @_handle.getpeername(out)
    return {}  if err
    @_peername = out
  @_peername

Socket::__defineGetter__ "remoteAddress", ->
  @_getpeername().address

Socket::__defineGetter__ "remoteFamily", ->
  @_getpeername().family

Socket::__defineGetter__ "remotePort", ->
  @_getpeername().port

Socket::_getsockname = ->
  return {}  if not @_handle or not @_handle.getsockname
  unless @_sockname
    out = {}
    err = @_handle.getsockname(out)
    return {}  if err
    @_sockname = out
  @_sockname

Socket::__defineGetter__ "localAddress", ->
  @_getsockname().address

Socket::__defineGetter__ "localPort", ->
  @_getsockname().port

Socket::write = (chunk, encoding, cb) ->
  throw new TypeError("invalid data")  if not util.isString(chunk) and not util.isBuffer(chunk)
  stream.Duplex::write.apply this, arguments

Socket::_writeGeneric = (writev, data, encoding, cb) ->
  if @_connecting
    @_pendingData = data
    @_pendingEncoding = encoding
    @once "connect", ->
      @_writeGeneric writev, data, encoding, cb
      return

    return
  @_pendingData = null
  @_pendingEncoding = ""
  timers._unrefActive this
  unless @_handle
    @_destroy new Error("This socket is closed."), cb
    return false
  req = new WriteWrap()
  req.oncomplete = afterWrite
  req.async = false
  err = undefined
  if writev
    chunks = new Array(data.length << 1)
    i = 0

    while i < data.length
      entry = data[i]
      chunk = entry.chunk
      enc = entry.encoding
      chunks[i * 2] = chunk
      chunks[i * 2 + 1] = enc
      i++
    err = @_handle.writev(req, chunks)
    req._chunks = chunks  if err is 0
  else
    enc = undefined
    if util.isBuffer(data)
      req.buffer = data
      enc = "buffer"
    else
      enc = encoding
    err = createWriteReq(req, @_handle, data, enc)
  return @_destroy(errnoException(err, "write", req.error), cb)  if err
  @_bytesDispatched += req.bytes
  if req.async and @_handle.writeQueueSize isnt 0
    req.cb = cb
  else
    cb()
  return

Socket::_writev = (chunks, cb) ->
  @_writeGeneric true, chunks, "", cb
  return

Socket::_write = (data, encoding, cb) ->
  @_writeGeneric false, data, encoding, cb
  return

Socket::__defineGetter__ "bytesWritten", ->
  bytes = @_bytesDispatched
  state = @_writableState
  data = @_pendingData
  encoding = @_pendingEncoding
  state.buffer.forEach (el) ->
    if util.isBuffer(el.chunk)
      bytes += el.chunk.length
    else
      bytes += Buffer.byteLength(el.chunk, el.encoding)
    return

  if data
    if util.isBuffer(data)
      bytes += data.length
    else
      bytes += Buffer.byteLength(data, encoding)
  bytes

Socket::connect = (options, cb) ->
  @write = Socket::write  if @write isnt Socket::write
  unless util.isObject(options)
    args = normalizeConnectArgs(arguments)
    return Socket::connect.apply(this, args)
  if @destroyed
    @_readableState.reading = false
    @_readableState.ended = false
    @_readableState.endEmitted = false
    @_writableState.ended = false
    @_writableState.ending = false
    @_writableState.finished = false
    @_writableState.errorEmitted = false
    @destroyed = false
    @_handle = null
  self = this
  pipe = !!options.path
  debug "pipe", pipe, options.path
  unless @_handle
    @_handle = (if pipe then createPipe() else createTCP())
    initSocketHandle this
  self.once "connect", cb  if util.isFunction(cb)
  timers._unrefActive this
  self._connecting = true
  self.writable = true
  if pipe
    connect self, options.path
  else unless options.host
    debug "connect: missing host"
    self._host = "127.0.0.1"
    connect self, self._host, options.port, 4
  else
    dns = require("dns")
    host = options.host
    dnsopts =
      family: options.family
      hints: 0

    dnsopts.hints = dns.ADDRCONFIG | dns.V4MAPPED  if dnsopts.family isnt 4 and dnsopts.family isnt 6
    debug "connect: find host " + host
    debug "connect: dns options " + dnsopts
    self._host = host
    dns.lookup host, dnsopts, (err, ip, addressType) ->
      self.emit "lookup", err, ip, addressType
      return  unless self._connecting
      if err
        process.nextTick ->
          err.host = options.host
          err.port = options.port
          err.message = err.message + " " + options.host + ":" + options.port
          self.emit "error", err
          self._destroy()
          return

      else
        timers._unrefActive self
        addressType = addressType or 4
        ip = ip or ((if addressType is 4 then "127.0.0.1" else "0:0:0:0:0:0:0:1"))
        connect self, ip, options.port, addressType, options.localAddress, options.localPort
      return

  self

Socket::ref = ->
  @_handle.ref()  if @_handle
  return

Socket::unref = ->
  @_handle.unref()  if @_handle
  return

util.inherits Server, events.EventEmitter
exports.Server = Server
createServerHandle = exports._createServerHandle = (address, port, addressType, fd) ->
  err = 0
  handle = undefined
  isTCP = false
  if util.isNumber(fd) and fd >= 0
    try
      handle = createHandle(fd)
    catch e
      debug "listen invalid fd=" + fd + ": " + e.message
      return uv.UV_EINVAL
    handle.open fd
    handle.readable = true
    handle.writable = true
    assert not address and not port
  else if port is -1 and addressType is -1
    handle = createPipe()
    if process.platform is "win32"
      instances = parseInt(process.env.NODE_PENDING_PIPE_INSTANCES)
      handle.setPendingInstances instances  unless isNaN(instances)
  else
    handle = createTCP()
    isTCP = true
  if address or port or isTCP
    debug "bind to " + (address or "anycast")
    unless address
      err = handle.bind6("::", port)
      if err
        handle.close()
        return createServerHandle("0.0.0.0", port)
    else if addressType is 6
      err = handle.bind6(address, port)
    else
      err = handle.bind(address, port)
  if err
    handle.close()
    return err
  handle

Server::_listen2 = (address, port, addressType, backlog, fd) ->
  debug "listen2", address, port, addressType, backlog
  self = this
  unless self._handle
    debug "_listen2: create a handle"
    rval = createServerHandle(address, port, addressType, fd)
    if util.isNumber(rval)
      error = detailedException(rval, "listen", address, port)
      process.nextTick ->
        self.emit "error", error
        return

      return
    self._handle = rval
  else
    debug "_listen2: have a handle already"
  self._handle.onconnection = onconnection
  self._handle.owner = self
  err = _listen(self._handle, backlog)
  if err
    ex = detailedException(err, "listen", address, port)
    self._handle.close()
    self._handle = null
    process.nextTick ->
      self.emit "error", ex
      return

    return
  @_connectionKey = addressType + ":" + address + ":" + port
  process.nextTick ->
    self.emit "listening"  if self._handle
    return

  return

Server::listen = ->
  listenAfterLookup = (port, address, backlog, exclusive) ->
    require("dns").lookup address, (err, ip, addressType) ->
      if err
        self.emit "error", err
      else
        addressType = (if ip then addressType else 4)
        listen self, ip, port, addressType, backlog, `undefined`, exclusive
      return

    return
  self = this
  lastArg = arguments[arguments.length - 1]
  self.once "listening", lastArg  if util.isFunction(lastArg)
  port = toNumber(arguments[0])
  backlog = toNumber(arguments[1]) or toNumber(arguments[2])
  TCP = process.binding("tcp_wrap").TCP
  if arguments.length is 0 or util.isFunction(arguments[0])
    listen self, null, 0, null, backlog
  else if util.isObject(arguments[0])
    h = arguments[0]
    h = h._handle or h.handle or h
    if h instanceof TCP
      self._handle = h
      listen self, null, -1, -1, backlog
    else if util.isNumber(h.fd) and h.fd >= 0
      listen self, null, null, null, backlog, h.fd
    else
      backlog = h.backlog  if h.backlog
      if util.isNumber(h.port)
        if h.host
          listenAfterLookup h.port, h.host, backlog, h.exclusive
        else
          listen self, null, h.port, 4, backlog, `undefined`, h.exclusive
      else if h.path and isPipeName(h.path)
        pipeName = self._pipeName = h.path
        listen self, pipeName, -1, -1, backlog, `undefined`, h.exclusive
      else
        throw new Error("Invalid listen argument: " + h)
  else if isPipeName(arguments[0])
    pipeName = self._pipeName = arguments[0]
    listen self, pipeName, -1, -1, backlog
  else if util.isUndefined(arguments[1]) or util.isFunction(arguments[1]) or util.isNumber(arguments[1])
    listen self, null, port, 4, backlog
  else
    listenAfterLookup port, arguments[1], backlog
  self

Server::address = ->
  if @_handle and @_handle.getsockname
    out = {}
    err = @_handle.getsockname(out)
    out
  else if @_pipeName
    @_pipeName
  else
    null

Server::getConnections = (cb) ->
  end = (err, connections) ->
    process.nextTick ->
      cb err, connections
      return

    return
  
  # Poll slaves
  oncount = (err, count) ->
    if err
      left = -1
      return end(err)
    total += count
    end null, total  if --left is 0
  return end(null, @_connections)  unless @_usingSlaves
  left = @_slaves.length
  total = @_connections
  @_slaves.forEach (slave) ->
    slave.getConnections oncount
    return

  return

Server::close = (cb) ->
  onSlaveClose = ->
    return  if --left isnt 0
    self._connections = 0
    self._emitCloseIfDrained()
    return
  if cb
    unless @_handle
      @once "close", ->
        cb new Error("Not running")
        return

    else
      @once "close", cb
  if @_handle
    @_handle.close()
    @_handle = null
  if @_usingSlaves
    self = this
    left = @_slaves.length
    
    # Increment connections to be sure that, even if all sockets will be closed
    # during polling of slaves, `close` event will be emitted only once.
    @_connections++
    
    # Poll slaves
    @_slaves.forEach (slave) ->
      slave.close onSlaveClose
      return

  else
    @_emitCloseIfDrained()
  this

Server::_emitCloseIfDrained = ->
  debug "SERVER _emitCloseIfDrained"
  self = this
  if self._handle or self._connections
    debug "SERVER handle? %j   connections? %d", !!self._handle, self._connections
    return
  process.nextTick ->
    debug "SERVER: emit close"
    self.emit "close"
    return

  return

Server::listenFD = util.deprecate((fd, type) ->
  @listen fd: fd
, "listenFD is deprecated. Use listen({fd: <number>}).")
Server::_setupSlave = (socketList) ->
  @_usingSlaves = true
  @_slaves.push socketList
  return

Server::ref = ->
  @_handle.ref()  if @_handle
  return

Server::unref = ->
  @_handle.unref()  if @_handle
  return


# TODO: isIP should be moved to the DNS code. Putting it here now because
# this is what the legacy system did.
exports.isIP = cares.isIP
exports.isIPv4 = (input) ->
  exports.isIP(input) is 4

exports.isIPv6 = (input) ->
  exports.isIP(input) is 6

if process.platform is "win32"
  simultaneousAccepts = undefined
  exports._setSimultaneousAccepts = (handle) ->
    return  if util.isUndefined(handle)
    simultaneousAccepts = (process.env.NODE_MANY_ACCEPTS and process.env.NODE_MANY_ACCEPTS isnt "0")  if util.isUndefined(simultaneousAccepts)
    if handle._simultaneousAccepts isnt simultaneousAccepts
      handle.setSimultaneousAccepts simultaneousAccepts
      handle._simultaneousAccepts = simultaneousAccepts
    return
else
  exports._setSimultaneousAccepts = (handle) ->
