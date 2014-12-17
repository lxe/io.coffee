# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
common = require("../common")
assert = require("assert")
if process.argv[2] isnt "child"
  spawn = require("child_process").spawn
  child = spawn(process.execPath, [
    __filename
    "child"
  ],
    stdio: "pipe" #'inherit'
  )
  timer = setTimeout(->
    throw new Error("child is hung")return
  , 3000)
  child.on "exit", (code) ->
    console.error "ok"
    assert not code
    clearTimeout timer
    return

else
  
  # in the error handler, we trigger several MakeCallback events
  f = ->
    process.nextTick ->
      d.run ->
        throw (new Error("x"))return

      return

    return
  domain = require("domain")
  d = domain.create()
  process.maxTickDepth = 10
  d.on "error", (e) ->
    console.log "a"
    console.log "b"
    console.log "c"
    console.log "d"
    console.log "e"
    f()
    return

  f()
  setTimeout ->
    console.error "broke in!"
    
    #process.stdout.close();
    #process.stderr.close();
    process.exit 0
    return

