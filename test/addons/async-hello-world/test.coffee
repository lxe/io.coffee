assert = require("assert")
binding = require("./build/Release/binding")
called = false
process.on "exit", ->
  assert called
  return

binding 5, (err, val) ->
  assert.equal null, err
  assert.equal 10, val
  process.nextTick ->
    called = true
    return

  return

