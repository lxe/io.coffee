# just like test/gc/http-client.js,
# but with an on('error') handler that does nothing.
serverHandler = (req, res) ->
  req.resume()
  res.writeHead 200,
    "Content-Type": "text/plain"

  res.end "Hello World\n"
  return
getall = ->
  return  if count >= todo
  (->
    cb = (res) ->
      res.resume()
      done += 1
      statusLater()
      return
    onerror = (er) ->
      throw erreturn
    req = http.get(
      hostname: "localhost"
      pathname: "/"
      port: PORT
    , cb).on("error", onerror)
    count++
    weak req, afterGC
    return
  )()
  setImmediate getall
  return
afterGC = ->
  countGC++
  return
statusLater = ->
  gc()
  clearTimeout timer  if timer
  timer = setTimeout(status, 1)
  return
status = ->
  gc()
  console.log "Done: %d/%d", done, todo
  console.log "Collected: %d/%d", countGC, count
  if done is todo
    console.log "All should be collected now."
    assert.strictEqual count, countGC
    process.exit 0
  return
http = require("http")
weak = require("weak")
done = 0
count = 0
countGC = 0
todo = 500
common = require("../common.js")
assert = require("assert")
PORT = common.PORT
console.log "We should do " + todo + " requests"
http = require("http")
server = http.createServer(serverHandler)
server.listen PORT, getall
i = 0

while i < 10
  getall()
  i++
timer = undefined
