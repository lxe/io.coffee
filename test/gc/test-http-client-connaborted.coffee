# just like test/gc/http-client.js,
# but aborting every connection that comes in.
serverHandler = (req, res) ->
  res.connection.destroy()
  return
getall = ->
  return  if count >= todo
  (->
    cb = (res) ->
      done += 1
      statusLater()
      return
    req = http.get(
      hostname: "localhost"
      pathname: "/"
      port: PORT
    , cb).on("error", cb)
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
    assert count is countGC
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
