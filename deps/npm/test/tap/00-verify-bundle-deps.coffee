fs = require("fs")
path = require("path")
test = require("tap").test
manifest = require("../../package.json")
deps = Object.keys(manifest.dependencies)
dev = Object.keys(manifest.devDependencies)
bundled = manifest.bundleDependencies
test "all deps are bundled deps or dev deps", (t) ->
  deps.forEach (name) ->
    t.assert bundled.indexOf(name) isnt -1, name + " is in bundledDependencies"
    return

  t.same fs.readdirSync(path.resolve(__dirname, "../../node_modules")).filter((name) ->
    (dev.indexOf(name) is -1) and (name isnt ".bin")
  ).sort(), bundled.sort(), "bundleDependencies matches what's in node_modules"
  t.end()
  return

