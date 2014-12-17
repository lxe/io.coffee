
# Just to make sure that all examples will be processed
once = (fn) ->
  once = false
  ->
    return  if once
    once = true
    fn.apply this, arguments
    return
verifyFiles = (files, callback) ->
  dir = path.resolve(verifyDir, "doc-" + id++)
  files = Object.keys(files).map((name) ->
    path: path.resolve(dir, name)
    name: name
    content: files[name]
  )
  files.push
    path: path.resolve(dir, "binding.gyp")
    content: JSON.stringify(targets: [
      target_name: "addon"
      sources: files.map((file) ->
        file.name
      )
    ])

  fs.mkdir dir, ->
    
    # Ignore errors
    next = (err) ->
      return done(err)  if err
      done()  if --waiting is 0
      return
    waiting = files.length
    i = 0

    while i < files.length
      fs.writeFile files[i].path, files[i].content, next
      i++
    done = once(callback)
    return

  return
fs = require("fs")
path = require("path")
marked = require("marked")
doc = path.resolve(__dirname, "..", "..", "doc", "api", "addons.markdown")
verifyDir = path.resolve(__dirname, "..", "..", "test", "addons")
contents = fs.readFileSync(doc).toString()
tokens = marked.lexer(contents, {})
files = null
id = 0
tokens.push type: "heading"
oldDirs = fs.readdirSync(verifyDir)
oldDirs = oldDirs.filter((dir) ->
  /^doc-/.test dir
).map((dir) ->
  path.resolve verifyDir, dir
)
i = 0

while i < tokens.length
  token = tokens[i]
  if token.type is "heading"
    if files and Object.keys(files).length isnt 0
      verifyFiles files, (err) ->
        if err
          console.log err
        else
          console.log "done"
        return

    files = {}
  else if token.type is "code"
    match = token.text.match(/^\/\/\s+(.*\.(?:cc|h|js))[\r\n]/)
    continue  if match is null
    files[match[1]] = token.text
  i++
