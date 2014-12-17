common = require("../common-tap")
test = require("tap").test
path = require("path")
cwd = path.resolve(__dirname, "..", "..")
fs = require("fs")
test "npm ls in npm", (t) ->
  t.ok fs.existsSync(cwd), "ensure that the path we are calling ls within exists"
  files = fs.readdirSync(cwd)
  t.notEqual files.length, 0, "ensure there are files in the directory we are to ls"
  opt =
    cwd: cwd
    stdio: [
      "ignore"
      "ignore"
      2
    ]

  common.npm ["ls"], opt, (err, code) ->
    t.ifError err, "error should not exist"
    t.equal code, 0, "npm ls exited with code"
    t.end()
    return

  return

