net = require("net")
connections = 0
errors = 0
server = net.Server((socket) ->
  socket.on "error", ->
    errors++
    return

  return
)

#server.maxConnections = 128;
server.listen 9000
oldConnections = undefined
oldErrors = undefined
setInterval (->
  unless oldConnections is server.connections
    oldConnections = server.connections
    console.log "SERVER %d connections: %d", process.pid, server.connections
  unless oldErrors is errors
    oldErrors = errors
    console.log "SERVER %d errors: %d", process.pid, errors
  return
), 1000
