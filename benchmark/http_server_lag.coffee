http = require("http")
port = parseInt(process.env.PORT, 10) or 8000
defaultLag = parseInt(process.argv[2], 10) or 100
http.createServer((req, res) ->
  res.writeHead 200,
    "content-type": "text/plain"
    "content-length": "2"

  lag = parseInt(req.url.split("/").pop(), 10) or defaultLag
  setTimeout (->
    res.end "ok"
    return
  ), lag
  return
).listen port, "localhost"
