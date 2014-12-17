common = require("../common-tap.js")
fs = require("fs")
path = require("path")
createServer = require("http").createServer
test = require("tap").test
rimraf = require("rimraf")
opts = cwd: __dirname
FIXTURE_PATH = path.resolve(__dirname, "fixture_npmrc")
test "npm whoami with basic auth", (t) ->
  s = "//registry.lvh.me/:username = wombat\n" + "//registry.lvh.me/:_password = YmFkIHBhc3N3b3Jk\n" + "//registry.lvh.me/:email = lindsay@wdu.org.au\n"
  fs.writeFileSync FIXTURE_PATH, s, "ascii"
  fs.chmodSync FIXTURE_PATH, "0444"
  common.npm [
    "whoami"
    "--userconfig=" + FIXTURE_PATH
    "--registry=http://registry.lvh.me/"
  ], opts, (err, code, stdout, stderr) ->
    t.ifError err
    t.equal stderr, "", "got nothing on stderr"
    t.equal code, 0, "exit ok"
    t.equal stdout, "wombat\n", "got username"
    rimraf.sync FIXTURE_PATH
    t.end()
    return

  return

test "npm whoami with bearer auth",
  timeout: 2 * 1000
, (t) ->
  verify = (req, res) ->
    t.equal req.method, "GET"
    t.equal req.url, "/whoami"
    res.setHeader "content-type", "application/json"
    res.writeHeader 200
    res.end JSON.stringify(username: "wombat"), "utf8"
    return
  s = "//localhost:" + common.port + "/:_authToken = wombat-developers-union\n"
  fs.writeFileSync FIXTURE_PATH, s, "ascii"
  fs.chmodSync FIXTURE_PATH, "0444"
  server = createServer(verify)
  server.listen common.port, ->
    common.npm [
      "whoami"
      "--userconfig=" + FIXTURE_PATH
      "--registry=http://localhost:" + common.port + "/"
    ], opts, (err, code, stdout, stderr) ->
      t.ifError err
      t.equal stderr, "", "got nothing on stderr"
      t.equal code, 0, "exit ok"
      t.equal stdout, "wombat\n", "got username"
      rimraf.sync FIXTURE_PATH
      server.close()
      t.end()
      return

    return

  return

