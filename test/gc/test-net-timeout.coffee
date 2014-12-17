# just like test/gc/http-client-timeout.js,
# but using a net server/client instead
serverHandler = (sock) ->
  sock.setTimeout 120000
  sock.resume()
  timer = undefined
  sock.on "close", ->
    clearTimeout timer
    return

  sock.on "error", (err) ->
    assert.strictEqual err.code, "ECONNRESET"
    return

  timer = setTimeout(->
    sock.end "hello\n"
    return
  , 100)
  return
getall = ->
  return  if count >= todo
  (->
    req = net.connect(PORT, "127.0.0.1")
    req.resume()
    req.setTimeout 10, ->
      
      #console.log('timeout (expected)')
      req.destroy()
      done++
      gc()
      return

    count++
    weak req, afterGC
    return
  )()
  setImmediate getall
  return
afterGC = ->
  countGC++
  return
status = ->
  gc()
  console.log "Done: %d/%d", done, todo
  console.log "Collected: %d/%d", countGC, count
  if done is todo
    
    # Give libuv some time to make close callbacks. 
    setTimeout (->
      gc()
      console.log "All should be collected now."
      console.log "Collected: %d/%d", countGC, count
      assert count is countGC
      process.exit 0
      return
    ), 200
  return
net = require("net")
weak = require("weak")
done = 0
count = 0
countGC = 0
todo = 500
common = require("../common.js")
assert = require("assert")
PORT = common.PORT
console.log "We should do " + todo + " requests"
server = net.createServer(serverHandler)
server.listen PORT, getall
i = 0

while i < 10
  getall()
  i++
setInterval(status, 100).unref()
