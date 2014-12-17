onmessage = (m) ->
  console.log "CHILD got message:", m
  assert.ok m.hello
  process.removeListener "message", onmessage
  return
assert = require("assert")
process.on "message", onmessage
process.send foo: "bar"
