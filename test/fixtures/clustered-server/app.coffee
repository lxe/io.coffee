handleRequest = (request, response) ->
  response.end "hello world\n"
  return
http = require("http")
cluster = require("cluster")
common = require("../../common.js")
NUMBER_OF_WORKERS = 2
workersOnline = 0
if cluster.isMaster
  cluster.on "online", ->
    console.error "all workers are running"  if ++workersOnline is NUMBER_OF_WORKERS
    return

  process.on "message", (msg) ->
    if msg.type is "getpids"
      pids = []
      pids.push process.pid
      for key of cluster.workers
        pids.push cluster.workers[key].process.pid
      process.send
        type: "pids"
        pids: pids

    return

  i = 0

  while i < NUMBER_OF_WORKERS
    cluster.fork()
    i++
else
  server = http.createServer(handleRequest)
  server.listen common.PORT + 1000
