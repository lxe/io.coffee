domain = require("domain")
d = domain.create()
d.on "error", (err) ->
  console.log "[ignored]", err.stack
  return

d.run ->
  setImmediate ->
    throw new Error("in domain")return

  return

