test = require("tap").test
npm = require("../../")
lifecycle = require("../../lib/utils/lifecycle")
test "lifecycle: make env correctly", (t) ->
  npm.load
    enteente: Infinity
  , ->
    env = lifecycle.makeEnv({}, null, process.env)
    t.equal "Infinity", env.npm_config_enteente
    t.end()
    return

  return

