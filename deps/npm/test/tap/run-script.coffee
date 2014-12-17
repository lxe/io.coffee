testOutput = (t, command, er, code, stdout, stderr) ->
  lines = undefined
  throw er  if er
  throw new Error("npm " + command + " stderr: " + stderr.toString())  if stderr
  lines = stdout.trim().split("\n")
  stdout = lines.filter((line) ->
    line.trim() isnt "" and line[0] isnt ">"
  ).join(";")
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
pkg = path.resolve(__dirname, "run-script")
cache = path.resolve(pkg, "cache")
tmp = path.resolve(pkg, "tmp")
opts = cwd: pkg
test "setup", (t) ->
  cleanup()
  mkdirp.sync cache
  mkdirp.sync tmp
  t.end()
  return

test "npm run-script", (t) ->
  common.npm [
    "run-script"
    "start"
  ], opts, testOutput.bind(null, t, "start")
  return

test "npm run-script with args", (t) ->
  common.npm [
    "run-script"
    "start"
    "--"
    "stop"
  ], opts, testOutput.bind(null, t, "stop")
  return

test "npm run-script with args that contain spaces", (t) ->
  common.npm [
    "run-script"
    "start"
    "--"
    "hello world"
  ], opts, testOutput.bind(null, t, "hello world")
  return

test "npm run-script with args that contain single quotes", (t) ->
  common.npm [
    "run-script"
    "start"
    "--"
    "they're awesome"
  ], opts, testOutput.bind(null, t, "they're awesome")
  return

test "npm run-script with args that contain double quotes", (t) ->
  common.npm [
    "run-script"
    "start"
    "--"
    "what's \"up\"?"
  ], opts, testOutput.bind(null, t, "what's \"up\"?")
  return

test "npm run-script with pre script", (t) ->
  common.npm [
    "run-script"
    "with-post"
  ], opts, testOutput.bind(null, t, "main;post")
  return

test "npm run-script with post script", (t) ->
  common.npm [
    "run-script"
    "with-pre"
  ], opts, testOutput.bind(null, t, "pre;main")
  return

test "npm run-script with both pre and post script", (t) ->
  common.npm [
    "run-script"
    "with-both"
  ], opts, testOutput.bind(null, t, "pre;main;post")
  return

test "npm run-script with both pre and post script and with args", (t) ->
  common.npm [
    "run-script"
    "with-both"
    "--"
    "an arg"
  ], opts, testOutput.bind(null, t, "pre;an arg;post")
  return

test "npm run-script explicitly call pre script with arg", (t) ->
  common.npm [
    "run-script"
    "prewith-pre"
    "--"
    "an arg"
  ], opts, testOutput.bind(null, t, "an arg")
  return

test "cleanup", (t) ->
  cleanup()
  t.end()
  return

