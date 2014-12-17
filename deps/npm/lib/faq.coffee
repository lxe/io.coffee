faq = (args, cb) ->
  npm.commands.help ["faq"], cb
  return
module.exports = faq
faq.usage = "npm faq"
npm = require("./npm.js")
