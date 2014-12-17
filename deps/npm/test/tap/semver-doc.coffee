test = require("tap").test
test "semver doc is up to date", (t) ->
  path = require("path")
  moddoc = path.join(__dirname, "../../node_modules/semver/README.md")
  mydoc = path.join(__dirname, "../../doc/misc/semver.md")
  fs = require("fs")
  mod = fs.readFileSync(moddoc, "utf8").replace(/semver\(1\)/, "semver(7)")
  my = fs.readFileSync(mydoc, "utf8")
  t.equal my, mod
  t.end()
  return

