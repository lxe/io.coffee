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
utcDate = ->
  unless dateCache
    d = new Date()
    dateCache = d.toUTCString()
    timers.enroll utcDate, 1000 - d.getMilliseconds()
    timers._unrefActive utcDate
  dateCache
OutgoingMessage = ->
  Stream.call this
  @output = []
  @outputEncodings = []
  @outputCallbacks = []
  @writable = true
  @_last = false
  @chunkedEncoding = false
  @shouldKeepAlive = true
  @useChunkedEncodingByDefault = true
  @sendDate = false
  @_removedHeader = {}
  @_hasBody = true
  @_trailer = ""
  @finished = false
  @_hangupClose = false
  @_headerSent = false
  @socket = null
  @connection = null
  @_header = null
  @_headers = null
  @_headerNames = {}
  return

# It's possible that the socket will be destroyed, and removed from
# any messages, before ever calling this.  In that case, just skip
# it, since something else is destroying this connection anyway.

# This abstract either writing directly to the socket or buffering it.

# This is a shameful hack to get the headers and first body chunk onto
# the same packet. Future versions of Node are going to take care of
# this at a lower level and in a more general way.

# There might be pending data in the this.output buffer.

# Directly write to socket.

# The socket was destroyed.  If we're still trying to write to it,
# then we haven't gotten the 'close' event yet.

# buffer, as long as we're not destroyed.

# firstLine in the case of request is: 'GET /index.html HTTP/1.1\r\n'
# in the case of response it is: 'HTTP/1.1 200 OK\r\n'

# Date header

# Force the connection to close when the response is a 204 No Content or
# a 304 Not Modified and the user has set a "Transfer-Encoding: chunked"
# header.
#
# RFC 2616 mandates that 204 and 304 responses MUST NOT have a body but
# node.js used to send out a zero chunk anyway to accommodate clients
# that don't have special handling for those responses.
#
# It was pointed out that this might confuse reverse proxies to the point
# of creating security liabilities, so suppress the zero chunk and force
# the connection to close.

# keep-alive logic

# Make sure we don't end the 0\r\n\r\n at the end of the message.

# wait until the first body chunk, or close(), is sent to flush,
# UNLESS we're sending Expect: 100-continue.
storeHeader = (self, state, field, value) ->
  
  # Protect against response splitting. The if statement is there to
  # minimize the performance impact in the common case.
  value = value.replace(/[\r\n]+[ \t]*/g, "")  if /[\r\n]/.test(value)
  state.messageHeader += field + ": " + value + CRLF
  if connectionExpression.test(field)
    state.sentConnectionHeader = true
    if closeExpression.test(value)
      self._last = true
    else
      self.shouldKeepAlive = true
  else if transferEncodingExpression.test(field)
    state.sentTransferEncodingHeader = true
    self.chunkedEncoding = true  if chunkExpression.test(value)
  else if contentLengthExpression.test(field)
    state.sentContentLengthHeader = true
  else if dateExpression.test(field)
    state.sentDateHeader = true
  else state.sentExpect = true  if expectExpression.test(field)
  return
"use strict"
assert = require("assert").ok
Stream = require("stream")
timers = require("timers")
util = require("util")
common = require("_http_common")
CRLF = common.CRLF
chunkExpression = common.chunkExpression
debug = common.debug
connectionExpression = /Connection/i
transferEncodingExpression = /Transfer-Encoding/i
closeExpression = /close/i
contentLengthExpression = /Content-Length/i
dateExpression = /Date/i
expectExpression = /Expect/i
automaticHeaders =
  connection: true
  "content-length": true
  "transfer-encoding": true
  date: true

dateCache = undefined
utcDate._onTimeout = ->
  dateCache = `undefined`
  return

util.inherits OutgoingMessage, Stream
exports.OutgoingMessage = OutgoingMessage
OutgoingMessage::setTimeout = (msecs, callback) ->
  @on "timeout", callback  if callback
  unless @socket
    @once "socket", (socket) ->
      socket.setTimeout msecs
      return

  else
    @socket.setTimeout msecs
  return

OutgoingMessage::destroy = (error) ->
  if @socket
    @socket.destroy error
  else
    @once "socket", (socket) ->
      socket.destroy error
      return

  return

OutgoingMessage::_send = (data, encoding, callback) ->
  unless @_headerSent
    if util.isString(data) and encoding isnt "hex" and encoding isnt "base64"
      data = @_header + data
    else
      @output.unshift @_header
      @outputEncodings.unshift "binary"
      @outputCallbacks.unshift null
    @_headerSent = true
  @_writeRaw data, encoding, callback

OutgoingMessage::_writeRaw = (data, encoding, callback) ->
  if util.isFunction(encoding)
    callback = encoding
    encoding = null
  if data.length is 0
    process.nextTick callback  if util.isFunction(callback)
    return true
  if @connection and @connection._httpMessage is this and @connection.writable and not @connection.destroyed
    while @output.length
      unless @connection.writable
        @_buffer data, encoding, callback
        return false
      c = @output.shift()
      e = @outputEncodings.shift()
      cb = @outputCallbacks.shift()
      @connection.write c, e, cb
    @connection.write data, encoding, callback
  else if @connection and @connection.destroyed
    false
  else
    @_buffer data, encoding, callback
    false

OutgoingMessage::_buffer = (data, encoding, callback) ->
  @output.push data
  @outputEncodings.push encoding
  @outputCallbacks.push callback
  false

OutgoingMessage::_storeHeader = (firstLine, headers) ->
  state =
    sentConnectionHeader: false
    sentContentLengthHeader: false
    sentTransferEncodingHeader: false
    sentDateHeader: false
    sentExpect: false
    messageHeader: firstLine

  field = undefined
  value = undefined
  if headers
    keys = Object.keys(headers)
    isArray = util.isArray(headers)
    field = undefined
    value = undefined
    i = 0
    l = keys.length

    while i < l
      key = keys[i]
      if isArray
        field = headers[key][0]
        value = headers[key][1]
      else
        field = key
        value = headers[key]
      if util.isArray(value)
        j = 0

        while j < value.length
          storeHeader this, state, field, value[j]
          j++
      else
        storeHeader this, state, field, value
      i++
  state.messageHeader += "Date: " + utcDate() + CRLF  if @sendDate is true and state.sentDateHeader is false
  statusCode = @statusCode
  if (statusCode is 204 or statusCode is 304) and @chunkedEncoding is true
    debug statusCode + " response should not use chunked encoding," + " closing connection."
    @chunkedEncoding = false
    @shouldKeepAlive = false
  if @_removedHeader.connection
    @_last = true
    @shouldKeepAlive = false
  else if state.sentConnectionHeader is false
    shouldSendKeepAlive = @shouldKeepAlive and (state.sentContentLengthHeader or @useChunkedEncodingByDefault or @agent)
    if shouldSendKeepAlive
      state.messageHeader += "Connection: keep-alive\r\n"
    else
      @_last = true
      state.messageHeader += "Connection: close\r\n"
  if state.sentContentLengthHeader is false and state.sentTransferEncodingHeader is false
    if @_hasBody and not @_removedHeader["transfer-encoding"]
      if @useChunkedEncodingByDefault
        state.messageHeader += "Transfer-Encoding: chunked\r\n"
        @chunkedEncoding = true
      else
        @_last = true
    else
      @chunkedEncoding = false
  @_header = state.messageHeader + CRLF
  @_headerSent = false
  @_send ""  if state.sentExpect
  return

OutgoingMessage::setHeader = (name, value) ->
  throw new TypeError("\"name\" should be a string")  if typeof name isnt "string"
  throw new Error("\"name\" and \"value\" are required for setHeader().")  if value is `undefined`
  throw new Error("Can't set headers after they are sent.")  if @_header
  @_headers = {}  if @_headers is null
  key = name.toLowerCase()
  @_headers[key] = value
  @_headerNames[key] = name
  @_removedHeader[key] = false  if automaticHeaders[key]
  return

OutgoingMessage::getHeader = (name) ->
  throw new Error("`name` is required for getHeader().")  if arguments.length < 1
  return  unless @_headers
  key = name.toLowerCase()
  @_headers[key]

OutgoingMessage::removeHeader = (name) ->
  throw new Error("`name` is required for removeHeader().")  if arguments.length < 1
  throw new Error("Can't remove headers after they are sent.")  if @_header
  key = name.toLowerCase()
  if key is "date"
    @sendDate = false
  else @_removedHeader[key] = true  if automaticHeaders[key]
  if @_headers
    delete @_headers[key]

    delete @_headerNames[key]
  return

OutgoingMessage::_renderHeaders = ->
  throw new Error("Can't render headers after they are sent to the client.")  if @_header
  return {}  unless @_headers
  headers = {}
  keys = Object.keys(@_headers)
  i = 0
  l = keys.length

  while i < l
    key = keys[i]
    headers[@_headerNames[key]] = @_headers[key]
    i++
  headers

Object.defineProperty OutgoingMessage::, "headersSent",
  configurable: true
  enumerable: true
  get: ->
    !!@_header

OutgoingMessage::write = (chunk, encoding, callback) ->
  self = this
  if @finished
    err = new Error("write after end")
    process.nextTick ->
      self.emit "error", err
      callback err  if callback
      return

    return true
  @_implicitHeader()  unless @_header
  unless @_hasBody
    debug "This type of response MUST NOT have a body. " + "Ignoring write() calls."
    return true
  throw new TypeError("first argument must be a string or Buffer")  if not util.isString(chunk) and not util.isBuffer(chunk)
  
  # If we get an empty string or buffer, then just do nothing, and
  # signal the user to keep writing.
  return true  if chunk.length is 0
  len = undefined
  ret = undefined
  if @chunkedEncoding
    if util.isString(chunk) and encoding isnt "hex" and encoding isnt "base64" and encoding isnt "binary"
      len = Buffer.byteLength(chunk, encoding)
      chunk = len.toString(16) + CRLF + chunk + CRLF
      ret = @_send(chunk, encoding, callback)
    else
      
      # buffer, or a non-toString-friendly encoding
      if util.isString(chunk)
        len = Buffer.byteLength(chunk, encoding)
      else
        len = chunk.length
      if @connection and not @connection.corked
        @connection.cork()
        conn = @connection
        process.nextTick connectionCork = ->
          conn.uncork()  if conn
          return

      @_send len.toString(16), "binary", null
      @_send crlf_buf, null, null
      @_send chunk, encoding, null
      ret = @_send(crlf_buf, null, callback)
  else
    ret = @_send(chunk, encoding, callback)
  debug "write ret = " + ret
  ret

OutgoingMessage::addTrailers = (headers) ->
  @_trailer = ""
  keys = Object.keys(headers)
  isArray = util.isArray(headers)
  field = undefined
  value = undefined
  i = 0
  l = keys.length

  while i < l
    key = keys[i]
    if isArray
      field = headers[key][0]
      value = headers[key][1]
    else
      field = key
      value = headers[key]
    @_trailer += field + ": " + value + CRLF
    i++
  return

crlf_buf = new Buffer("\r\n")
OutgoingMessage::end = (data, encoding, callback) ->
  finish = ->
    self.emit "finish"
    return
  if util.isFunction(data)
    callback = data
    data = null
  else if util.isFunction(encoding)
    callback = encoding
    encoding = null
  throw new TypeError("first argument must be a string or Buffer")  if data and not util.isString(data) and not util.isBuffer(data)
  return false  if @finished
  self = this
  @once "finish", callback  if util.isFunction(callback)
  @_implicitHeader()  unless @_header
  if data and not @_hasBody
    debug "This type of response MUST NOT have a body. " + "Ignoring data passed to end()."
    data = null
  @connection.cork()  if @connection and data
  ret = undefined
  
  # Normal body write.
  ret = @write(data, encoding)  if data
  if @_hasBody and @chunkedEncoding
    ret = @_send("0\r\n" + @_trailer + "\r\n", "binary", finish)
  else
    
    # Force a flush, HACK.
    ret = @_send("", "binary", finish)
  @connection.uncork()  if @connection and data
  @finished = true
  
  # There is the first message on the outgoing queue, and we've sent
  # everything to the socket.
  debug "outgoing message end."
  @_finish()  if @output.length is 0 and @connection._httpMessage is this
  ret

OutgoingMessage::_finish = ->
  assert @connection
  @emit "prefinish"
  return


# This logic is probably a bit confusing. Let me explain a bit:
#
# In both HTTP servers and clients it is possible to queue up several
# outgoing messages. This is easiest to imagine in the case of a client.
# Take the following situation:
#
#    req1 = client.request('GET', '/');
#    req2 = client.request('POST', '/');
#
# When the user does
#
#   req2.write('hello world\n');
#
# it's possible that the first request has not been completely flushed to
# the socket yet. Thus the outgoing messages need to be prepared to queue
# up data internally before sending it on further to the socket's queue.
#
# This function, outgoingFlush(), is called by both the Server and Client
# to attempt to flush any pending messages out to the socket.
OutgoingMessage::_flush = ->
  if @socket and @socket.writable
    ret = undefined
    while @output.length
      data = @output.shift()
      encoding = @outputEncodings.shift()
      cb = @outputCallbacks.shift()
      ret = @socket.write(data, encoding, cb)
    if @finished
      
      # This is a queue to the server or client to bring in the next this.
      @_finish()
    
    # This is necessary to prevent https from breaking
    else @emit "drain"  if ret
  return

OutgoingMessage::flush = ->
  unless @_header
    
    # Force-flush the headers.
    @_implicitHeader()
    @_send ""
  return
