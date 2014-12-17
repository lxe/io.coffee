assert = require("assert")
fs = require("fs")
saneEmitter = undefined
sanity = "ire('assert')"
saneEmitter = fs.createReadStream(__filename,
  start: 17
  end: 29
)
assert.throws (->
  fs.createReadStream __filename,
    start: "17"
    end: 29

  return
), "start as string didn't throw an error for createReadStream"
assert.throws (->
  fs.createReadStream __filename,
    start: 17
    end: "29"

  return
), "end as string didn't throw an error"
assert.throws (->
  fs.createWriteStream __filename,
    start: "17"

  return
), "start as string didn't throw an error for createWriteStream"
saneEmitter.on "data", (data) ->
  
  # a sanity check when using numbers instead of strings
  assert.strictEqual sanity, data.toString("utf8"), "read " + data.toString("utf8") + " instead of " + sanity
  return

