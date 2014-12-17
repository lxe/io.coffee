# npm explore <pkg>[@<version>]
# open a subshell to the package folder.
explore = (args, cb) ->
  return cb(explore.usage)  if args.length < 1 or not args[0]
  p = args.shift()
  args = args.join(" ").trim()
  if args
    args = [
      "-c"
      args
    ]
  else
    args = []
  cwd = path.resolve(npm.dir, p)
  sh = npm.config.get("shell")
  fs.stat cwd, (er, s) ->
    return cb(new Error("It doesn't look like " + p + " is installed."))  if er or not s.isDirectory()
    console.log "\nExploring " + cwd + "\n" + "Type 'exit' or ^D when finished\n"  unless args.length
    npm.spinner.stop()
    shell = spawn(sh, args,
      cwd: cwd
      stdio: "inherit"
    )
    shell.on "close", (er) ->
      
      # only fail if non-interactive.
      return cb()  unless args.length
      cb er
      return

    return

  return
module.exports = explore
explore.usage = "npm explore <pkg> [ -- <cmd>]"
explore.completion = require("./utils/completion/installed-shallow.js")
npm = require("./npm.js")
spawn = require("child_process").spawn
path = require("path")
fs = require("graceful-fs")
