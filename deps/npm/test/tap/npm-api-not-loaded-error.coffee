test = require("tap").test
npm = require("../..")
path = require("path")
rimraf = require("rimraf")
npmrc = path.join(__dirname, "npmrc")
fs = require("fs")
test "setup", (t) ->
  fs.writeFileSync npmrc, "foo = bar\n", "ascii"
  t.end()
  return

test "calling set/get on config pre-load should throw", (t) ->
  threw = true
  try
    npm.config.get "foo"
    threw = false
  catch er
    t.equal er.message, "npm.load() required"
  finally
    t.ok threw, "get before load should throw"
  threw = true
  try
    npm.config.set "foo", "bar"
    threw = false
  catch er
    t.equal er.message, "npm.load() required"
  finally
    t.ok threw, "set before load should throw"
  npm.load
    userconfig: npmrc
  , (er) ->
    throw er  if er
    t.equal npm.config.get("foo"), "bar"
    npm.config.set "foo", "baz"
    t.equal npm.config.get("foo"), "baz"
    t.end()
    return

  return

test "cleanup", (t) ->
  rimraf.sync npmrc
  t.end()
  return

