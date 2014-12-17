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

# person.jpg is 57kb. We just need some file that is sufficiently large.
tryToKillEventLoop = ->
  console.log "trying to kill event loop ..."
  fs.stat __filename, (err) ->
    if err
      throw new Exception("first fs.stat failed")
    else
      fs.stat __filename, (err) ->
        if err
          throw new Exception("second fs.stat failed")
        else
          console.log "could not kill event loop, retrying..."
          setTimeout (->
            if --count
              tryToKillEventLoop()
            else
              console.log "done trying to kill event loop"
              process.exit 0
            return
          ), 1
        return

    return

  return
common = require("../common")
assert = require("assert")
count = 100
fs = require("fs")
filename = require("path").join(common.fixturesDir, "person.jpg")

# Generate a lot of thread pool events
pos = 0
fs.open filename, "r", 0666, (err, fd) ->
  readChunk = ->
    fs.read fd, 1024, 0, "binary", (err, chunk, bytesRead) ->
      throw err  if err
      if chunk
        pos += bytesRead
        
        #console.log(pos);
        readChunk()
      else
        fs.closeSync fd
        throw new Exception("Shouldn't get EOF")
      return

    return
  throw err  if err
  readChunk()
  return

tryToKillEventLoop()
process.on "exit", ->
  console.log "done with test"
  assert.ok pos > 10000
  return

