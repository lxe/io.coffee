# Run all the tests in the `npm-registry-couchapp` suite
# This verifies that the server-side stuff still works.
runTests = ->
  env = {}
  for i of process.env
    env[i] = process.env[i]
  env.npm = npmExec
  opts =
    cwd: ca
    stdio: "inherit"

  common.npm ["install"], opts, (err, code) ->
    throw err  if err
    if code
      test "need install to work", (t) ->
        t.fail "install failed with: " + code
        t.end()
        return

    else
      opts =
        cwd: ca
        env: env
        stdio: "inherit"

      common.npm ["test"], opts, (err, code) ->
        throw err  if err
        if code
          return test("need test to work", (t) ->
            t.fail "test failed with: " + code
            t.end()
            return
          )
        opts =
          cwd: ca
          env: env
          stdio: "inherit"

        common.npm [
          "prune"
          "--production"
        ], opts, (err, code) ->
          throw err  if err
          process.exit code or 0
          return

        return

    return

  return
common = require("../common-tap")
test = require("tap").test
npmExec = require.resolve("../../bin/npm-cli.js")
path = require("path")
ca = path.resolve(__dirname, "../../node_modules/npm-registry-couchapp")
which = require("which")
v = process.versions.node.split(".").map((n) ->
  parseInt n, 10
)
if v[0] is 0 and v[1] < 10
  console.error "WARNING: need a recent Node for npm-registry-couchapp tests to run, have", process.versions.node
else
  which "couchdb", (er) ->
    if er
      console.error "WARNING: need couch to run test: " + er.message
    else
      runTests()
    return

