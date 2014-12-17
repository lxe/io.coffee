# this is a weird meta test.  It verifies that all the instances of
# `npm.config.get(...)` are:
# a) Simple strings, and not variables
# b) Documented
# c) Defined in the `npmconf` package.
test = require("tap").test
fs = require("fs")
path = require("path")
root = path.resolve(__dirname, "..", "..")
lib = path.resolve(root, "lib")
nm = path.resolve(root, "node_modules")
doc = path.resolve(root, "doc/misc/npm-config.md")
FILES = []
CONFS = {}
DOC = {}
exceptions = [
  path.resolve(lib, "adduser.js")
  path.resolve(lib, "config.js")
  path.resolve(lib, "publish.js")
  path.resolve(lib, "utils", "lifecycle.js")
  path.resolve(lib, "utils", "map-to-registry.js")
  path.resolve(nm, "npm-registry-client", "lib", "publish.js")
  path.resolve(nm, "npm-registry-client", "lib", "request.js")
]
test "get files", (t) ->
  walk = (lib) ->
    files = fs.readdirSync(lib).map((f) ->
      path.resolve lib, f
    )
    files.forEach (f) ->
      try
        s = fs.statSync(f)
      catch er
        return
      if s.isDirectory()
        walk f
      else FILES.push f  if f.match(/\.js$/)
      return

    return
  walk nm
  walk lib
  t.pass "got files"
  t.end()
  return

test "get lines", (t) ->
  FILES.forEach (f) ->
    lines = fs.readFileSync(f, "utf8").split(/\r|\n/)
    lines.forEach (l, i) ->
      matches = l.split(/conf(?:ig)?\.get\(/g)
      matches.shift()
      matches.forEach (m) ->
        m = m.split(")").shift()
        literal = m.match(/^['"].+['"]$/)
        if literal
          m = m.slice(1, -1)
          if not m.match(/^\_/) and m isnt "argv"
            CONFS[m] =
              file: f
              line: i
        else t.fail "non-string-literal config used in " + f + ":" + i  if exceptions.indexOf(f) is -1
        return

      return

    return

  t.pass "got lines"
  t.end()
  return

test "get docs", (t) ->
  d = fs.readFileSync(doc, "utf8").split(/\r|\n/)
  
  # walk down until the "## Config Settings" section
  i = 0

  while i < d.length and d[i] isnt "## Config Settings"
    i++
  i++
  
  # now gather up all the ^###\s lines until the next ^##\s
  while i < d.length and not d[i].match(/^## /)
    DOC[d[i].replace(/^### /, "").trim()] = true  if d[i].match(/^### /)
    i++
  t.pass "read the docs"
  t.end()
  return

test "check configs", (t) ->
  defs = require("../../lib/config/defaults.js")
  types = Object.keys(defs.types)
  defaults = Object.keys(defs.defaults)
  for c1 of CONFS
    if CONFS[c1].file.indexOf(lib) is 0
      t.ok DOC[c1], "should be documented " + c1 + " " + CONFS[c1].file + ":" + CONFS[c1].line
      t.ok types.indexOf(c1) isnt -1, "should be defined in npmconf " + c1
      t.ok defaults.indexOf(c1) isnt -1, "should have default in npmconf " + c1
  for c2 of DOC
    if c2 isnt "versions" and c2 isnt "version" and c2 isnt "init.version"
      t.ok CONFS[c2], "config in doc should be used somewhere " + c2
      t.ok types.indexOf(c2) isnt -1, "should be defined in npmconf " + c2
      t.ok defaults.indexOf(c2) isnt -1, "should have default in npmconf " + c2
  types.forEach (c) ->
    if not c.match(/^\_/) and c isnt "argv" and not c.match(/^versions?$/)
      t.ok DOC[c], "defined type should be documented " + c
      t.ok CONFS[c], "defined type should be used " + c
    return

  defaults.forEach (c) ->
    if not c.match(/^\_/) and c isnt "argv" and not c.match(/^versions?$/)
      t.ok DOC[c], "defaulted type should be documented " + c
      t.ok CONFS[c], "defaulted type should be used " + c
    return

  t.end()
  return

