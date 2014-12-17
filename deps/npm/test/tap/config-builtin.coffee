test = require("tap").test
npmconf = require("../../lib/config/core.js")
common = require("./00-config-setup.js")
path = require("path")
ucData = common.ucData
envData = common.envData
envDataFix = common.envDataFix
gcData = "package-config:foo": "boo"
biData = "builtin-config": true
cli =
  foo: "bar"
  heading: "foo"
  "git-tag-version": false

projectData =
  "save-prefix": "~"
  "proprietary-attribs": false

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
    path: path.resolve(__dirname, "..", "..", ".npmrc")
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

test "with builtin", (t) ->
  npmconf.load cli, common.builtin, (er, conf) ->
    throw er  if er
    t.same conf.list, expectList
    t.same conf.sources, expectSources
    t.same npmconf.rootConf.list, []
    t.equal npmconf.rootConf.root, npmconf.defs.defaults
    t.equal conf.root, npmconf.defs.defaults
    t.equal conf.get("heading"), "foo"
    t.equal conf.get("git-tag-version"), false
    t.end()
    return

  return

