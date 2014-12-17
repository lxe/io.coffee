npm = require.resolve("../../")
test = require("tap").test
path = require("path")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
mr = require("npm-registry-mock")
common = require("../common-tap.js")
cache = path.resolve(__dirname, "cache-shasum")
spawn = require("child_process").spawn
sha = require("sha")
server = undefined
test "mock reg", (t) ->
  rimraf.sync cache
  mkdirp.sync cache
  mr common.port, (s) ->
    server = s
    t.pass "ok"
    t.end()
    return

  return

test "npm cache add request", (t) ->
  c = spawn(process.execPath, [
    npm
    "cache"
    "add"
    "request@2.27.0"
    "--cache=" + cache
    "--registry=" + common.registry
    "--loglevel=quiet"
  ])
  c.stderr.pipe process.stderr
  c.stdout.on "data", (d) ->
    t.fail "Should not get data on stdout: " + d
    return

  c.on "close", (code) ->
    t.notOk code, "exit ok"
    t.end()
    return

  return

test "compare", (t) ->
  d = path.resolve(__dirname, "cache-shasum/request")
  p = path.resolve(d, "2.27.0/package.tgz")
  r = require("./cache-shasum/localhost_1337/request/.cache.json")
  rshasum = r.versions["2.27.0"].dist.shasum
  sha.get p, (er, pshasum) ->
    throw er  if er
    t.equal pshasum, rshasum
    t.end()
    return

  return

test "cleanup", (t) ->
  server.close()
  rimraf.sync cache
  t.end()
  return

