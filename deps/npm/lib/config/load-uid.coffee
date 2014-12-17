
# Call in the context of a npmconf object
loadUid = (cb) ->
  
  # if we're not in unsafe-perm mode, then figure out who
  # to run stuff as.  Do this first, to support `npm update npm -g`
  unless @get("unsafe-perm")
    getUid @get("user"), @get("group"), cb
  else
    process.nextTick cb
  return
module.exports = loadUid
getUid = require("uid-number")
