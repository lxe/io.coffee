# Run this program with valgrind or efence with --expose_gc to expose the
# problem.

# Flags: --expose_gc
flushPool = ->
  new Buffer(Buffer.poolSize - 1)
  gc()
  return
demoBug = (part1, part2) ->
  flushPool()
  parser = new HTTPParser("REQUEST")
  parser.headers = []
  parser.url = ""
  parser[kOnHeaders] = (headers, url) ->
    parser.headers = parser.headers.concat(headers)
    parser.url += url
    return

  parser[kOnHeadersComplete] = (info) ->
    headersComplete++
    console.log "url", info.url
    return

  parser[kOnBody] = (b, start, len) ->

  parser[kOnMessageComplete] = ->
    messagesComplete++
    return

  
  # We use a function to eliminate references to the Buffer b
  # We want b to be GCed. The parser will hold a bad reference to it.
  (->
    b = Buffer(part1)
    flushPool()
    console.log "parse the first part of the message"
    parser.execute b, 0, b.length
    return
  )()
  flushPool()
  (->
    b = Buffer(part2)
    console.log "parse the second part of the message"
    parser.execute b, 0, b.length
    parser.finish()
    return
  )()
  flushPool()
  return
common = require("../common")
assert = require("assert")
HTTPParser = process.binding("http_parser").HTTPParser
kOnHeaders = HTTPParser.kOnHeaders | 0
kOnHeadersComplete = HTTPParser.kOnHeadersComplete | 0
kOnBody = HTTPParser.kOnBody | 0
kOnMessageComplete = HTTPParser.kOnMessageComplete | 0
headersComplete = 0
messagesComplete = 0
demoBug "POST /1", "/22 HTTP/1.1\r\n" + "Content-Type: text/plain\r\n" + "Content-Length: 4\r\n\r\n" + "pong"
demoBug "POST /1/22 HTTP/1.1\r\n" + "Content-Type: tex", "t/plain\r\n" + "Content-Length: 4\r\n\r\n" + "pong"
process.on "exit", ->
  assert.equal 2, headersComplete
  assert.equal 2, messagesComplete
  console.log "done!"
  return

