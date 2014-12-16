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
ClientRequest = (options, cb) ->
  self = this
  OutgoingMessage.call self
  if util.isString(options)
    options = url.parse(options)
  else
    options = util._extend({}, options)
  agent = options.agent
  defaultAgent = options._defaultAgent or Agent.globalAgent
  if agent is false
    agent = new defaultAgent.constructor()
  else agent = defaultAgent  if util.isNullOrUndefined(agent) and not options.createConnection
  self.agent = agent
  protocol = options.protocol or defaultAgent.protocol
  expectedProtocol = defaultAgent.protocol
  expectedProtocol = self.agent.protocol  if self.agent and self.agent.protocol
  if options.path and RegExp(" ").test(options.path)
    
    # The actual regex is more like /[^A-Za-z0-9\-._~!$&'()*+,;=/:@]/
    # with an additional rule for ignoring percentage-escaped characters
    # but that's a) hard to capture in a regular expression that performs
    # well, and b) possibly too restrictive for real-world usage. That's
    # why it only scans for spaces because those are guaranteed to create
    # an invalid request.
    throw new TypeError("Request path contains unescaped characters.")
  else throw new Error("Protocol \"" + protocol + "\" not supported. " + "Expected \"" + expectedProtocol + "\".")  if protocol isnt expectedProtocol
  defaultPort = options.defaultPort or self.agent and self.agent.defaultPort
  port = options.port = options.port or defaultPort or 80
  host = options.host = options.hostname or options.host or "localhost"
  setHost = true  if util.isUndefined(options.setHost)
  self.socketPath = options.socketPath
  method = self.method = (options.method or "GET").toUpperCase()
  self.path = options.path or "/"
  self.once "response", cb  if cb
  unless util.isArray(options.headers)
    if options.headers
      keys = Object.keys(options.headers)
      i = 0
      l = keys.length

      while i < l
        key = keys[i]
        self.setHeader key, options.headers[key]
        i++
    if host and not @getHeader("host") and setHost
      hostHeader = host
      hostHeader += ":" + port  if port and +port isnt defaultPort
      @setHeader "Host", hostHeader
  
  #basic auth
  @setHeader "Authorization", "Basic " + new Buffer(options.auth).toString("base64")  if options.auth and not @getHeader("Authorization")
  if method is "GET" or method is "HEAD" or method is "DELETE" or method is "OPTIONS" or method is "CONNECT"
    self.useChunkedEncodingByDefault = false
  else
    self.useChunkedEncodingByDefault = true
  if util.isArray(options.headers)
    self._storeHeader self.method + " " + self.path + " HTTP/1.1\r\n", options.headers
  else self._storeHeader self.method + " " + self.path + " HTTP/1.1\r\n", self._renderHeaders()  if self.getHeader("expect")
  if self.socketPath
    self._last = true
    self.shouldKeepAlive = false
    conn = self.agent.createConnection(path: self.socketPath)
    self.onSocket conn
  else if self.agent
    
    # If there is an agent we should default to Connection:keep-alive,
    # but only if the Agent will actually reuse the connection!
    # If it's not a keepAlive agent, and the maxSockets==Infinity, then
    # there's never a case where this socket will actually be reused
    if not self.agent.keepAlive and not Number.isFinite(self.agent.maxSockets)
      self._last = true
      self.shouldKeepAlive = false
    else
      self._last = false
      self.shouldKeepAlive = true
    self.agent.addRequest self, options
  else
    
    # No agent, default to Connection:close.
    self._last = true
    self.shouldKeepAlive = false
    if options.createConnection
      conn = options.createConnection(options)
    else
      debug "CLIENT use net.createConnection", options
      conn = net.createConnection(options)
    self.onSocket conn
  self._deferToConnect null, null, ->
    self._flush()
    self = null
    return

  return

# Mark as aborting so we can avoid sending queued request data
# This is used as a truthy flag elsewhere. The use of Date.now is for
# debugging purposes only.

# If we're aborting, we don't care about any more response data.

# In the event that we don't have a socket, we will pop out of
# the request queue through handling in onSocket.

# in-progress
createHangUpError = ->
  error = new Error("socket hang up")
  error.code = "ECONNRESET"
  error
socketCloseListener = ->
  socket = this
  req = socket._httpMessage
  debug "HTTP socket close"
  
  # Pull through final chunk, if anything is buffered.
  # the ondata function will handle it properly, and this
  # is a no-op if no final chunk remains.
  socket.read()
  
  # NOTE: Its important to get parser here, because it could be freed by
  # the `socketOnData`.
  parser = socket.parser
  req.emit "close"
  if req.res and req.res.readable
    
    # Socket closed before we emitted 'end' below.
    req.res.emit "aborted"
    res = req.res
    res.on "end", ->
      res.emit "close"
      return

    res.push null
  else if not req.res and not req.socket._hadError
    
    # This socket error fired before we started to
    # receive a response. The error needs to
    # fire on the request.
    req.emit "error", createHangUpError()
    req.socket._hadError = true
  
  # Too bad.  That output wasn't getting written.
  # This is pretty terrible that it doesn't raise an error.
  # Fixed better in v0.10
  req.output.length = 0  if req.output
  req.outputEncodings.length = 0  if req.outputEncodings
  if parser
    parser.finish()
    freeParser parser, req, socket
  return
socketErrorListener = (err) ->
  socket = this
  parser = socket.parser
  req = socket._httpMessage
  debug "SOCKET ERROR:", err.message, err.stack
  if req
    req.emit "error", err
    
    # For Safety. Some additional errors might fire later on
    # and we need to make sure we don't double-fire the error event.
    req.socket._hadError = true
  if parser
    parser.finish()
    freeParser parser, req, socket
  socket.destroy()
  return
socketOnEnd = ->
  socket = this
  req = @_httpMessage
  parser = @parser
  if not req.res and not req.socket._hadError
    
    # If we don't have a response then we know that the socket
    # ended prematurely and we need to emit an error on the request.
    req.emit "error", createHangUpError()
    req.socket._hadError = true
  if parser
    parser.finish()
    freeParser parser, req, socket
  socket.destroy()
  return
socketOnData = (d) ->
  socket = this
  req = @_httpMessage
  parser = @parser
  assert parser and parser.socket is socket
  ret = parser.execute(d)
  if ret instanceof Error
    debug "parse error"
    freeParser parser, req, socket
    socket.destroy()
    req.emit "error", ret
    req.socket._hadError = true
  else if parser.incoming and parser.incoming.upgrade
    
    # Upgrade or CONNECT
    bytesParsed = ret
    res = parser.incoming
    req.res = res
    socket.removeListener "data", socketOnData
    socket.removeListener "end", socketOnEnd
    parser.finish()
    bodyHead = d.slice(bytesParsed, d.length)
    eventName = (if req.method is "CONNECT" then "connect" else "upgrade")
    if EventEmitter.listenerCount(req, eventName) > 0
      req.upgradeOrConnect = true
      
      # detach the socket
      socket.emit "agentRemove"
      socket.removeListener "close", socketCloseListener
      socket.removeListener "error", socketErrorListener
      
      # TODO(isaacs): Need a way to reset a stream to fresh state
      # IE, not flowing, and not explicitly paused.
      socket._readableState.flowing = null
      req.emit eventName, res, socket, bodyHead
      req.emit "close"
    else
      
      # Got Upgrade header or CONNECT method, but have no handler.
      socket.destroy()
    freeParser parser, req, socket
  
  # When the status code is 100 (Continue), the server will
  # send a final response after this client sends a request
  # body. So, we must not free the parser.
  else if parser.incoming and parser.incoming.complete and parser.incoming.statusCode isnt 100
    socket.removeListener "data", socketOnData
    socket.removeListener "end", socketOnEnd
    freeParser parser, req, socket
  return

# client
parserOnIncomingClient = (res, shouldKeepAlive) ->
  socket = @socket
  req = socket._httpMessage
  
  # propogate "domain" setting...
  if req.domain and not res.domain
    debug "setting \"res.domain\""
    res.domain = req.domain
  debug "AGENT incoming response!"
  if req.res
    
    # We already have a response object, this means the server
    # sent a double response.
    socket.destroy()
    return
  req.res = res
  
  # Responses to CONNECT request is handled as Upgrade.
  if req.method is "CONNECT"
    res.upgrade = true
    return true # skip body
  
  # Responses to HEAD requests are crazy.
  # HEAD responses aren't allowed to have an entity-body
  # but *can* have a content-length which actually corresponds
  # to the content-length of the entity-body had the request
  # been a GET.
  isHeadResponse = req.method is "HEAD"
  debug "AGENT isHeadResponse", isHeadResponse
  if res.statusCode is 100
    
    # restart the parser, as this is a continue message.
    delete req.res # Clear res so that we don't hit double-responses.

    req.emit "continue"
    return true
  
  # Server MUST respond with Connection:keep-alive for us to enable it.
  # If we've been upgraded (via WebSockets) we also shouldn't try to
  # keep the connection open.
  req.shouldKeepAlive = false  if req.shouldKeepAlive and not shouldKeepAlive and not req.upgradeOrConnect
  DTRACE_HTTP_CLIENT_RESPONSE socket, req
  COUNTER_HTTP_CLIENT_RESPONSE()
  req.res = res
  res.req = req
  
  # add our listener first, so that we guarantee socket cleanup
  res.on "end", responseOnEnd
  handled = req.emit("response", res)
  
  # If the user did not listen for the 'response' event, then they
  # can't possibly read the data, so we ._dump() it into the void
  # so that the socket doesn't hang there in a paused state.
  res._dump()  unless handled
  isHeadResponse

# client
responseOnEnd = ->
  res = this
  req = res.req
  socket = req.socket
  unless req.shouldKeepAlive
    if socket.writable
      debug "AGENT socket.destroySoon()"
      socket.destroySoon()
    assert not socket.writable
  else
    debug "AGENT socket keep-alive"
    if req.timeoutCb
      socket.setTimeout 0, req.timeoutCb
      req.timeoutCb = null
    socket.removeListener "close", socketCloseListener
    socket.removeListener "error", socketErrorListener
    
    # Mark this socket as available, AFTER user-added end
    # handlers have a chance to run.
    process.nextTick ->
      socket.emit "free"
      return

  return
tickOnSocket = (req, socket) ->
  parser = parsers.alloc()
  req.socket = socket
  req.connection = socket
  parser.reinitialize HTTPParser.RESPONSE
  parser.socket = socket
  parser.incoming = null
  req.parser = parser
  socket.parser = parser
  socket._httpMessage = req
  
  # Setup "drain" propogation.
  httpSocketSetup socket
  
  # Propagate headers limit from request object to parser
  if util.isNumber(req.maxHeadersCount)
    parser.maxHeaderPairs = req.maxHeadersCount << 1
  else
    
    # Set default value because parser may be reused from FreeList
    parser.maxHeaderPairs = 2000
  parser.onIncoming = parserOnIncomingClient
  socket.on "error", socketErrorListener
  socket.on "data", socketOnData
  socket.on "end", socketOnEnd
  socket.on "close", socketCloseListener
  req.emit "socket", socket
  return
"use strict"
util = require("util")
net = require("net")
url = require("url")
EventEmitter = require("events").EventEmitter
HTTPParser = process.binding("http_parser").HTTPParser
assert = require("assert").ok
common = require("_http_common")
httpSocketSetup = common.httpSocketSetup
parsers = common.parsers
freeParser = common.freeParser
debug = common.debug
OutgoingMessage = require("_http_outgoing").OutgoingMessage
Agent = require("_http_agent")
util.inherits ClientRequest, OutgoingMessage
exports.ClientRequest = ClientRequest
ClientRequest::aborted = `undefined`
ClientRequest::_finish = ->
  DTRACE_HTTP_CLIENT_REQUEST this, @connection
  COUNTER_HTTP_CLIENT_REQUEST()
  OutgoingMessage::_finish.call this
  return

ClientRequest::_implicitHeader = ->
  @_storeHeader @method + " " + @path + " HTTP/1.1\r\n", @_renderHeaders()
  return

ClientRequest::abort = ->
  @aborted = Date.now()
  if @res
    @res._dump()
  else
    @once "response", (res) ->
      res._dump()
      return

  @socket.destroy()  if @socket
  return

ClientRequest::onSocket = (socket) ->
  req = this
  process.nextTick ->
    if req.aborted
      
      # If we were aborted while waiting for a socket, skip the whole thing.
      socket.emit "free"
    else
      tickOnSocket req, socket
    return

  return

ClientRequest::_deferToConnect = (method, arguments_, cb) ->
  
  # This function is for calls that need to happen once the socket is
  # connected and writable. It's an important promisy thing for all the socket
  # calls that happen either now (when a socket is assigned) or
  # in the future (when a socket gets assigned out of the pool and is
  # eventually writable).
  self = this
  onSocket = ->
    if self.socket.writable
      self.socket[method].apply self.socket, arguments_  if method
      cb()  if cb
    else
      self.socket.once "connect", ->
        self.socket[method].apply self.socket, arguments_  if method
        cb()  if cb
        return

    return

  unless self.socket
    self.once "socket", onSocket
  else
    onSocket()
  return

ClientRequest::setTimeout = (msecs, callback) ->
  emitTimeout = ->
    self.emit "timeout"
    return
  @once "timeout", callback  if callback
  self = this
  if @socket and @socket.writable
    @socket.setTimeout 0, @timeoutCb  if @timeoutCb
    @timeoutCb = emitTimeout
    @socket.setTimeout msecs, emitTimeout
    return
  
  # Set timeoutCb so that it'll get cleaned up on request end
  @timeoutCb = emitTimeout
  if @socket
    sock = @socket
    @socket.once "connect", ->
      sock.setTimeout msecs, emitTimeout
      return

    return
  @once "socket", (sock) ->
    sock.setTimeout msecs, emitTimeout
    return

  return

ClientRequest::setNoDelay = ->
  @_deferToConnect "setNoDelay", arguments
  return

ClientRequest::setSocketKeepAlive = ->
  @_deferToConnect "setKeepAlive", arguments
  return

ClientRequest::clearTimeout = (cb) ->
  @setTimeout 0, cb
  return
