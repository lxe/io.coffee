getCredentialsByURI = (uri) ->
  assert uri and typeof uri is "string", "registry URL is required"
  nerfed = toNerfDart(uri)
  defnerf = toNerfDart(@get("registry"))
  
  # hidden class micro-optimization
  c =
    scope: nerfed
    token: `undefined`
    password: `undefined`
    username: `undefined`
    email: `undefined`
    auth: `undefined`
    alwaysAuth: `undefined`

  if @get(nerfed + ":_authToken")
    c.token = @get(nerfed + ":_authToken")
    
    # the bearer token is enough, don't confuse things
    return c
  
  # Handle the old-style _auth=<base64> style for the default
  # registry, if set.
  #
  # XXX(isaacs): Remove when npm 1.4 is no longer relevant
  authDef = @get("_auth")
  userDef = @get("username")
  passDef = @get("_password")
  if authDef and not (userDef and passDef)
    authDef = new Buffer(authDef, "base64").toString()
    authDef = authDef.split(":")
    userDef = authDef.shift()
    passDef = authDef.join(":")
  if @get(nerfed + ":_password")
    c.password = new Buffer(@get(nerfed + ":_password"), "base64").toString("utf8")
  else c.password = passDef  if nerfed is defnerf and passDef
  if @get(nerfed + ":username")
    c.username = @get(nerfed + ":username")
  else c.username = userDef  if nerfed is defnerf and userDef
  if @get(nerfed + ":email")
    c.email = @get(nerfed + ":email")
  else c.email = @get("email")  if @get("email")
  if @get(nerfed + ":always-auth") isnt `undefined`
    val = @get(nerfed + ":always-auth")
    c.alwaysAuth = (if val is "false" then false else !!val)
  else c.alwaysAuth = @get("always-auth")  if @get("always-auth") isnt `undefined`
  c.auth = new Buffer(c.username + ":" + c.password).toString("base64")  if c.username and c.password
  c
assert = require("assert")
toNerfDart = require("./nerf-dart.js")
module.exports = getCredentialsByURI
