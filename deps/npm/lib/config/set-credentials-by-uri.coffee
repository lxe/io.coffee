setCredentialsByURI = (uri, c) ->
  assert uri and typeof uri is "string", "registry URL is required"
  assert c and typeof c is "object", "credentials are required"
  nerfed = toNerfDart(uri)
  if c.token
    @set nerfed + ":_authToken", c.token, "user"
    @del nerfed + ":_password", "user"
    @del nerfed + ":username", "user"
    @del nerfed + ":email", "user"
    @del nerfed + ":always-auth", "user"
  else if c.username or c.password or c.email
    assert c.username, "must include username"
    assert c.password, "must include password"
    assert c.email, "must include email address"
    @del nerfed + ":_authToken", "user"
    encoded = new Buffer(c.password, "utf8").toString("base64")
    @set nerfed + ":_password", encoded, "user"
    @set nerfed + ":username", c.username, "user"
    @set nerfed + ":email", c.email, "user"
    if c.alwaysAuth isnt `undefined`
      @set nerfed + ":always-auth", c.alwaysAuth, "user"
    else
      @del nerfed + ":always-auth", "user"
  else
    throw new Error("No credentials to set.")
  return
assert = require("assert")
toNerfDart = require("./nerf-dart.js")
module.exports = setCredentialsByURI
