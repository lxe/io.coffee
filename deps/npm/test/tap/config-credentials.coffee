test = require("tap").test
npmconf = require("../../lib/config/core.js")
common = require("./00-config-setup.js")
URI = "https://registry.lvh.me:8661/"
test "getting scope with no credentials set", (t) ->
  npmconf.load {}, (er, conf) ->
    t.ifError er, "configuration loaded"
    basic = conf.getCredentialsByURI(URI)
    t.equal basic.scope, "//registry.lvh.me:8661/", "nerfed URL extracted"
    t.end()
    return

  return

test "trying to set credentials with no URI", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    t.throws (->
      conf.setCredentialsByURI()
      return
    ), "enforced missing URI"
    t.end()
    return

  return

test "set with missing credentials object", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    t.throws (->
      conf.setCredentialsByURI URI
      return
    ), "enforced missing credentials"
    t.end()
    return

  return

test "set with empty credentials object", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    t.throws (->
      conf.setCredentialsByURI URI, {}
      return
    ), "enforced missing credentials"
    t.end()
    return

  return

test "set with token", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    t.doesNotThrow (->
      conf.setCredentialsByURI URI,
        token: "simple-token"

      return
    ), "needs only token"
    expected =
      scope: "//registry.lvh.me:8661/"
      token: "simple-token"
      username: `undefined`
      password: `undefined`
      email: `undefined`
      auth: `undefined`
      alwaysAuth: `undefined`

    t.same conf.getCredentialsByURI(URI), expected, "got bearer token and scope"
    t.end()
    return

  return

test "set with missing username", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    credentials =
      password: "password"
      email: "ogd@aoaioxxysz.net"

    t.throws (->
      conf.setCredentialsByURI URI, credentials
      return
    ), "enforced missing email"
    t.end()
    return

  return

test "set with missing password", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    credentials =
      username: "username"
      email: "ogd@aoaioxxysz.net"

    t.throws (->
      conf.setCredentialsByURI URI, credentials
      return
    ), "enforced missing email"
    t.end()
    return

  return

test "set with missing email", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    credentials =
      username: "username"
      password: "password"

    t.throws (->
      conf.setCredentialsByURI URI, credentials
      return
    ), "enforced missing email"
    t.end()
    return

  return

test "set with old-style credentials", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    credentials =
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"

    t.doesNotThrow (->
      conf.setCredentialsByURI URI, credentials
      return
    ), "requires all of username, password, and email"
    expected =
      scope: "//registry.lvh.me:8661/"
      token: `undefined`
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"
      auth: "dXNlcm5hbWU6cGFzc3dvcmQ="
      alwaysAuth: false

    t.same conf.getCredentialsByURI(URI), expected, "got credentials"
    t.end()
    return

  return

test "get old-style credentials for default registry", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    actual = conf.getCredentialsByURI(conf.get("registry"))
    expected =
      scope: "//registry.npmjs.org/"
      token: `undefined`
      password: "password"
      username: "username"
      email: "i@izs.me"
      auth: "dXNlcm5hbWU6cGFzc3dvcmQ="
      alwaysAuth: false

    t.same actual, expected
    t.end()
    return

  return

test "set with always-auth enabled", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    credentials =
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"
      alwaysAuth: true

    conf.setCredentialsByURI URI, credentials
    expected =
      scope: "//registry.lvh.me:8661/"
      token: `undefined`
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"
      auth: "dXNlcm5hbWU6cGFzc3dvcmQ="
      alwaysAuth: true

    t.same conf.getCredentialsByURI(URI), expected, "got credentials"
    t.end()
    return

  return

test "set with always-auth disabled", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    credentials =
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"
      alwaysAuth: false

    conf.setCredentialsByURI URI, credentials
    expected =
      scope: "//registry.lvh.me:8661/"
      token: `undefined`
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"
      auth: "dXNlcm5hbWU6cGFzc3dvcmQ="
      alwaysAuth: false

    t.same conf.getCredentialsByURI(URI), expected, "got credentials"
    t.end()
    return

  return

test "set with global always-auth enabled", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    original = conf.get("always-auth")
    conf.set "always-auth", true
    credentials =
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"

    conf.setCredentialsByURI URI, credentials
    expected =
      scope: "//registry.lvh.me:8661/"
      token: `undefined`
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"
      auth: "dXNlcm5hbWU6cGFzc3dvcmQ="
      alwaysAuth: true

    t.same conf.getCredentialsByURI(URI), expected, "got credentials"
    conf.set "always-auth", original
    t.end()
    return

  return

test "set with global always-auth disabled", (t) ->
  npmconf.load common.builtin, (er, conf) ->
    t.ifError er, "configuration loaded"
    original = conf.get("always-auth")
    conf.set "always-auth", false
    credentials =
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"

    conf.setCredentialsByURI URI, credentials
    expected =
      scope: "//registry.lvh.me:8661/"
      token: `undefined`
      username: "username"
      password: "password"
      email: "ogd@aoaioxxysz.net"
      auth: "dXNlcm5hbWU6cGFzc3dvcmQ="
      alwaysAuth: false

    t.same conf.getCredentialsByURI(URI), expected, "got credentials"
    conf.set "always-auth", original
    t.end()
    return

  return

