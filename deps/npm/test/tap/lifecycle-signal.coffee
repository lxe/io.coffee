test = require("tap").test
npm = require.resolve("../../bin/npm-cli.js")
node = process.execPath
spawn = require("child_process").spawn
path = require("path")
pkg = path.resolve(__dirname, "lifecycle-signal")
test "lifecycle signal abort", (t) ->
  
  # windows does not use lifecycle signals, abort
  return t.end()  if process.platform is "win32" or process.env.TRAVIS
  child = spawn(node, [
    npm
    "install"
  ],
    cwd: pkg
  )
  child.on "close", (code, signal) ->
    
    # GNU shell returns a code, no signal
    if process.platform is "linux"
      t.equal code, 1
      t.equal signal, null
      return t.end()
    t.equal code, null
    t.equal signal, "SIGSEGV"
    t.end()
    return

  return

