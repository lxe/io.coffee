common = require("../common-tap.js")
test = require("tap").test
http = require("http")
test "should send referer http header", (t) ->
  http.createServer((q, s) ->
    t.equal q.headers.referer, "install foo"
    s.statusCode = 404
    s.end JSON.stringify(error: "whatever")
    @close()
    return
  ).listen common.port, ->
    reg = "http://localhost:" + common.port
    args = [
      "install"
      "foo"
      "--registry"
      reg
    ]
    common.npm args, {}, (er, code) ->
      throw er  if er
      
      # should not have ended nicely, since we returned an error
      t.ok code
      t.end()
      return

    return

  return

