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
readStart = (socket) ->
  socket.resume()  if socket and not socket._paused and socket.readable
  return
readStop = (socket) ->
  socket.pause()  if socket
  return

# Abstract base class for ServerRequest and ClientResponse. 
IncomingMessage = (socket) ->
  Stream.Readable.call this
  
  # XXX This implementation is kind of all over the place
  # When the parser emits body chunks, they go in this list.
  # _read() pulls them out, and when it finds EOF, it ends.
  @socket = socket
  @connection = socket
  @httpVersionMajor = null
  @httpVersionMinor = null
  @httpVersion = null
  @complete = false
  @headers = {}
  @rawHeaders = []
  @trailers = {}
  @rawTrailers = []
  @readable = true
  @_pendings = []
  @_pendingIndex = 0
  @upgrade = null
  
  # request (server) only
  @url = ""
  @method = null
  
  # response (client) only
  @statusCode = null
  @statusMessage = null
  @client = @socket
  
  # flag for backwards compatibility grossness.
  @_consuming = false
  
  # flag for when we decide that this message cannot possibly be
  # read by the user, so there's no point continuing to handle it.
  @_dumped = false
  return
"use strict"
util = require("util")
Stream = require("stream")
exports.readStart = readStart
exports.readStop = readStop
util.inherits IncomingMessage, Stream.Readable
exports.IncomingMessage = IncomingMessage
IncomingMessage::setTimeout = (msecs, callback) ->
  @on "timeout", callback  if callback
  @socket.setTimeout msecs
  return

IncomingMessage::read = (n) ->
  @_consuming = true
  @read = Stream.Readable::read
  @read n

IncomingMessage::_read = (n) ->
  
  # We actually do almost nothing here, because the parserOnBody
  # function fills up our internal buffer directly.  However, we
  # do need to unpause the underlying socket so that it flows.
  readStart @socket  if @socket.readable
  return


# It's possible that the socket will be destroyed, and removed from
# any messages, before ever calling this.  In that case, just skip
# it, since something else is destroying this connection anyway.
IncomingMessage::destroy = (error) ->
  @socket.destroy error  if @socket
  return

IncomingMessage::_addHeaderLines = (headers, n) ->
  if headers and headers.length
    raw = undefined
    dest = undefined
    if @complete
      raw = @rawTrailers
      dest = @trailers
    else
      raw = @rawHeaders
      dest = @headers
    i = 0

    while i < n
      k = headers[i]
      v = headers[i + 1]
      raw.push k
      raw.push v
      @_addHeaderLine k, v, dest
      i += 2
  return


# Add the given (field, value) pair to the message
#
# Per RFC2616, section 4.2 it is acceptable to join multiple instances of the
# same header with a ', ' if the header in question supports specification of
# multiple values this way. If not, we declare the first instance the winner
# and drop the second. Extended header fields (those beginning with 'x-') are
# always joined.
IncomingMessage::_addHeaderLine = (field, value, dest) ->
  field = field.toLowerCase()
  switch field
    
    # Array headers:
    when "set-cookie"
      unless util.isUndefined(dest[field])
        dest[field].push value
      else
        dest[field] = [value]
    
    # list is taken from:
    # https://mxr.mozilla.org/mozilla/source/netwerk/protocol/http/src/nsHttpHeaderArray.cpp
    when "content-type", "content-length", "user-agent", "referer", "host", "authorization", "proxy-authorization", "if-modified-since", "if-unmodified-since", "from", "location", "max-forwards"
      
      # drop duplicates
      dest[field] = value  if util.isUndefined(dest[field])
    else
      
      # make comma-separated list
      unless util.isUndefined(dest[field])
        dest[field] += ", " + value
      else
        dest[field] = value
  return


# Call this instead of resume() if we want to just
# dump all the data to /dev/null
IncomingMessage::_dump = ->
  unless @_dumped
    @_dumped = true
    @resume()
  return
