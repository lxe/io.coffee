adduser = (args, cb) ->
  loop = (er) ->
    return cb(er)  if er
    fn = fns.shift()
    return fn(c, u, loop_)  if fn
    cb()
    return
  npm.spinner.stop()
  return cb(new Error("You must compile node with ssl support to use the adduser feature"))  unless crypto
  creds = npm.config.getCredentialsByURI(npm.config.get("registry"))
  c =
    u: creds.username or ""
    p: creds.password or ""
    e: creds.email or ""

  u = {}
  fns = [
    readUsername
    readPassword
    readEmail
    save
  ]
  loop_()
  return
readUsername = (c, u, cb) ->
  v = userValidate.username
  read
    prompt: "Username: "
    default: c.u or ""
  , (er, un) ->
    return cb((if er.message is "cancelled" then er.message else er))  if er
    
    # make sure it's valid.  we have to do this here, because
    # couchdb will only ever say "bad password" with a 401 when
    # you try to PUT a _users record that the validate_doc_update
    # rejects for *any* reason.
    return readUsername(c, u, cb)  unless un
    error = v(un)
    if error
      log.warn error.message
      return readUsername(c, u, cb)
    c.changed = c.u isnt un
    u.u = un
    cb er
    return

  return
readPassword = (c, u, cb) ->
  v = userValidate.pw
  prompt = undefined
  if c.p and not c.changed
    prompt = "Password: (or leave unchanged) "
  else
    prompt = "Password: "
  read
    prompt: prompt
    silent: true
  , (er, pw) ->
    return cb((if er.message is "cancelled" then er.message else er))  if er
    
    # when the username was not changed,
    # empty response means "use the old value"
    pw = c.p  if not c.changed and pw is ""
    return readPassword(c, u, cb)  unless pw
    error = v(pw)
    if error
      log.warn error.message
      return readPassword(c, u, cb)
    c.changed = c.changed or c.p isnt pw
    u.p = pw
    cb er
    return

  return
readEmail = (c, u, cb) ->
  v = userValidate.email
  r =
    prompt: "Email: (this IS public) "
    default: c.e or ""

  read r, (er, em) ->
    return cb((if er.message is "cancelled" then er.message else er))  if er
    return readEmail(c, u, cb)  unless em
    error = v(em)
    if error
      log.warn error.message
      return readEmail(c, u, cb)
    u.e = em
    cb er
    return

  return
save = (c, u, cb) ->
  if c.changed
    delete registry.auth

    delete registry.username

    delete registry.password

    registry.username = u.u
    registry.password = u.p
  npm.spinner.start()
  
  # save existing configs, but yank off for this PUT
  uri = npm.config.get("registry")
  scope = npm.config.get("scope")
  
  # there may be a saved scope and no --registry (for login)
  if scope
    scope = "@" + scope  if scope.charAt(0) isnt "@"
    scopedRegistry = npm.config.get(scope + ":registry")
    uri = scopedRegistry  if scopedRegistry
  registry.adduser uri, u.u, u.p, u.e, (er, doc) ->
    npm.spinner.stop()
    return cb(er)  if er
    registry.username = u.u
    registry.password = u.p
    registry.email = u.e
    
    # don't want this polluting the configuration
    npm.config.del "_token", "user"
    npm.config.set scope + ":registry", uri, "user"  if scope
    if doc and doc.token
      npm.config.setCredentialsByURI uri,
        token: doc.token

    else
      npm.config.setCredentialsByURI uri,
        username: u.u
        password: u.p
        email: u.e
        alwaysAuth: npm.config.get("always-auth")

    log.info "adduser", "Authorized user %s", u.u
    npm.config.save "user", cb
    return

  return
module.exports = adduser
log = require("npmlog")
npm = require("./npm.js")
registry = npm.registry
read = require("read")
userValidate = require("npm-user-validate")
crypto = undefined
try
  crypto = process.binding("crypto") and require("crypto")
adduser.usage = "npm adduser\nThen enter stuff at the prompts"
