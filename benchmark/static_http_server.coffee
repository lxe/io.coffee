http = require("http")
concurrency = 30
port = 12346
n = 700
bytes = 1024 * 5
requests = 0
responses = 0
body = ""
i = 0

while i < bytes
  body += "C"
  i++
server = http.createServer((req, res) ->
  res.writeHead 200,
    "Content-Type": "text/plain"
    "Content-Length": body.length

  res.end body
  return
)
server.listen port, ->
  agent = new http.Agent()
  agent.maxSockets = concurrency
  i = 0

  while i < n
    req = http.get(
      port: port
      path: "/"
      agent: agent
    , (res) ->
      res.resume()
      res.on "end", ->
        server.close()  if ++responses is n
        return

      return
    )
    req.id = i
    requests++
    i++
  return

