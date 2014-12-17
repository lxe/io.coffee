# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

# Exception is thrown from vm.js via module.js (internal file)
#   var compiledWrapper = runInThisContext(wrapper, filename, 0, true);

###*
IMPLEMENTATION ****************
###
addScenario = (scriptName, throwsInFile, throwsOnLine) ->
  scenarios = []  unless scenarios
  scenarios.push runScenario.bind(null, scriptName, throwsInFile, throwsOnLine, run)
  return
run = ->
  next = scenarios.shift()
  next()  if next
  return
runScenario = (scriptName, throwsInFile, throwsOnLine, next) ->
  setupClient = (callback) ->
    client = new debug.Client()
    client.once "ready", callback.bind(null, client)
    client.on "unhandledResponse", (body) ->
      console.error "unhandled response: %j", body
      return

    client.on "error", (err) ->
      return  if asserted
      assert.ifError err
      return

    client.connect port
    return
  runTest = (client) ->
    client.req
      command: "setexceptionbreak"
      arguments:
        type: "uncaught"
        enabled: true
    , (error, result) ->
      assert.ifError error
      client.on "exception", (event) ->
        exceptions.push event.body
        return

      client.reqContinue (error, result) ->
        assert.ifError error
        setTimeout assertHasPaused.bind(null, client), 100
        return

      return

    return
  assertHasPaused = (client) ->
    assert.equal exceptions.length, 1, "debugger did not pause on exception"
    assert.equal exceptions[0].uncaught, true
    assert.equal exceptions[0].script.name, throwsInFile or testScript
    assert.equal exceptions[0].sourceLine + 1, throwsOnLine  if throwsOnLine?
    asserted = true
    client.reqContinue assert.ifError
    return
  console.log "**[ %s ]**", scriptName
  asserted = false
  port = common.PORT + 1337
  testScript = path.join(common.fixturesDir, "uncaught-exceptions", scriptName)
  child = spawn(process.execPath, [
    "--debug-brk=" + port
    testScript
  ])
  child.on "close", ->
    assert asserted, "debugger did not pause on exception"
    next()  if next
    return

  exceptions = []
  setTimeout setupClient.bind(null, runTest), 200
  return
path = require("path")
assert = require("assert")
spawn = require("child_process").spawn
common = require("../common")
debug = require("_debugger")
addScenario "global.js", null, 2
addScenario "timeout.js", null, 2
addScenario "domain.js", null, 10
addScenario "parse-error.js", "vm.js", null
run()
scenarios = undefined
