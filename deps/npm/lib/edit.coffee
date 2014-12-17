# npm edit <pkg>[@<version>]
# open the package folder in the $EDITOR
edit = (args, cb) ->
  p = args[0]
  return cb(edit.usage)  if args.length isnt 1 or not p
  e = npm.config.get("editor")
  return cb(new Error("No editor set.  Set the 'editor' config, or $EDITOR environ."))  unless e
  p = p.split("/").join("/node_modules/").replace(/(\/node_modules)+/, "/node_modules")
  f = path.resolve(npm.dir, p)
  fs.lstat f, (er) ->
    return cb(er)  if er
    editor f,
      editor: e
    , (er) ->
      return cb(er)  if er
      npm.commands.rebuild args, cb
      return

    return

  return
module.exports = edit
edit.usage = "npm edit <pkg>"
edit.completion = require("./utils/completion/installed-shallow.js")
npm = require("./npm.js")
path = require("path")
fs = require("graceful-fs")
editor = require("editor")
