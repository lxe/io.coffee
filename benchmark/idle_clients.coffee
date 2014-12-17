connect = ->
  process.nextTick ->
    s = net.Stream()
    gotConnected = false
    s.connect 9000
    s.on "connect", ->
      gotConnected = true
      connections++
      connect()
      return

    s.on "close", ->
      connections--  if gotConnected
      lastClose = new Date()
      return

    s.on "error", ->
      errors++
      return

    return

  return
net = require("net")
errors = 0
connections = 0
lastClose = 0
connect()
oldConnections = undefined
oldErrors = undefined

# Try to start new connections every so often
setInterval connect, 5000
setInterval (->
  unless oldConnections is connections
    oldConnections = connections
    console.log "CLIENT %d connections: %d", process.pid, connections
  unless oldErrors is errors
    oldErrors = errors
    console.log "CLIENT %d errors: %d", process.pid, errors
  return
), 1000
