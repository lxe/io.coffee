fs = require("fs")
ini = require("ini")
test = require("tap").test
npmconf = require("../../lib/config/core.js")
common = require("./00-config-setup.js")
expectConf = [
  "globalconfig = " + common.globalconfig
  "email = i@izs.me"
  "env-thing = asdf"
  "init.author.name = Isaac Z. Schlueter"
  "init.author.email = i@izs.me"
  "init.author.url = http://blog.izs.me/"
  "init.version = 1.2.3"
  "proprietary-attribs = false"
  "npm:publishtest = true"
  "_npmjs.org:couch = https://admin:password@localhost:5984/registry"
  "npm-www:nocache = 1"
  "sign-git-tag = false"
  "message = v%s"
  "strict-ssl = false"
  "_auth = dXNlcm5hbWU6cGFzc3dvcmQ="
  ""
  "[_token]"
  "AuthSession = yabba-dabba-doodle"
  "version = 1"
  "expires = 1345001053415"
  "path = /"
  "httponly = true"
  ""
].join("\n")
expectFile = [
  "globalconfig = " + common.globalconfig
  "email = i@izs.me"
  "env-thing = asdf"
  "init.author.name = Isaac Z. Schlueter"
  "init.author.email = i@izs.me"
  "init.author.url = http://blog.izs.me/"
  "init.version = 1.2.3"
  "proprietary-attribs = false"
  "npm:publishtest = true"
  "_npmjs.org:couch = https://admin:password@localhost:5984/registry"
  "npm-www:nocache = 1"
  "sign-git-tag = false"
  "message = v%s"
  "strict-ssl = false"
  "_auth = dXNlcm5hbWU6cGFzc3dvcmQ="
  ""
  "[_token]"
  "AuthSession = yabba-dabba-doodle"
  "version = 1"
  "expires = 1345001053415"
  "path = /"
  "httponly = true"
  ""
].join("\n")
test "saving configs", (t) ->
  npmconf.load (er, conf) ->
    throw er  if er
    conf.set "sign-git-tag", false, "user"
    conf.del "nodedir"
    conf.del "tmp"
    foundConf = ini.stringify(conf.sources.user.data)
    t.same ini.parse(foundConf), ini.parse(expectConf)
    fs.unlinkSync common.userconfig
    conf.save "user", (er) ->
      throw er  if er
      uc = fs.readFileSync(conf.get("userconfig"), "utf8")
      t.same ini.parse(uc), ini.parse(expectFile)
      t.end()
      return

    return

  return

test "setting prefix", (t) ->
  npmconf.load (er, conf) ->
    throw er  if er
    conf.prefix = "newvalue"
    t.same conf.prefix, "newvalue"
    t.end()
    return

  return

