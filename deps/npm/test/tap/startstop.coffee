testOutput = (t, command, er, code, stdout, stderr) ->
  t.notOk code, "npm " + command + " exited with code 0"
  throw new Error("npm " + command + " stderr: " + stderr.toString())  if stderr
  stdout = stdout.trim().split(/\n|\r/)
  stdout = stdout[stdout.length - 1]
  t.equal stdout, command
  t.end()
  return
cleanup = ->
  rimraf.sync cache
  rimraf.sync tmp
  return
common = require("../common-tap")
test = require("tap").test
path = require("path")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = path.resolve(__dirname, "startstop")
cache = path.resolve(pkg, "cache")
tmp = path.resolve(pkg, "tmp")
opts = cwd: pkg
test "setup", (t) ->
  cleanup()
  mkdirp.sync cache
  mkdirp.sync tmp
  t.end()
  return

test "npm start", (t) ->
  common.npm ["start"], opts, testOutput.bind(null, t, "start")
  return

test "npm stop", (t) ->
  common.npm ["stop"], opts, testOutput.bind(null, t, "stop")
  return

test "npm restart", (t) ->
  common.npm ["restart"], opts, (er, c, stdout) ->
    throw er  if er
    output = stdout.split("\n").filter((val) ->
      val.match /^s/
    )
    t.same output.sort(), [
      "start"
      "stop"
    ].sort()
    t.end()
    return

  return

test "cleanup", (t) ->
  cleanup()
  t.end()
  return

