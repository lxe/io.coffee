cleanup = ->
  try
    pid = +fs.readFileSync(pidfile)
    process.kill pid, "SIGKILL"
  rimraf.sync cache
  rimraf.sync nm
  rimraf.sync pidfile
  return
test = require("tap").test
rimraf = require("rimraf")
common = require("../common-tap.js")
path = require("path")
fs = require("fs")
pkg = path.resolve(__dirname, "optional-metadep-rollback-collision")
nm = path.resolve(pkg, "node_modules")
cache = path.resolve(pkg, "cache")
pidfile = path.resolve(pkg, "child.pid")
test "setup", (t) ->
  cleanup()
  t.end()
  return

test "go go test racer", (t) ->
  common.npm [
    "install"
    "--prefix=" + pkg
    "--fetch-retries=0"
    "--cache=" + cache
  ],
    cwd: pkg
    env:
      PATH: process.env.PATH
      Path: process.env.Path
      npm_config_loglevel: "silent"

    stdio: [
      0
      "pipe"
      2
    ]
  , (er, code, sout) ->
    throw er  if er
    t.notOk code, "npm install exited with code 0"
    t.equal sout, "ok\nok\n"
    t.notOk /not ok/.test(sout), "should not contain the string 'not ok'"
    t.end()
    return

  return

test "verify results", (t) ->
  t.throws ->
    fs.statSync nm
    return

  t.end()
  return

test "cleanup", (t) ->
  cleanup()
  t.end()
  return

