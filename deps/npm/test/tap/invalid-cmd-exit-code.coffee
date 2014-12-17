test = require("tap").test
common = require("../common-tap.js")
opts = cwd: process.cwd()
test "npm asdf should return exit code 1", (t) ->
  common.npm ["asdf"], opts, (er, c) ->
    throw er  if er
    t.ok c, "exit code should not be zero"
    t.end()
    return

  return

test "npm help should return exit code 0", (t) ->
  common.npm ["help"], opts, (er, c) ->
    throw er  if er
    t.equal c, 0, "exit code should be 0"
    t.end()
    return

  return

test "npm help fadf should return exit code 0", (t) ->
  common.npm [
    "help"
    "fadf"
  ], opts, (er, c) ->
    throw er  if er
    t.equal c, 0, "exit code should be 0"
    t.end()
    return

  return

