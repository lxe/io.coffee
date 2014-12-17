test = require("tap").test
path = require("path")
fix = path.resolve(__dirname, "..", "fixtures", "config")
projectRc = path.resolve(fix, ".npmrc")
npmconf = require("../../lib/config/core.js")
common = require("./00-config-setup.js")
projectData = just: "testing"
ucData = common.ucData
envData = common.envData
envDataFix = common.envDataFix
gcData = "package-config:foo": "boo"
biData = {}
cli =
  foo: "bar"
  umask: 022
  prefix: fix

expectList = [
  cli
  envDataFix
  projectData
  ucData
  gcData
  biData
]
expectSources =
  cli:
    data: cli

  env:
    data: envDataFix
    source: envData
    prefix: ""

  project:
    path: projectRc
    type: "ini"
    data: projectData

  user:
    path: common.userconfig
    type: "ini"
    data: ucData

  global:
    path: common.globalconfig
    type: "ini"
    data: gcData

  builtin:
    data: biData

test "no builtin", (t) ->
  npmconf.load cli, (er, conf) ->
    throw er  if er
    t.same conf.list, expectList
    t.same conf.sources, expectSources
    t.same npmconf.rootConf.list, []
    t.equal npmconf.rootConf.root, npmconf.defs.defaults
    t.equal conf.root, npmconf.defs.defaults
    t.equal conf.get("umask"), 022
    t.equal conf.get("heading"), "npm"
    t.end()
    return

  return

