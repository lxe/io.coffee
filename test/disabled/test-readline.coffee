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

# Can't test this when 'make test' doesn't assign a tty to the stdout.
# Yet another use-case for require('tty').spawn ?
common = require("../common")
assert = require("assert")
readline = require("readline")
key =
  xterm:
    home: [
      "\u001b[H"
      {
        ctrl: true
        name: "a"
      }
    ]
    end: [
      "\u001b[F"
      {
        ctrl: true
        name: "e"
      }
    ]
    metab: [
      "\u001bb"
      {
        meta: true
        name: "b"
      }
    ]
    metaf: [
      "\u001bf"
      {
        meta: true
        name: "f"
      }
    ]
    metad: [
      "\u001bd"
      {
        meta: true
        name: "d"
      }
    ]

  gnome:
    home: [
      "\u001bOH"
      {
        ctrl: true
        name: "a"
      }
    ]
    end: [
      "\u001bOF"
      {
        ctrl: true
        name: "e"
      }
    ]

  rxvt:
    home: [
      "\u001b[7"
      {
        ctrl: true
        name: "a"
      }
    ]
    end: [
      "\u001b[8"
      {
        ctrl: true
        name: "e"
      }
    ]

  putty:
    home: [
      "\u001b[1~"
      {
        ctrl: true
        name: "a"
      }
    ]
    end: [
      "\u001b[>~"
      {
        ctrl: true
        name: "e"
      }
    ]

readlineFakeStream = ->
  written_bytes = []
  rl = readline.createInterface(
    input: process.stdin
    output: process.stdout
    completer: (text) ->
      [
        []
        ""
      ]
  )
  _stdoutWrite = process.stdout.write
  process.stdout.write = (data) ->
    data.split("").forEach rl.written_bytes.push.bind(rl.written_bytes)
    _stdoutWrite.apply this, arguments
    return

  rl.written_bytes = written_bytes
  rl

rl = readlineFakeStream()
written_bytes_length = undefined
refreshed = undefined
rl.write "foo"
assert.equal 3, rl.cursor
[
  key.xterm
  key.rxvt
  key.gnome
  key.putty
].forEach (key) ->
  rl.write.apply rl, key.home
  assert.equal 0, rl.cursor
  rl.write.apply rl, key.end
  assert.equal 3, rl.cursor
  return

rl = readlineFakeStream()
rl.write "foo bar.hop/zoo"
rl.write.apply rl, key.xterm.home
[
  {
    cursor: 4
    key: key.xterm.metaf
  }
  {
    cursor: 7
    key: key.xterm.metaf
  }
  {
    cursor: 8
    key: key.xterm.metaf
  }
  {
    cursor: 11
    key: key.xterm.metaf
  }
  {
    cursor: 12
    key: key.xterm.metaf
  }
  {
    cursor: 15
    key: key.xterm.metaf
  }
  {
    cursor: 12
    key: key.xterm.metab
  }
  {
    cursor: 11
    key: key.xterm.metab
  }
  {
    cursor: 8
    key: key.xterm.metab
  }
  {
    cursor: 7
    key: key.xterm.metab
  }
  {
    cursor: 4
    key: key.xterm.metab
  }
  {
    cursor: 0
    key: key.xterm.metab
  }
].forEach (action) ->
  written_bytes_length = rl.written_bytes.length
  rl.write.apply rl, action.key
  assert.equal action.cursor, rl.cursor
  refreshed = written_bytes_length isnt rl.written_bytes.length
  assert.equal true, refreshed
  return

rl = readlineFakeStream()
rl.write "foo bar.hop/zoo"
rl.write.apply rl, key.xterm.home
[
  "bar.hop/zoo"
  ".hop/zoo"
  "hop/zoo"
  "/zoo"
  "zoo"
  ""
].forEach (expectedLine) ->
  rl.write.apply rl, key.xterm.metad
  assert.equal 0, rl.cursor
  assert.equal expectedLine, rl.line
  return

rl.close()
