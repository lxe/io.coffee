gensym = ->
  rando(16).toString "hex"
writeAlmostForever = (filename) ->
  unless keepItGoingLouder[filename]
    writers--
    done()  if writers < 1
  else
    writeFile filename, keepItGoingLouder[filename], (err) ->
      errors++  if err
      writeAlmostForever filename
      return

  return
done = ->
  rimraf BASEDIR, ->
    if errors > 0
      console.log "not ok - %d errors", errors
    else
      console.log "ok"
    return

  return
rando = require("crypto").randomBytes
resolve = require("path").resolve
mkdirp = require("mkdirp")
rimraf = require("rimraf")
writeFile = require("graceful-fs").writeFile
BASEDIR = resolve(__dirname, "arena")
keepItGoingLouder = {}
writers = 0
errors = 0
mkdirp BASEDIR, go = ->
  i = 0

  while i < 16
    filename = resolve(BASEDIR, gensym() + ".txt")
    keepItGoingLouder[filename] = ""
    j = 0

    while j < 512
      keepItGoingLouder[filename] += filename
      j++
    writers++
    writeAlmostForever filename
    i++
  setTimeout (viktor = ->
    
    # kill all the writers
    keepItGoingLouder = {}
    return
  ), 3 * 1000
  return

