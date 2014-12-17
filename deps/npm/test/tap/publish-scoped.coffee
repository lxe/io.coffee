fs = require("fs")
path = require("path")
test = require("tap").test
mkdirp = require("mkdirp")
rimraf = require("rimraf")
nock = require("nock")
npm = require("../../")
common = require("../common-tap.js")
pkg = path.join(__dirname, "prepublish_package")

# TODO: nock uses setImmediate, breaks 0.8: replace with mockRegistry
unless global.setImmediate
  global.setImmediate = ->
    args = [
      arguments[0]
      0
    ].concat([].slice.call(arguments, 1))
    setTimeout.apply this, args
    return
test "setup", (t) ->
  next = ->
    process.chdir pkg
    fs.writeFile path.join(pkg, "package.json"), JSON.stringify(
      name: "@bigco/publish-organized"
      version: "1.2.5"
    ), "ascii", (er) ->
      t.ifError er
      t.pass "setup done"
      t.end()
      return

    return
  mkdirp path.join(pkg, "cache"), next
  return

test "npm publish should honor scoping", (t) ->
  onload = (er) ->
    t.ifError er, "npm bootstrapped successfully"
    npm.config.set "@bigco:registry", common.registry
    npm.commands.publish [], false, (er) ->
      t.ifError er, "published without error"
      put.done()
      t.end()
      return

    return
  verify = (_, body) ->
    t.doesNotThrow (->
      parsed = JSON.parse(body)
      current = parsed.versions["1.2.5"]
      t.equal current._npmVersion, require(path.resolve(__dirname, "../../package.json")).version, "npm version is correct"
      t.equal current._nodeVersion, process.versions.node, "node version is correct"
      return
    ), "converted body back into object"
    ok: true
  put = nock(common.registry).put("/@bigco%2fpublish-organized").reply(201, verify)
  configuration =
    cache: path.join(pkg, "cache")
    loglevel: "silent"
    registry: "http://nonexistent.lvh.me"
    "//localhost:1337/:username": "username"
    "//localhost:1337/:_password": new Buffer("password").toString("base64")
    "//localhost:1337/:email": "ogd@aoaioxxysz.net"

  npm.load configuration, onload
  return

test "cleanup", (t) ->
  process.chdir __dirname
  rimraf pkg, (er) ->
    t.ifError er
    t.end()
    return

  return

