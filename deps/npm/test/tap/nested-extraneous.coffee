common = require("../common-tap.js")
test = require("tap").test
mkdirp = require("mkdirp")
fs = require("fs")
rimraf = require("rimraf")
path = require("path")
pkg = path.resolve(__dirname, "nested-extraneous")
pj =
  name: "nested-extraneous"
  version: "1.2.3"

dep = path.resolve(pkg, "node_modules", "dep")
deppj =
  name: "nested-extraneous-dep"
  version: "1.2.3"
  dependencies:
    "nested-extra-depdep": "*"

depdep = path.resolve(dep, "node_modules", "depdep")
depdeppj =
  name: "nested-extra-depdep"
  version: "1.2.3"

test "setup", (t) ->
  rimraf.sync pkg
  mkdirp.sync depdep
  fs.writeFileSync path.resolve(pkg, "package.json"), JSON.stringify(pj)
  fs.writeFileSync path.resolve(dep, "package.json"), JSON.stringify(deppj)
  fs.writeFileSync path.resolve(depdep, "package.json"), JSON.stringify(depdeppj)
  t.end()
  return

test "test", (t) ->
  common.npm ["ls"],
    cwd: pkg
  , (er, code, sto, ste) ->
    throw er  if er
    t.notEqual code, 0
    t.notSimilar ste, /depdep/
    t.notSimilar sto, /depdep/
    t.end()
    return

  return

test "clean", (t) ->
  rimraf.sync pkg
  t.end()
  return

