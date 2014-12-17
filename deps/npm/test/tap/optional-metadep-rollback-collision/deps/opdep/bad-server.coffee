createServer = require("http").createServer
spawn = require("child_process").spawn
fs = require("fs")
path = require("path")
pidfile = path.resolve(__dirname, "..", "..", "child.pid")
if process.argv[2]
  console.log "ok"
  createServer((req, res) ->
    setTimeout (->
      res.writeHead 404
      res.end()
      return
    ), 1000
    @close()
    return
  ).listen 8080
else
  child = spawn(process.execPath, [
    __filename
    "whatever"
  ],
    stdio: [
      0
      1
      2
    ]
    detached: true
  )
  child.unref()
  
  # kill any prior children, if existing.
  try
    pid = +fs.readFileSync(pidfile)
    process.kill pid, "SIGKILL"
  fs.writeFileSync pidfile, child.pid + "\n"
