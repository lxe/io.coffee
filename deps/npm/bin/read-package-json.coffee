argv = process.argv
if argv.length < 3
  console.error "Usage: read-package.json <file> [<fields> ...]"
  process.exit 1
fs = require("fs")
file = argv[2]
readJson = require("read-package-json")
readJson file, (er, data) ->
  throw er  if er
  if argv.length is 3
    console.log data
  else
    argv.slice(3).forEach (field) ->
      field = field.split(".")
      val = data
      field.forEach (f) ->
        val = val[f]
        return

      console.log val
      return

  return

