createChild = (ignoreShrinkwrap) ->
  args = undefined
  if ignoreShrinkwrap
    args = [
      npm
      "install"
      "--no-shrinkwrap"
    ]
  else
    args = [
      npm
      "install"
    ]
  spawn node, args,
    cwd: pkg
    env:
      npm_config_registry: common.registry
      npm_config_cache_lock_stale: 1000
      npm_config_cache_lock_wait: 1000
      HOME: process.env.HOME
      Path: process.env.PATH
      PATH: process.env.PATH

common = require("../common-tap.js")
test = require("tap").test
pkg = require("path").join(__dirname, "ignore-shrinkwrap")
mr = require("npm-registry-mock")
spawn = require("child_process").spawn
npm = require.resolve("../../bin/npm-cli.js")
node = process.execPath
customMocks = get:
  "/package.js": [
    200
    {
      ente: true
    }
  ]
  "/shrinkwrap.js": [
    200
    {
      ente: true
    }
  ]

test "ignore-shrinkwrap: using the option", (t) ->
  mr
    port: common.port
    mocks: customMocks
  , (s) ->
    s._server.on "request", (req) ->
      switch req.url
        when "/shrinkwrap.js"
          t.fail()
        when "/package.js"
          t.pass "package.json used"
      return

    child = createChild(true)
    child.on "close", ->
      s.close()
      t.end()
      return

    return

  return

test "ignore-shrinkwrap: NOT using the option", (t) ->
  mr
    port: common.port
    mocks: customMocks
  , (s) ->
    s._server.on "request", (req) ->
      switch req.url
        when "/shrinkwrap.js"
          t.pass "shrinkwrap used"
        when "/package.js"
          t.fail()
      return

    child = createChild(false)
    child.on "close", ->
      s.close()
      t.end()
      return

    return

  return

