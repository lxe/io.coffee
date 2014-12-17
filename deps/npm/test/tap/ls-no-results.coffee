test = require("tap").test
spawn = require("child_process").spawn
node = process.execPath
npm = require.resolve("../../")
args = [
  npm
  "ls"
  "ceci n’est pas une package"
]
test "ls exits non-zero when nothing found", (t) ->
  child = spawn(node, args)
  child.on "exit", (code) ->
    t.notEqual code, 0
    t.end()
    return

  return

