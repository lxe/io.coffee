test = (args, cb) ->
  testCmd args, (er) ->
    return cb()  unless er
    return cb("Test failed.  See above for more details.")  if er.code is "ELIFECYCLE"
    cb er

  return
module.exports = test
testCmd = require("./utils/lifecycle.js").cmd("test")
