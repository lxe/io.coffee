main = (conf) ->
  dur = +conf.dur
  concurrency = +conf.concurrency
  cert_dir = path.resolve(__dirname, "../../test/fixtures")
  options =
    key: fs.readFileSync(cert_dir + "/test_key.pem")
    cert: fs.readFileSync(cert_dir + "/test_cert.pem")
    ca: [fs.readFileSync(cert_dir + "/test_ca.pem")]
    ciphers: "AES256-GCM-SHA384"

  server = tls.createServer(options, onConnection)
  server.listen common.PORT, onListening
  return
onListening = ->
  setTimeout done, dur * 1000
  bench.start()
  i = 0

  while i < concurrency
    makeConnection()
    i++
  return
onConnection = (conn) ->
  serverConn++
  return
makeConnection = ->
  conn = tls.connect(
    port: common.PORT
    rejectUnauthorized: false
  , ->
    clientConn++
    conn.on "error", (er) ->
      console.error "client error", er
      throw erreturn

    conn.end()
    makeConnection()  if running
    return
  )
  return
done = ->
  running = false
  
  # it's only an established connection if they both saw it.
  # because we destroy the server somewhat abruptly, these
  # don't always match.  Generally, serverConn will be
  # the smaller number, but take the min just to be sure.
  bench.end Math.min(serverConn, clientConn)
  return
assert = require("assert")
fs = require("fs")
path = require("path")
tls = require("tls")
common = require("../common.js")
bench = common.createBenchmark(main,
  concurrency: [
    1
    10
  ]
  dur: [5]
)
clientConn = 0
serverConn = 0
server = undefined
dur = undefined
concurrency = undefined
running = true
