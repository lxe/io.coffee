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
# RFC 2518, obsoleted by RFC 4918
# RFC 4918
# RFC 7238
# RFC 2324
# RFC 4918
# RFC 4918
# RFC 4918
# RFC 4918
# RFC 2817
# RFC 6585
# RFC 6585
# RFC 6585
# RFC 2295
# RFC 4918
# RFC 2774
# RFC 6585
ServerResponse = (req) ->
  OutgoingMessage.call this
  @_hasBody = false  if req.method is "HEAD"
  @sendDate = true
  if req.httpVersionMajor < 1 or req.httpVersionMinor < 1
    @useChunkedEncodingByDefault = chunkExpression.test(req.headers.te)
    @shouldKeepAlive = false
  return
onServerResponseClose = ->
  
  # EventEmitter.emit makes a copy of the 'close' listeners array before
  # calling the listeners. detachSocket() unregisters onServerResponseClose
  # but if detachSocket() is called, directly or indirectly, by a 'close'
  # listener, onServerResponseClose is still in that copy of the listeners
  # array. That is, in the example below, b still gets called even though
  # it's been removed by a:
  #
  #   var obj = new events.EventEmitter;
  #   obj.on('event', a);
  #   obj.on('event', b);
  #   function a() { obj.removeListener('event', b) }
  #   function b() { throw "BAM!" }
  #   obj.emit('event');  // throws
  #
  # Ergo, we need to deal with stale 'close' events and handle the case
  # where the ServerResponse object has already been deconstructed.
  # Fortunately, that requires only a single if check. :-)
  @_httpMessage.emit "close"  if @_httpMessage
  return

# writeHead(statusCode, reasonPhrase[, headers])

# writeHead(statusCode[, headers])

# Slow-case: when progressive API and header fields are passed.

# only progressive api is used

# only writeHead() called

# RFC 2616, 10.2.5:
# The 204 response MUST NOT include a message-body, and thus is always
# terminated by the first empty line after the header fields.
# RFC 2616, 10.3.5:
# The 304 response MUST NOT contain a message-body, and thus is always
# terminated by the first empty line after the header fields.
# RFC 2616, 10.1 Informational 1xx:
# This class of status code indicates a provisional response,
# consisting only of the Status-Line and optional headers, and is
# terminated by an empty line.

# don't keep alive connections where the client expects 100 Continue
# but we sent a final status; they may put extra bytes on the wire.
Server = (requestListener) ->
  return new Server(requestListener)  unless this instanceof Server
  net.Server.call this,
    allowHalfOpen: true

  @addListener "request", requestListener  if requestListener
  
  # Similar option to this. Too lazy to write my own docs.
  # http://www.squid-cache.org/Doc/config/half_closed_clients/
  # http://wiki.squid-cache.org/SquidFaq/InnerWorkings#What_is_a_half-closed_filedescriptor.3F
  @httpAllowHalfOpen = false
  @addListener "connection", connectionListener
  @addListener "clientError", (err, conn) ->
    conn.destroy err
    return

  @timeout = 2 * 60 * 1000
  return
connectionListener = (socket) ->
  abortIncoming = ->
    while incoming.length
      req = incoming.shift()
      req.emit "aborted"
      req.emit "close"
    return
  
  # abort socket._httpMessage ?
  serverSocketCloseListener = ->
    debug "server socket close"
    
    # mark this parser as reusable
    freeParser @parser, null, this  if @parser
    abortIncoming()
    return
  
  # If the user has added a listener to the server,
  # request, or response, then it's their responsibility.
  # otherwise, destroy on timeout by default
  
  # Propagate headers limit from server instance to parser
  
  # Set default value because parser may be reused from FreeList
  
  # TODO(isaacs): Move all these functions out of here
  socketOnError = (e) ->
    self.emit "clientError", e, this
    return
  socketOnData = (d) ->
    assert not socket._paused
    debug "SERVER socketOnData %d", d.length
    ret = parser.execute(d)
    if ret instanceof Error
      debug "parse error"
      socket.destroy ret
    else if parser.incoming and parser.incoming.upgrade
      
      # Upgrade or CONNECT
      bytesParsed = ret
      req = parser.incoming
      debug "SERVER upgrade or connect", req.method
      socket.removeListener "data", socketOnData
      socket.removeListener "end", socketOnEnd
      socket.removeListener "close", serverSocketCloseListener
      parser.finish()
      freeParser parser, req, null
      parser = null
      eventName = (if req.method is "CONNECT" then "connect" else "upgrade")
      if EventEmitter.listenerCount(self, eventName) > 0
        debug "SERVER have listener for %s", eventName
        bodyHead = d.slice(bytesParsed, d.length)
        
        # TODO(isaacs): Need a way to reset a stream to fresh state
        # IE, not flowing, and not explicitly paused.
        socket._readableState.flowing = null
        self.emit eventName, req, socket, bodyHead
      else
        
        # Got upgrade header or CONNECT method, but have no handler.
        socket.destroy()
    if socket._paused
      
      # onIncoming paused the socket, we should pause the parser as well
      debug "pause parser"
      socket.parser.pause()
    return
  socketOnEnd = ->
    socket = this
    ret = parser.finish()
    if ret instanceof Error
      debug "parse error"
      socket.destroy ret
      return
    unless self.httpAllowHalfOpen
      abortIncoming()
      socket.end()  if socket.writable
    else if outgoing.length
      outgoing[outgoing.length - 1]._last = true
    else if socket._httpMessage
      socket._httpMessage._last = true
    else
      socket.end()  if socket.writable
    return
  
  # The following callback is issued after the headers have been read on a
  # new message. In this callback we setup the response object and pass it
  # to the user.
  socketOnDrain = ->
    
    # If we previously paused, then start reading again.
    if socket._paused
      socket._paused = false
      socket.parser.resume()
      socket.resume()
    return
  parserOnIncoming = (req, shouldKeepAlive) ->
    
    # If the writable end isn't consuming, then stop reading
    # so that we don't become overwhelmed by a flood of
    # pipelined requests that may never be resolved.
    
    # We also need to pause the parser, but don't do that until after
    # the call to execute, because we may still be processing the last
    # chunk.
    
    # There are already pending outgoing res, append.
    
    # When we're finished writing the response, check if this is the last
    # respose, if so destroy the socket.
    resOnFinish = ->
      
      # Usually the first incoming element should be our request.  it may
      # be that in the case abortIncoming() was called that the incoming
      # array will be empty.
      assert incoming.length is 0 or incoming[0] is req
      incoming.shift()
      
      # if the user never called req.read(), and didn't pipe() or
      # .resume() or .on('data'), then we call req._dump() so that the
      # bytes will be pulled off the wire.
      req._dump()  if not req._consuming and not req._readableState.resumeScheduled
      res.detachSocket socket
      if res._last
        socket.destroySoon()
      else
        
        # start sending the next message
        m = outgoing.shift()
        m.assignSocket socket  if m
      return
    incoming.push req
    unless socket._paused
      needPause = socket._writableState.needDrain
      if needPause
        socket._paused = true
        socket.pause()
    res = new ServerResponse(req)
    res.shouldKeepAlive = shouldKeepAlive
    DTRACE_HTTP_SERVER_REQUEST req, socket
    COUNTER_HTTP_SERVER_REQUEST()
    if socket._httpMessage
      outgoing.push res
    else
      res.assignSocket socket
    res.on "prefinish", resOnFinish
    if not util.isUndefined(req.headers.expect) and (req.httpVersionMajor is 1 and req.httpVersionMinor is 1) and continueExpression.test(req.headers["expect"])
      res._expect_continue = true
      if EventEmitter.listenerCount(self, "checkContinue") > 0
        self.emit "checkContinue", req, res
      else
        res.writeContinue()
        self.emit "request", req, res
    else
      self.emit "request", req, res
    false # Not a HEAD response. (Not even a response!)
  self = this
  outgoing = []
  incoming = []
  debug "SERVER new http connection"
  httpSocketSetup socket
  socket.setTimeout self.timeout  if self.timeout
  socket.on "timeout", ->
    req = socket.parser and socket.parser.incoming
    reqTimeout = req and not req.complete and req.emit("timeout", socket)
    res = socket._httpMessage
    resTimeout = res and res.emit("timeout", socket)
    serverTimeout = self.emit("timeout", socket)
    socket.destroy()  if not reqTimeout and not resTimeout and not serverTimeout
    return

  parser = parsers.alloc()
  parser.reinitialize HTTPParser.REQUEST
  parser.socket = socket
  socket.parser = parser
  parser.incoming = null
  if util.isNumber(@maxHeadersCount)
    parser.maxHeaderPairs = @maxHeadersCount << 1
  else
    parser.maxHeaderPairs = 2000
  socket.addListener "error", socketOnError
  socket.addListener "close", serverSocketCloseListener
  parser.onIncoming = parserOnIncoming
  socket.on "end", socketOnEnd
  socket.on "data", socketOnData
  socket._paused = false
  socket.on "drain", socketOnDrain
  return
"use strict"
util = require("util")
net = require("net")
EventEmitter = require("events").EventEmitter
HTTPParser = process.binding("http_parser").HTTPParser
assert = require("assert").ok
common = require("_http_common")
parsers = common.parsers
freeParser = common.freeParser
debug = common.debug
CRLF = common.CRLF
continueExpression = common.continueExpression
chunkExpression = common.chunkExpression
httpSocketSetup = common.httpSocketSetup
OutgoingMessage = require("_http_outgoing").OutgoingMessage
STATUS_CODES = exports.STATUS_CODES =
  100: "Continue"
  101: "Switching Protocols"
  102: "Processing"
  200: "OK"
  201: "Created"
  202: "Accepted"
  203: "Non-Authoritative Information"
  204: "No Content"
  205: "Reset Content"
  206: "Partial Content"
  207: "Multi-Status"
  300: "Multiple Choices"
  301: "Moved Permanently"
  302: "Moved Temporarily"
  303: "See Other"
  304: "Not Modified"
  305: "Use Proxy"
  307: "Temporary Redirect"
  308: "Permanent Redirect"
  400: "Bad Request"
  401: "Unauthorized"
  402: "Payment Required"
  403: "Forbidden"
  404: "Not Found"
  405: "Method Not Allowed"
  406: "Not Acceptable"
  407: "Proxy Authentication Required"
  408: "Request Time-out"
  409: "Conflict"
  410: "Gone"
  411: "Length Required"
  412: "Precondition Failed"
  413: "Request Entity Too Large"
  414: "Request-URI Too Large"
  415: "Unsupported Media Type"
  416: "Requested Range Not Satisfiable"
  417: "Expectation Failed"
  418: "I'm a teapot"
  422: "Unprocessable Entity"
  423: "Locked"
  424: "Failed Dependency"
  425: "Unordered Collection"
  426: "Upgrade Required"
  428: "Precondition Required"
  429: "Too Many Requests"
  431: "Request Header Fields Too Large"
  500: "Internal Server Error"
  501: "Not Implemented"
  502: "Bad Gateway"
  503: "Service Unavailable"
  504: "Gateway Time-out"
  505: "HTTP Version Not Supported"
  506: "Variant Also Negotiates"
  507: "Insufficient Storage"
  509: "Bandwidth Limit Exceeded"
  510: "Not Extended"
  511: "Network Authentication Required"

util.inherits ServerResponse, OutgoingMessage
ServerResponse::_finish = ->
  DTRACE_HTTP_SERVER_RESPONSE @connection
  COUNTER_HTTP_SERVER_RESPONSE()
  OutgoingMessage::_finish.call this
  return

exports.ServerResponse = ServerResponse
ServerResponse::statusCode = 200
ServerResponse::statusMessage = `undefined`
ServerResponse::assignSocket = (socket) ->
  assert not socket._httpMessage
  socket._httpMessage = this
  socket.on "close", onServerResponseClose
  @socket = socket
  @connection = socket
  @emit "socket", socket
  @_flush()
  return

ServerResponse::detachSocket = (socket) ->
  assert socket._httpMessage is this
  socket.removeListener "close", onServerResponseClose
  socket._httpMessage = null
  @socket = @connection = null
  return

ServerResponse::writeContinue = (cb) ->
  @_writeRaw "HTTP/1.1 100 Continue" + CRLF + CRLF, "ascii", cb
  @_sent100 = true
  return

ServerResponse::_implicitHeader = ->
  @writeHead @statusCode
  return

ServerResponse::writeHead = (statusCode, reason, obj) ->
  headers = undefined
  if util.isString(reason)
    @statusMessage = reason
  else
    @statusMessage = @statusMessage or STATUS_CODES[statusCode] or "unknown"
    obj = reason
  @statusCode = statusCode
  if @_headers
    if obj
      keys = Object.keys(obj)
      i = 0

      while i < keys.length
        k = keys[i]
        @setHeader k, obj[k]  if k
        i++
    headers = @_renderHeaders()
  else
    headers = obj
  statusLine = "HTTP/1.1 " + statusCode.toString() + " " + @statusMessage + CRLF
  @_hasBody = false  if statusCode is 204 or statusCode is 304 or (100 <= statusCode and statusCode <= 199)
  @shouldKeepAlive = false  if @_expect_continue and not @_sent100
  @_storeHeader statusLine, headers
  return

ServerResponse::writeHeader = ->
  @writeHead.apply this, arguments
  return

util.inherits Server, net.Server
Server::setTimeout = (msecs, callback) ->
  @timeout = msecs
  @on "timeout", callback  if callback
  return

exports.Server = Server
exports._connectionListener = connectionListener
