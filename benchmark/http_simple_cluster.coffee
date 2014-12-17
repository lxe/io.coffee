cluster = require("cluster")
os = require("os")
if cluster.isMaster
  console.log "master running on pid %d", process.pid
  i = 0
  n = os.cpus().length

  while i < n
    cluster.fork()
    ++i
else
  require __dirname + "/http_simple.js"
