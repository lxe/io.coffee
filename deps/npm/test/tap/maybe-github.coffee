require "../common-tap.js"
test = require("tap").test
npm = require("../../lib/npm.js")

# this is the narrowest way to replace a function in the module cache
found = true
remoteGitPath = require.resolve("../../lib/cache/add-remote-git.js")
require("module")._cache[remoteGitPath] =
  id: remoteGitPath
  exports: stub = (_, __, cb) ->
    if found
      cb null, {}
    else
      cb new Error("not on filesystem")
    return


# only load maybeGithub now, so it gets the stub from cache
maybeGithub = require("../../lib/cache/maybe-github.js")
test "should throw with no parameters", (t) ->
  t.plan 1
  t.throws (->
    maybeGithub()
    return
  ), "throws when called without parameters"
  return

test "should throw with wrong parameter types", (t) ->
  t.plan 2
  t.throws (->
    maybeGithub {}, ->

    return
  ), "expects only a package name"
  t.throws (->
    maybeGithub "npm/xxx-noexist", "ham"
    return
  ), "is always async"
  return

test "should find an existing package on Github", (t) ->
  found = true
  npm.load {}, (error) ->
    t.notOk error, "bootstrapping succeeds"
    t.doesNotThrow ->
      maybeGithub "npm/npm", (error, data) ->
        t.notOk error, "no issues in looking things up"
        t.ok data, "received metadata from Github"
        t.end()
        return

      return

    return

  return

test "shouldn't find a nonexistent package on Github", (t) ->
  found = false
  npm.load {}, ->
    t.doesNotThrow ->
      maybeGithub "npm/xxx-noexist", (error, data) ->
        t.equal error.message, "not on filesystem", "passed through original error message"
        t.notOk data, "didn't pass any metadata"
        t.end()
        return

      return

    return

  return

