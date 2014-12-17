test = require("tap").test
common = require("../common-tap.js")
path = require("path")
rimraf = require("rimraf")
pkg = path.resolve(__dirname, "lifecycle-path")
fs = require("fs")
link = path.resolve(pkg, "node-bin")

# Without the path to the shell, nothing works usually.
PATH = undefined
if process.platform is "win32"
  PATH = "C:\\Windows\\system32;C:\\Windows"
else
  PATH = "/bin:/usr/bin"
test "setup", (t) ->
  rimraf.sync link
  fs.symlinkSync path.dirname(process.execPath), link, "dir"
  t.end()
  return

test "make sure the path is correct", (t) ->
  common.npm [
    "run-script"
    "path"
  ],
    cwd: pkg
    env:
      PATH: PATH
      stdio: [
        0
        "pipe"
        2
      ]
  , (er, code, stdout) ->
    throw er  if er
    t.equal code, 0, "exit code"
    
    # remove the banner, we just care about the last line
    stdout = stdout.trim().split(/\r|\n/).pop()
    pathSplit = (if process.platform is "win32" then ";" else ":")
    root = path.resolve(__dirname, "../..")
    actual = stdout.split(pathSplit).map((p) ->
      p = "{{ROOT}}" + p.substr(root.length)  if p.indexOf(root) is 0
      p.replace /\\/g, "/"
    )
    
    # get the ones we tacked on, then the system-specific requirements
    expect = [
      "{{ROOT}}/bin/node-gyp-bin"
      "{{ROOT}}/test/tap/lifecycle-path/node_modules/.bin"
    ].concat(PATH.split(pathSplit).map((p) ->
      p.replace /\\/g, "/"
    ))
    t.same actual, expect
    t.end()
    return

  return

test "clean", (t) ->
  rimraf.sync link
  t.end()
  return

