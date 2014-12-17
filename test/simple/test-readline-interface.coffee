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
FakeInput = ->
  EventEmitter.call this
  return
isWarned = (emitter) ->
  for name of emitter
    listeners = emitter[name]
    return true  if listeners.warned
  false
assert = require("assert")
readline = require("readline")
EventEmitter = require("events").EventEmitter
inherits = require("util").inherits
inherits FakeInput, EventEmitter
FakeInput::resume = ->

FakeInput::pause = ->

FakeInput::write = ->

FakeInput::end = ->

[
  true
  false
].forEach (terminal) ->
  fi = undefined
  rli = undefined
  called = undefined
  
  # sending a full line
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  called = false
  rli.on "line", (line) ->
    called = true
    assert.equal line, "asdf"
    return

  fi.emit "data", "asdf\n"
  assert.ok called
  
  # sending a blank line
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  called = false
  rli.on "line", (line) ->
    called = true
    assert.equal line, ""
    return

  fi.emit "data", "\n"
  assert.ok called
  
  # sending a single character with no newline
  fi = new FakeInput()
  rli = new readline.Interface(fi, {})
  called = false
  rli.on "line", (line) ->
    called = true
    return

  fi.emit "data", "a"
  assert.ok not called
  rli.close()
  
  # sending a single character with no newline and then a newline
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  called = false
  rli.on "line", (line) ->
    called = true
    assert.equal line, "a"
    return

  fi.emit "data", "a"
  assert.ok not called
  fi.emit "data", "\n"
  assert.ok called
  rli.close()
  
  # sending multiple newlines at once
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  expectedLines = [
    "foo"
    "bar"
    "baz"
  ]
  callCount = 0
  rli.on "line", (line) ->
    assert.equal line, expectedLines[callCount]
    callCount++
    return

  fi.emit "data", expectedLines.join("\n") + "\n"
  assert.equal callCount, expectedLines.length
  rli.close()
  
  # sending multiple newlines at once that does not end with a new line
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  expectedLines = [
    "foo"
    "bar"
    "baz"
    "bat"
  ]
  callCount = 0
  rli.on "line", (line) ->
    assert.equal line, expectedLines[callCount]
    callCount++
    return

  fi.emit "data", expectedLines.join("\n")
  assert.equal callCount, expectedLines.length - 1
  rli.close()
  
  # sending multiple newlines at once that does not end with a new(empty) 
  # line and a `end` event
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  expectedLines = [
    "foo"
    "bar"
    "baz"
    ""
  ]
  callCount = 0
  rli.on "line", (line) ->
    assert.equal line, expectedLines[callCount]
    callCount++
    return

  rli.on "close", ->
    callCount++
    return

  fi.emit "data", expectedLines.join("\n")
  fi.emit "end"
  assert.equal callCount, expectedLines.length
  rli.close()
  
  # sending multiple newlines at once that does not end with a new line
  # and a `end` event(last line is)
  
  # \r\n should emit one line event, not two
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  expectedLines = [
    "foo"
    "bar"
    "baz"
    "bat"
  ]
  callCount = 0
  rli.on "line", (line) ->
    assert.equal line, expectedLines[callCount]
    callCount++
    return

  fi.emit "data", expectedLines.join("\r\n")
  assert.equal callCount, expectedLines.length - 1
  rli.close()
  
  # \r\n should emit one line event when split across multiple writes.
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  expectedLines = [
    "foo"
    "bar"
    "baz"
    "bat"
  ]
  callCount = 0
  rli.on "line", (line) ->
    assert.equal line, expectedLines[callCount]
    callCount++
    return

  expectedLines.forEach (line) ->
    fi.emit "data", line + "\r"
    fi.emit "data", "\n"
    return

  assert.equal callCount, expectedLines.length
  rli.close()
  
  # \r should behave like \n when alone
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: true
  )
  expectedLines = [
    "foo"
    "bar"
    "baz"
    "bat"
  ]
  callCount = 0
  rli.on "line", (line) ->
    assert.equal line, expectedLines[callCount]
    callCount++
    return

  fi.emit "data", expectedLines.join("\r")
  assert.equal callCount, expectedLines.length - 1
  rli.close()
  
  # \r at start of input should output blank line
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: true
  )
  expectedLines = [
    ""
    "foo"
  ]
  callCount = 0
  rli.on "line", (line) ->
    assert.equal line, expectedLines[callCount]
    callCount++
    return

  fi.emit "data", "\rfoo\r"
  assert.equal callCount, expectedLines.length
  rli.close()
  
  # sending a multi-byte utf8 char over multiple writes
  buf = Buffer("☮", "utf8")
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: fi
    terminal: terminal
  )
  callCount = 0
  rli.on "line", (line) ->
    callCount++
    assert.equal line, buf.toString("utf8")
    return

  [].forEach.call buf, (i) ->
    fi.emit "data", Buffer([i])
    return

  assert.equal callCount, 0
  fi.emit "data", "\n"
  assert.equal callCount, 1
  rli.close()
  
  # keypress
  [
    ["a"]
    ["\u001b"]
    ["\u001b[31m"]
    [
      "\u001b[31m"
      "\u001b[39m"
    ]
    [
      "\u001b[31m"
      "a"
      "\u001b[39m"
      "a"
    ]
  ].forEach (keypresses) ->
    keypressListener = (ch, key) ->
      callCount++
      assert not key.code  if ch
      assert.equal key.sequence, remainingKeypresses.shift()
      return
    fi = new FakeInput()
    callCount = 0
    remainingKeypresses = keypresses.slice()
    readline.emitKeypressEvents fi
    fi.on "keypress", keypressListener
    fi.emit "data", keypresses.join("")
    assert.equal callCount, keypresses.length
    assert.equal remainingKeypresses.length, 0
    fi.removeListener "keypress", keypressListener
    fi.emit "data", "" # removes listener
    return

  if terminal
    
    # question
    fi = new FakeInput()
    rli = new readline.Interface(
      input: fi
      output: fi
      terminal: terminal
    )
    expectedLines = ["foo"]
    rli.question expectedLines[0], ->
      rli.close()
      return

    cursorPos = rli._getCursorPos()
    assert.equal cursorPos.rows, 0
    assert.equal cursorPos.cols, expectedLines[0].length
    rli.close()
    
    # sending a multi-line question
    fi = new FakeInput()
    rli = new readline.Interface(
      input: fi
      output: fi
      terminal: terminal
    )
    expectedLines = [
      "foo"
      "bar"
    ]
    rli.question expectedLines.join("\n"), ->
      rli.close()
      return

    cursorPos = rli._getCursorPos()
    assert.equal cursorPos.rows, expectedLines.length - 1
    assert.equal cursorPos.cols, expectedLines.slice(-1)[0].length
    rli.close()
  
  # wide characters should be treated as two columns.
  assert.equal readline.isFullWidthCodePoint("a".charCodeAt(0)), false
  assert.equal readline.isFullWidthCodePoint("あ".charCodeAt(0)), true
  assert.equal readline.isFullWidthCodePoint("谢".charCodeAt(0)), true
  assert.equal readline.isFullWidthCodePoint("고".charCodeAt(0)), true
  assert.equal readline.isFullWidthCodePoint(0x1f251), true # surrogate
  assert.equal readline.codePointAt("ABC", 0), 0x41
  assert.equal readline.codePointAt("あいう", 1), 0x3044
  # surrogate
  assert.equal readline.codePointAt("𐀀", 0), 0x10000
  # surrogate
  assert.equal readline.codePointAt("𐀀A", 2), 0x41
  assert.equal readline.getStringWidth("abcde"), 5
  assert.equal readline.getStringWidth("古池や"), 6
  assert.equal readline.getStringWidth("ノード.js"), 9
  assert.equal readline.getStringWidth("你好"), 4
  assert.equal readline.getStringWidth("안녕하세요"), 10
  assert.equal readline.getStringWidth("A🈀BC"), 5 # surrogate
  
  # check if vt control chars are stripped
  assert.equal readline.stripVTControlCharacters("\u001b[31m> \u001b[39m"), "> "
  assert.equal readline.stripVTControlCharacters("\u001b[31m> \u001b[39m> "), "> > "
  assert.equal readline.stripVTControlCharacters("\u001b[31m\u001b[39m"), ""
  assert.equal readline.stripVTControlCharacters("> "), "> "
  assert.equal readline.getStringWidth("\u001b[31m> \u001b[39m"), 2
  assert.equal readline.getStringWidth("\u001b[31m> \u001b[39m> "), 4
  assert.equal readline.getStringWidth("\u001b[31m\u001b[39m"), 0
  assert.equal readline.getStringWidth("> "), 2
  assert.deepEqual fi.listeners((if terminal then "keypress" else "data")), []
  
  # check EventEmitter memory leak
  i = 0

  while i < 12
    rl = readline.createInterface(
      input: process.stdin
      output: process.stdout
    )
    rl.close()
    assert.equal isWarned(process.stdin._events), false
    assert.equal isWarned(process.stdout._events), false
    i++
  
  #can create a new readline Interface with a null output arugument
  fi = new FakeInput()
  rli = new readline.Interface(
    input: fi
    output: null
    terminal: terminal
  )
  called = false
  rli.on "line", (line) ->
    called = true
    assert.equal line, "asdf"
    return

  fi.emit "data", "asdf\n"
  assert.ok called
  assert.doesNotThrow ->
    rli.setPrompt "ddd> "
    return

  assert.doesNotThrow ->
    rli.prompt()
    return

  assert.doesNotThrow ->
    rli.write "really shouldnt be seeing this"
    return

  assert.doesNotThrow ->
    rli.question "What do you think of node.js? ", (answer) ->
      console.log "Thank you for your valuable feedback:", answer
      rli.close()
      return

    return

  return

