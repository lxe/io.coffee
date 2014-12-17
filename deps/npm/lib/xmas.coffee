# happy xmas
log = require("npmlog")
module.exports = (args, cb) ->
  w = (s) ->
    process.stderr.write s
    return
  s = (if process.platform is "win32" then " *" else " ★")
  f = "／"
  b = "＼"
  x = (if process.platform is "win32" then " " else "")
  o = [
    "i"
    " "
    " "
    " "
    " "
    " "
    " "
    " "
    " "
    " "
    " "
    " "
    " "
    "⸛"
    "⁂"
    "⸮"
    "&"
    "@"
    "｡"
  ]
  oc = [
    21
    33
    34
    35
    36
    37
  ]
  l = "^"
  w "\n"
  (T = (H) ->
    i = 0

    while i < H
      w " "
      i++
    w x + "\u001b[33m" + s + "\n"
    M = H * 2 - 1
    L = 1

    while L <= H
      O = L * 2 - 2
      S = (M - O) / 2
      i = 0
      while i < S
        w " "
        i++
      w x + "\u001b[32m" + f
      i = 0
      while i < O
        w "\u001b[" + oc[Math.floor(Math.random() * oc.length)] + "m" + o[Math.floor(Math.random() * o.length)]
        i++
      w x + "\u001b[32m" + b + "\n"
      L++
    w " "
    i = 1
    while i < H
      w "\u001b[32m" + l
      i++
    w "| " + x + " |"
    i = 1
    while i < H
      w "\u001b[32m" + l
      i++
    if H > 10
      w "\n "
      i = 1
      while i < H
        w " "
        i++
      w "| " + x + " |"
      i = 1
      while i < H
        w " "
        i++
    return
  ) 20
  w "\n\n"
  log.heading = ""
  log.addLevel "npm", 100000, log.headingStyle
  log.npm "loves you", "Happy Xmas, Noders!"
  cb()
  return

dg = false
Object.defineProperty module.exports, "usage",
  get: ->
    if dg
      module.exports [], ->

    dg = true
    " "

