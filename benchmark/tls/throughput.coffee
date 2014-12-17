main = (conf) ->
  onConnection = (conn) ->
    conn.on "data", (chunk) ->
      received += chunk.length
      return

    return
  done = ->
    mbits = (received * 8) / (1024 * 1024)
    bench.end mbits
    conn.destroy()
    server.close()
    return
  dur = +conf.dur
  type = conf.type
  size = +conf.size
  chunk = undefined
  switch type
    when "buf"
      chunk = new Buffer(size)
      chunk.fill "b"
    when "asc"
      chunk = new Array(size + 1).join("a")
      encoding = "ascii"
    when "utf"
      chunk = new Array(size / 2 + 1).join("ü")
      encoding = "utf8"
    else
      throw new Error("invalid type")
  options =
    key: fs.readFileSync(cert_dir + "/test_key.pem")
    cert: fs.readFileSync(cert_dir + "/test_cert.pem")
    ca: [fs.readFileSync(cert_dir + "/test_ca.pem")]
    ciphers: "AES256-GCM-SHA384"

  server = tls.createServer(options, onConnection)
  setTimeout done, dur * 1000
  server.listen common.PORT, ->
    write = ->
      i = 0
        while false isnt conn.write(chunk, encoding)
      return
    opt =
      port: common.PORT
      rejectUnauthorized: false

    conn = tls.connect(opt, ->
      bench.start()
      conn.on "drain", write
      write()
      return
    )
    return

  received = 0
  return
common = require("../common.js")
bench = common.createBenchmark(main,
  dur: [5]
  type: [
    "buf"
    "asc"
    "utf"
  ]
  size: [
    2
    1024
    1024 * 1024
  ]
)
dur = undefined
type = undefined
encoding = undefined
size = undefined
server = undefined
path = require("path")
fs = require("fs")
cert_dir = path.resolve(__dirname, "../../test/fixtures")
options = undefined
tls = require("tls")
