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

# Only called in the slow case where slow means
# that the request headers were either fragmented
# across multiple TCP packets or too large to be
# processed in a single run. This method is also
# called to process trailing HTTP headers.
parserOnHeaders = (headers, url) ->
  
  # Once we exceeded headers limit - stop collecting them
  @_headers = @_headers.concat(headers)  if @maxHeaderPairs <= 0 or @_headers.length < @maxHeaderPairs
  @_url += url
  return

# info.headers and info.url are set only if .onHeaders()
# has not been called for this request.
#
# info.url is not set for response parsers but that's not
# applicable here since all our parsers are request parsers.
parserOnHeadersComplete = (info) ->
  debug "parserOnHeadersComplete", info
  parser = this
  headers = info.headers
  url = info.url
  unless headers
    headers = parser._headers
    parser._headers = []
  unless url
    url = parser._url
    parser._url = ""
  parser.incoming = new IncomingMessage(parser.socket)
  parser.incoming.httpVersionMajor = info.versionMajor
  parser.incoming.httpVersionMinor = info.versionMinor
  parser.incoming.httpVersion = info.versionMajor + "." + info.versionMinor
  parser.incoming.url = url
  n = headers.length
  
  # If parser.maxHeaderPairs <= 0 - assume that there're no limit
  n = Math.min(n, parser.maxHeaderPairs)  if parser.maxHeaderPairs > 0
  parser.incoming._addHeaderLines headers, n
  if isNumber(info.method)
    
    # server only
    parser.incoming.method = HTTPParser.methods[info.method]
  else
    
    # client only
    parser.incoming.statusCode = info.statusCode
    parser.incoming.statusMessage = info.statusMessage
  parser.incoming.upgrade = info.upgrade
  skipBody = false # response to HEAD or CONNECT
  
  # For upgraded connections and CONNECT method request,
  # we'll emit this after parser.execute
  # so that we can capture the first part of the new protocol
  skipBody = parser.onIncoming(parser.incoming, info.shouldKeepAlive)  unless info.upgrade
  skipBody

# XXX This is a mess.
# TODO: http.Parser should be a Writable emits request/response events.
parserOnBody = (b, start, len) ->
  parser = this
  stream = parser.incoming
  
  # if the stream has already been removed, then drop it.
  return  unless stream
  socket = stream.socket
  
  # pretend this was the result of a stream._read call.
  if len > 0 and not stream._dumped
    slice = b.slice(start, start + len)
    ret = stream.push(slice)
    readStop socket  unless ret
  return
parserOnMessageComplete = ->
  parser = this
  stream = parser.incoming
  if stream
    stream.complete = true
    
    # Emit any trailing headers.
    headers = parser._headers
    if headers
      parser.incoming._addHeaderLines headers, headers.length
      parser._headers = []
      parser._url = ""
    
    # For upgraded connections, also emit this after parser.execute
    stream.push null  unless stream.upgrade
  
  # For emit end event
  stream.push null  if stream and not parser.incoming._pendings.length
  
  # force to read the next incoming message
  readStart parser.socket
  return

# Only called in the slow case where slow means
# that the request headers were either fragmented
# across multiple TCP packets or too large to be
# processed in a single run. This method is also
# called to process trailing HTTP headers.

# Free the parser and also break any links that it
# might have to any other things.
# TODO: All parser data should be attached to a
# single object, so that it can be easily cleaned
# up by doing `parser.data = {}`, which should
# be done in FreeList.free.  `parsers.free(parser)`
# should be all that is needed.
freeParser = (parser, req, socket) ->
  if parser
    parser._headers = []
    parser.onIncoming = null
    parser.socket.parser = null  if parser.socket
    parser.socket = null
    parser.incoming = null
    parser.close()  if parsers.free(parser) is false
    parser = null
  req.parser = null  if req
  socket.parser = null  if socket
  return
ondrain = ->
  @_httpMessage.emit "drain"  if @_httpMessage
  return
httpSocketSetup = (socket) ->
  socket.removeListener "drain", ondrain
  socket.on "drain", ondrain
  return
"use strict"
FreeList = require("freelist").FreeList
HTTPParser = process.binding("http_parser").HTTPParser
incoming = require("_http_incoming")
IncomingMessage = incoming.IncomingMessage
readStart = incoming.readStart
readStop = incoming.readStop
isNumber = require("util").isNumber
debug = require("util").debuglog("http")
exports.debug = debug
exports.CRLF = "\r\n"
exports.chunkExpression = /chunk/i
exports.continueExpression = /100-continue/i
exports.methods = HTTPParser.methods
kOnHeaders = HTTPParser.kOnHeaders | 0
kOnHeadersComplete = HTTPParser.kOnHeadersComplete | 0
kOnBody = HTTPParser.kOnBody | 0
kOnMessageComplete = HTTPParser.kOnMessageComplete | 0
parsers = new FreeList("parsers", 1000, ->
  parser = new HTTPParser(HTTPParser.REQUEST)
  parser._headers = []
  parser._url = ""
  parser[kOnHeaders] = parserOnHeaders
  parser[kOnHeadersComplete] = parserOnHeadersComplete
  parser[kOnBody] = parserOnBody
  parser[kOnMessageComplete] = parserOnMessageComplete
  parser
)
exports.parsers = parsers
exports.freeParser = freeParser
exports.httpSocketSetup = httpSocketSetup
