# This test ensures that a few commands do the same
# thing when the cwd is where package.json is, and when
# the package.json is one level up.
test = require("tap").test
common = require("../common-tap.js")
path = require("path")
root = path.resolve(__dirname, "../..")
lib = path.resolve(root, "lib")
commands = [
  "run"
  "version"
]
commands.forEach (cmd) ->
  
  # Should get the same stdout and stderr each time
  stdout = undefined
  stderr = undefined
  test cmd + " in root", (t) ->
    common.npm [cmd],
      cwd: root
    , (er, code, so, se) ->
      throw er  if er
      t.notOk code, "npm " + cmd + " exited with code 0"
      stdout = so
      stderr = se
      t.end()
      return

    return

  test cmd + " in lib", (t) ->
    common.npm [cmd],
      cwd: lib
    , (er, code, so, se) ->
      throw er  if er
      t.notOk code, "npm " + cmd + " exited with code 0"
      t.equal so, stdout
      t.equal se, stderr
      t.end()
      return

    return

  return

