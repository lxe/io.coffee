
# set up one global domain.

# example: http://localhost:port/bytes/512/4
# sends a 512 byte body in 4 chunks of 128 bytes

# send body in chunks
makeString = (size, c) ->
  s = ""
  s += c  while s.length < size
  s
path = require("path")
exec = require("child_process").exec
http = require("http")
port = parseInt(process.env.PORT or 8000)
fixed = makeString(20 * 1024, "C")
storedBytes = {}
storedBuffer = {}
storedUnicode = {}
useDomains = process.env.NODE_USE_DOMAINS
if useDomains
  domain = require("domain")
  gdom = domain.create()
  gdom.on "error", (er) ->
    console.error "Error on global domain", er
    throw erreturn

  gdom.enter()
server = module.exports = http.createServer((req, res) ->
  if useDomains
    dom = domain.create()
    dom.add req
    dom.add res
  commands = req.url.split("/")
  command = commands[1]
  body = ""
  arg = commands[2]
  n_chunks = parseInt(commands[3], 10)
  status = 200
  if command is "bytes"
    n = ~~arg
    throw new Error("bytes called with n <= 0")  if n <= 0
    storedBytes[n] = makeString(n, "C")  if storedBytes[n] is `undefined`
    body = storedBytes[n]
  else if command is "buffer"
    n = ~~arg
    throw new Error("buffer called with n <= 0")  if n <= 0
    if storedBuffer[n] is `undefined`
      storedBuffer[n] = new Buffer(n)
      i = 0

      while i < n
        storedBuffer[n][i] = "C".charCodeAt(0)
        i++
    body = storedBuffer[n]
  else if command is "unicode"
    n = ~~arg
    throw new Error("unicode called with n <= 0")  if n <= 0
    storedUnicode[n] = makeString(n, "☺")  if storedUnicode[n] is `undefined`
    body = storedUnicode[n]
  else if command is "quit"
    res.connection.server.close()
    body = "quitting"
  else if command is "fixed"
    body = fixed
  else if command is "echo"
    res.writeHead 200,
      "Content-Type": "text/plain"
      "Transfer-Encoding": "chunked"

    req.pipe res
    return
  else
    status = 404
    body = "not found\n"
  if n_chunks > 0
    res.writeHead status,
      "Content-Type": "text/plain"
      "Transfer-Encoding": "chunked"

    len = body.length
    step = Math.floor(len / n_chunks) or 1
    i = 0
    n = (n_chunks - 1)

    while i < n
      res.write body.slice(i * step, i * step + step)
      ++i
    res.end body.slice((n_chunks - 1) * step)
  else
    content_length = body.length.toString()
    res.writeHead status,
      "Content-Type": "text/plain"
      "Content-Length": content_length

    res.end body
  return
)
server.listen port, ->
  console.error "Listening at http://127.0.0.1:" + port + "/"  if module is require.main
  return

