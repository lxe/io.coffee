mocks = (server) ->
  server.filteringRequestBody (r) ->
    "auth"  if r.match(/\"_id\":\"org\.couchdb\.user:u\"/)

  server.put("/-/user/org.couchdb.user:u", "auth").reply 201,
    username: "u"
    password: "p"
    email: "u@p.me"

  return
fs = require("fs")
path = require("path")
rimraf = require("rimraf")
mr = require("npm-registry-mock")
test = require("tap").test
common = require("../common-tap.js")
opts = cwd: __dirname
outfile = path.resolve(__dirname, "_npmrc")
responses =
  Username: "u\n"
  Password: "p\n"
  Email: "u@p.me\n"

test "npm login", (t) ->
  mr
    port: common.port
    mocks: mocks
  , (s) ->
    runner = common.npm([
      "login"
      "--registry"
      common.registry
      "--loglevel"
      "silent"
      "--userconfig"
      outfile
    ], opts, (err, code) ->
      t.notOk code, "exited OK"
      t.notOk err, "no error output"
      config = fs.readFileSync(outfile, "utf8")
      t.like config, /:always-auth=false/, "always-auth is scoped and false (by default)"
      s.close()
      rimraf outfile, (err) ->
        t.ifError err, "removed config file OK"
        t.end()
        return

      return
    )
    o = ""
    e = ""
    remaining = Object.keys(responses).length
    runner.stdout.on "data", (chunk) ->
      remaining--
      o += chunk
      label = chunk.toString("utf8").split(":")[0]
      runner.stdin.write responses[label]
      runner.stdin.end()  if remaining is 0
      return

    runner.stderr.on "data", (chunk) ->
      e += chunk
      return

    return

  return

test "npm login --always-auth", (t) ->
  mr
    port: common.port
    mocks: mocks
  , (s) ->
    runner = common.npm([
      "login"
      "--registry"
      common.registry
      "--loglevel"
      "silent"
      "--userconfig"
      outfile
      "--always-auth"
    ], opts, (err, code) ->
      t.notOk code, "exited OK"
      t.notOk err, "no error output"
      config = fs.readFileSync(outfile, "utf8")
      t.like config, /:always-auth=true/, "always-auth is scoped and true"
      s.close()
      rimraf outfile, (err) ->
        t.ifError err, "removed config file OK"
        t.end()
        return

      return
    )
    o = ""
    e = ""
    remaining = Object.keys(responses).length
    runner.stdout.on "data", (chunk) ->
      remaining--
      o += chunk
      label = chunk.toString("utf8").split(":")[0]
      runner.stdin.write responses[label]
      runner.stdin.end()  if remaining is 0
      return

    runner.stderr.on "data", (chunk) ->
      e += chunk
      return

    return

  return

test "npm login --no-always-auth", (t) ->
  mr
    port: common.port
    mocks: mocks
  , (s) ->
    runner = common.npm([
      "login"
      "--registry"
      common.registry
      "--loglevel"
      "silent"
      "--userconfig"
      outfile
      "--no-always-auth"
    ], opts, (err, code) ->
      t.notOk code, "exited OK"
      t.notOk err, "no error output"
      config = fs.readFileSync(outfile, "utf8")
      t.like config, /:always-auth=false/, "always-auth is scoped and false"
      s.close()
      rimraf outfile, (err) ->
        t.ifError err, "removed config file OK"
        t.end()
        return

      return
    )
    o = ""
    e = ""
    remaining = Object.keys(responses).length
    runner.stdout.on "data", (chunk) ->
      remaining--
      o += chunk
      label = chunk.toString("utf8").split(":")[0]
      runner.stdin.write responses[label]
      runner.stdin.end()  if remaining is 0
      return

    runner.stderr.on "data", (chunk) ->
      e += chunk
      return

    return

  return

test "cleanup", (t) ->
  rimraf.sync outfile
  t.pass "cleaned up"
  t.end()
  return

