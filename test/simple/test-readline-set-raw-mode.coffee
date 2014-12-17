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
assert = require("assert")
readline = require("readline")
Stream = require("stream")
stream = new Stream()
expectedRawMode = true
rawModeCalled = false
resumeCalled = false
pauseCalled = false
stream.setRawMode = (mode) ->
  rawModeCalled = true
  assert.equal mode, expectedRawMode
  return

stream.resume = ->
  resumeCalled = true
  return

stream.pause = ->
  pauseCalled = true
  return


# when the "readline" starts in "terminal" mode,
# then setRawMode(true) should be called
rli = readline.createInterface(
  input: stream
  output: stream
  terminal: true
)
assert rli.terminal
assert rawModeCalled
assert resumeCalled
assert not pauseCalled

# pause() should call *not* call setRawMode()
rawModeCalled = false
resumeCalled = false
pauseCalled = false
rli.pause()
assert not rawModeCalled
assert not resumeCalled
assert pauseCalled

# resume() should *not* call setRawMode()
rawModeCalled = false
resumeCalled = false
pauseCalled = false
rli.resume()
assert not rawModeCalled
assert resumeCalled
assert not pauseCalled

# close() should call setRawMode(false)
expectedRawMode = false
rawModeCalled = false
resumeCalled = false
pauseCalled = false
rli.close()
assert rawModeCalled
assert not resumeCalled
assert pauseCalled
assert.deepEqual stream.listeners("keypress"), []

# one data listener for the keypress events.
assert.equal stream.listeners("data").length, 1
