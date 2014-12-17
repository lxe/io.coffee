assert = require("assert")
assert.throws (->
  process.binding "test"
  return
), /No such module: test/
assert.doesNotThrow (->
  process.binding "buffer"
  return
), ((err) ->
  true  if err instanceof Error
), "unexpected error"
