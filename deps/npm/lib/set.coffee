set = (args, cb) ->
  return cb(set.usage)  unless args.length
  npm.commands.config ["set"].concat(args), cb
  return
module.exports = set
set.usage = "npm set <key> <value> (See `npm config`)"
npm = require("./npm.js")
set.completion = npm.commands.config.completion
