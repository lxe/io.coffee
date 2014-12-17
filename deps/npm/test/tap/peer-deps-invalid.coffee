common = require("../common-tap")
fs = require("fs")
path = require("path")
test = require("tap").test
rimraf = require("rimraf")
npm = require("../../")
mr = require("npm-registry-mock")
pkg = path.resolve(__dirname, "peer-deps-invalid")
cache = path.resolve(pkg, "cache")
nodeModules = path.resolve(pkg, "node_modules")
okFile = fs.readFileSync(path.join(pkg, "file-ok.js"), "utf8")
failFile = fs.readFileSync(path.join(pkg, "file-fail.js"), "utf8")
test "installing dependencies that have conflicting peerDependencies", (t) ->
  rimraf.sync nodeModules
  rimraf.sync cache
  process.chdir pkg
  customMocks = get:
    "/ok.js": [
      200
      okFile
    ]
    "/invalid.js": [
      200
      failFile
    ]

  mr # create mock registry.
    port: common.port
    mocks: customMocks
  , (s) ->
    npm.load
      cache: cache
      registry: common.registry
    , ->
      npm.commands.install [], (err) ->
        unless err
          t.fail "No error!"
        else
          t.equal err.code, "EPEERINVALID"
        t.end()
        s.close() # shutdown mock registry.
        return

      return

    return

  return

test "cleanup", (t) ->
  rimraf.sync nodeModules
  rimraf.sync cache
  t.end()
  return

