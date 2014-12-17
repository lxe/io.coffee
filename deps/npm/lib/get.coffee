get = (args, cb) ->
  npm.commands.config ["get"].concat(args), cb
  return
module.exports = get
get.usage = "npm get <key> <value> (See `npm config`)"
npm = require("./npm.js")
get.completion = npm.commands.config.completion
