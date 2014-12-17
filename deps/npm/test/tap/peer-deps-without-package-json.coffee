common = require("../common-tap")
fs = require("fs")
path = require("path")
test = require("tap").test
rimraf = require("rimraf")
npm = require("../../")
mr = require("npm-registry-mock")
pkg = path.resolve(__dirname, "peer-deps-without-package-json")
cache = path.resolve(pkg, "cache")
nodeModules = path.resolve(pkg, "node_modules")
js = fs.readFileSync(path.join(pkg, "file-js.js"), "utf8")
test "installing a peerDependencies-using package without a package.json present (GH-3049)", (t) ->
  rimraf.sync nodeModules
  rimraf.sync cache
  fs.mkdirSync nodeModules
  process.chdir pkg
  customMocks = get:
    "/ok.js": [
      200
      js
    ]

  mr # create mock registry.
    port: common.port
    mocks: customMocks
  , (s) ->
    npm.load
      registry: common.registry
      cache: cache
    , ->
      npm.install common.registry + "/ok.js", (err) ->
        if err
          t.fail err
        else
          t.ok fs.existsSync(path.join(nodeModules, "/npm-test-peer-deps-file"))
          t.ok fs.existsSync(path.join(nodeModules, "/underscore"))
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

