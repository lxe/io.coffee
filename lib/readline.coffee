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

# Inspiration for this code comes from Salvatore Sanfilippo's linenoise.
# https://github.com/antirez/linenoise
# Reference:
# * http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
# * http://www.3waylabs.com/nw/WWW/products/wizcon/vt220.html
Interface = (input, output, completer, terminal) ->
  
  # an options object was given
  
  # backwards compat; check the isTTY prop of the output stream
  #  when `terminal` was not specified
  
  # Check arity, 2 - for async, 1 for sync
  ondata = (data) ->
    self._normalWrite data
    return
  onend = ->
    self.emit "line", self._line_buffer  if util.isString(self._line_buffer) and self._line_buffer.length > 0
    self.close()
    return
  ontermend = ->
    self.emit "line", self.line  if util.isString(self.line) and self.line.length > 0
    self.close()
    return
  onkeypress = (s, key) ->
    self._ttyWrite s, key
    return
  onresize = ->
    self._refreshLine()
    return
  return new Interface(input, output, completer, terminal)  unless this instanceof Interface
  @_sawReturn = false
  EventEmitter.call this
  if arguments.length is 1
    output = input.output
    completer = input.completer
    terminal = input.terminal
    input = input.input
  completer = completer or ->
    []

  throw new TypeError("Argument 'completer' must be a function")  unless util.isFunction(completer)
  terminal = !!output.isTTY  if util.isUndefined(terminal) and not util.isNullOrUndefined(output)
  self = this
  @output = output
  @input = input
  @completer = (if completer.length is 2 then completer else (v, callback) ->
    callback null, completer(v)
    return
  )
  @setPrompt "> "
  @terminal = !!terminal
  unless @terminal
    input.on "data", ondata
    input.on "end", onend
    self.once "close", ->
      input.removeListener "data", ondata
      input.removeListener "end", onend
      return

    StringDecoder = require("string_decoder").StringDecoder # lazy load
    @_decoder = new StringDecoder("utf8")
  else
    exports.emitKeypressEvents input
    
    # input usually refers to stdin
    input.on "keypress", onkeypress
    input.on "end", ontermend
    
    # Current line
    @line = ""
    @_setRawMode true
    @terminal = true
    
    # Cursor position on the line.
    @cursor = 0
    @history = []
    @historyIndex = -1
    output.on "resize", onresize  unless util.isNullOrUndefined(output)
    self.once "close", ->
      input.removeListener "keypress", onkeypress
      input.removeListener "end", ontermend
      output.removeListener "resize", onresize  unless util.isNullOrUndefined(output)
      return

  input.resume()
  return

# Only store so many

# line length

# cursor position

# first move to the bottom of the current line, based on cursor pos

# Cursor to left edge.

# erase data

# Write the prompt and the current buffer content.

# Force terminal to allocate a new line

# Move cursor to original position.

# \r\n, \n, or \r followed by something other than \n

# Run test() on the new string chunk, not on the entire line buffer.

# got one or more newlines; process into "line" events

# either '' or (concievably) the unfinished portion of the next line

# no newlines this time, save what we have for next time

#BUG: Problem when adding tabs with following content.
#     Perhaps the bug is in _refreshLine(). Not sure.
#     A hack would be to insert spaces instead of literal '\t'.

# a hack to get the line refreshed if it's needed

# XXX Log it somewhere?
# the text that was completed

# Apply/show completions.
# 2 space padding

# If there is a common prefix to all matches, then apply that
# portion.

# this = Interface instance
handleGroup = (self, group, width, maxColumns) ->
  return  if group.length is 0
  minRows = Math.ceil(group.length / maxColumns)
  row = 0

  while row < minRows
    col = 0

    while col < maxColumns
      idx = row * maxColumns + col
      break  if idx >= group.length
      item = group[idx]
      self._writeToOutput item
      if col < maxColumns - 1
        s = 0
        itemLen = item.length

        while s < width - itemLen
          self._writeToOutput " "
          s++
      col++
    self._writeToOutput "\r\n"
    row++
  self._writeToOutput "\r\n"
  return
commonPrefix = (strings) ->
  return ""  if not strings or strings.length is 0
  sorted = strings.slice().sort()
  min = sorted[0]
  max = sorted[sorted.length - 1]
  i = 0
  len = min.length

  while i < len
    return min.slice(0, i)  unless min[i] is max[i]
    i++
  min
# set cursor to end of line.
# set cursor to end of line.

# Returns the last character's display position of the given string
# surrogates
# new line \n

# Returns current cursor's position and line

# If the cursor is on a full-width character which steps over the line,
# move the cursor to the beginning of the next line.

# This function moves cursor dx places to the right
# (-dx for left) and refreshes the line if it is needed

# bounds check

# check if cursors are in the same line

# handle a write from the tty

# Ignore escape key - Fixes #2876

# Control and shift pressed 

# Control key pressed 

# This readline instance is finished
# delete left
# delete right or EOF

# This readline instance is finished
# delete the whole line
# delete from current to end of line
# go to the start of the line
# go to the end of the line
# back one character
# forward one character
# clear the whole screen
# next history item
# previous history item

# Don't raise events if stream has already been abandoned.

# Stream must be paused and resumed after SIGCONT to catch
# SIGINT, SIGTSTP, and EOF.

# explicitly re-enable "raw mode" and move the cursor to
# the correct position.
# See https://github.com/joyent/node/issues/3295.
# delete backwards to a word boundary
# delete forward to a word boundary

# Meta key pressed 
# backward word
# forward word
# delete forward word
# delete backwards to a word boundary

# No modifier keys used 

# \r bookkeeping is only relevant if a \n comes right after.
# carriage return, i.e. \r
# tab completion

###*
accepts a readable Stream instance and makes it emit "keypress" events
###
emitKeypressEvents = (stream) ->
  # lazy load
  onData = (b) ->
    if EventEmitter.listenerCount(stream, "keypress") > 0
      r = stream._keypressDecoder.write(b)
      emitKeys stream, r  if r
    else
      
      # Nobody's watching anyway
      stream.removeListener "data", onData
      stream.on "newListener", onNewListener
    return
  onNewListener = (event) ->
    if event is "keypress"
      stream.on "data", onData
      stream.removeListener "newListener", onNewListener
    return
  return  if stream._keypressDecoder
  StringDecoder = require("string_decoder").StringDecoder
  stream._keypressDecoder = new StringDecoder("utf8")
  if EventEmitter.listenerCount(stream, "keypress") > 0
    stream.on "data", onData
  else
    stream.on "newListener", onNewListener
  return

#
#  Some patterns seen in terminal key escape codes, derived from combos seen
#  at http://www.midnight-commander.org/browser/lib/tty/key.c
#
#  ESC letter
#  ESC [ letter
#  ESC [ modifier letter
#  ESC [ 1 ; modifier letter
#  ESC [ num char
#  ESC [ num ; modifier char
#  ESC O letter
#  ESC O modifier letter
#  ESC O 1 ; modifier letter
#  ESC N letter
#  ESC [ [ num ; modifier char
#  ESC [ [ 1 ; modifier letter
#  ESC ESC [ num char
#  ESC ESC O letter
#
#  - char is usually ~ but $ and ^ also happen with rxvt
#  - modifier is 1 +
#                (shift     * 1) +
#                (left_alt  * 2) +
#                (ctrl      * 4) +
#                (right_alt * 8)
#  - two leading ESCs apparently mean the same as one leading ESC
#

# Regexes used for ansi escape code splitting
# mouse
emitKeys = (stream, s) ->
  if util.isBuffer(s)
    if s[0] > 127 and util.isUndefined(s[1])
      s[0] -= 128
      s = "\u001b" + s.toString(stream.encoding or "utf-8")
    else
      s = s.toString(stream.encoding or "utf-8")
  buffer = []
  match = undefined
  while match = escapeCodeReAnywhere.exec(s)
    buffer = buffer.concat(s.slice(0, match.index).split(""))
    buffer.push match[0]
    s = s.slice(match.index + match[0].length)
  buffer = buffer.concat(s.split(""))
  buffer.forEach (s) ->
    ch = undefined
    key =
      sequence: s
      name: `undefined`
      ctrl: false
      meta: false
      shift: false

    parts = undefined
    if s is "\r"
      
      # carriage return
      key.name = "return"
    else if s is "\n"
      
      # enter, should have been called linefeed
      key.name = "enter"
    else if s is "\t"
      
      # tab
      key.name = "tab"
    else if s is "\b" or s is "" or s is "\u001b" or s is "\u001b\b"
      
      # backspace or ctrl+h
      key.name = "backspace"
      key.meta = (s.charAt(0) is "\u001b")
    else if s is "\u001b" or s is "\u001b\u001b"
      
      # escape key
      key.name = "escape"
      key.meta = (s.length is 2)
    else if s is " " or s is "\u001b "
      key.name = "space"
      key.meta = (s.length is 2)
    else if s.length is 1 and s <= "\u001a"
      
      # ctrl+letter
      key.name = String.fromCharCode(s.charCodeAt(0) + "a".charCodeAt(0) - 1)
      key.ctrl = true
    else if s.length is 1 and s >= "a" and s <= "z"
      
      # lowercase letter
      key.name = s
    else if s.length is 1 and s >= "A" and s <= "Z"
      
      # shift+letter
      key.name = s.toLowerCase()
      key.shift = true
    else if parts = metaKeyCodeRe.exec(s)
      
      # meta+character key
      key.name = parts[1].toLowerCase()
      key.meta = true
      key.shift = /^[A-Z]$/.test(parts[1])
    else if parts = functionKeyCodeRe.exec(s)
      
      # ansi escape sequence
      
      # reassemble the key code leaving out leading \x1b's,
      # the modifier key bitflag and any meaningless "1;" sequence
      code = (parts[1] or "") + (parts[2] or "") + (parts[4] or "") + (parts[9] or "")
      modifier = (parts[3] or parts[8] or 1) - 1
      
      # Parse the key modifier
      key.ctrl = !!(modifier & 4)
      key.meta = !!(modifier & 10)
      key.shift = !!(modifier & 1)
      key.code = code
      
      # Parse the key itself
      switch code
        
        # xterm/gnome ESC O letter 
        when "OP"
          key.name = "f1"
        when "OQ"
          key.name = "f2"
        when "OR"
          key.name = "f3"
        when "OS"
          key.name = "f4"
        
        # xterm/rxvt ESC [ number ~ 
        when "[11~"
          key.name = "f1"
        when "[12~"
          key.name = "f2"
        when "[13~"
          key.name = "f3"
        when "[14~"
          key.name = "f4"
        
        # from Cygwin and used in libuv 
        when "[[A"
          key.name = "f1"
        when "[[B"
          key.name = "f2"
        when "[[C"
          key.name = "f3"
        when "[[D"
          key.name = "f4"
        when "[[E"
          key.name = "f5"
        
        # common 
        when "[15~"
          key.name = "f5"
        when "[17~"
          key.name = "f6"
        when "[18~"
          key.name = "f7"
        when "[19~"
          key.name = "f8"
        when "[20~"
          key.name = "f9"
        when "[21~"
          key.name = "f10"
        when "[23~"
          key.name = "f11"
        when "[24~"
          key.name = "f12"
        
        # xterm ESC [ letter 
        when "[A"
          key.name = "up"
        when "[B"
          key.name = "down"
        when "[C"
          key.name = "right"
        when "[D"
          key.name = "left"
        when "[E"
          key.name = "clear"
        when "[F"
          key.name = "end"
        when "[H"
          key.name = "home"
        
        # xterm/gnome ESC O letter 
        when "OA"
          key.name = "up"
        when "OB"
          key.name = "down"
        when "OC"
          key.name = "right"
        when "OD"
          key.name = "left"
        when "OE"
          key.name = "clear"
        when "OF"
          key.name = "end"
        when "OH"
          key.name = "home"
        
        # xterm/rxvt ESC [ number ~ 
        when "[1~"
          key.name = "home"
        when "[2~"
          key.name = "insert"
        when "[3~"
          key.name = "delete"
        when "[4~"
          key.name = "end"
        when "[5~"
          key.name = "pageup"
        when "[6~"
          key.name = "pagedown"
        
        # putty 
        when "[[5~"
          key.name = "pageup"
        when "[[6~"
          key.name = "pagedown"
        
        # rxvt 
        when "[7~"
          key.name = "home"
        when "[8~"
          key.name = "end"
        
        # rxvt keys with modifiers 
        when "[a"
          key.name = "up"
          key.shift = true
        when "[b"
          key.name = "down"
          key.shift = true
        when "[c"
          key.name = "right"
          key.shift = true
        when "[d"
          key.name = "left"
          key.shift = true
        when "[e"
          key.name = "clear"
          key.shift = true
        when "[2$"
          key.name = "insert"
          key.shift = true
        when "[3$"
          key.name = "delete"
          key.shift = true
        when "[5$"
          key.name = "pageup"
          key.shift = true
        when "[6$"
          key.name = "pagedown"
          key.shift = true
        when "[7$"
          key.name = "home"
          key.shift = true
        when "[8$"
          key.name = "end"
          key.shift = true
        when "Oa"
          key.name = "up"
          key.ctrl = true
        when "Ob"
          key.name = "down"
          key.ctrl = true
        when "Oc"
          key.name = "right"
          key.ctrl = true
        when "Od"
          key.name = "left"
          key.ctrl = true
        when "Oe"
          key.name = "clear"
          key.ctrl = true
        when "[2^"
          key.name = "insert"
          key.ctrl = true
        when "[3^"
          key.name = "delete"
          key.ctrl = true
        when "[5^"
          key.name = "pageup"
          key.ctrl = true
        when "[6^"
          key.name = "pagedown"
          key.ctrl = true
        when "[7^"
          key.name = "home"
          key.ctrl = true
        when "[8^"
          key.name = "end"
          key.ctrl = true
        
        # misc. 
        when "[Z"
          key.name = "tab"
          key.shift = true
        else
          key.name = "undefined"
    
    # Don't emit a key if no name was found
    key = `undefined`  if util.isUndefined(key.name)
    ch = s  if s.length is 1
    stream.emit "keypress", ch, key  if key or ch
    return

  return

###*
moves the cursor to the x and y coordinate on the given stream
###
cursorTo = (stream, x, y) ->
  return  if util.isNullOrUndefined(stream)
  return  if not util.isNumber(x) and not util.isNumber(y)
  throw new Error("Can't set cursor row without also setting it's column")  unless util.isNumber(x)
  unless util.isNumber(y)
    stream.write "\u001b[" + (x + 1) + "G"
  else
    stream.write "\u001b[" + (y + 1) + ";" + (x + 1) + "H"
  return

###*
moves the cursor relative to its current location
###
moveCursor = (stream, dx, dy) ->
  return  if util.isNullOrUndefined(stream)
  if dx < 0
    stream.write "\u001b[" + (-dx) + "D"
  else stream.write "\u001b[" + dx + "C"  if dx > 0
  if dy < 0
    stream.write "\u001b[" + (-dy) + "A"
  else stream.write "\u001b[" + dy + "B"  if dy > 0
  return

###*
clears the current line the cursor is on:
-1 for left of the cursor
+1 for right of the cursor
0 for the entire line
###
clearLine = (stream, dir) ->
  return  if util.isNullOrUndefined(stream)
  if dir < 0
    
    # to the beginning
    stream.write "\u001b[1K"
  else if dir > 0
    
    # to the end
    stream.write "\u001b[0K"
  else
    
    # entire line
    stream.write "\u001b[2K"
  return

###*
clears the screen from the current position of the cursor down
###
clearScreenDown = (stream) ->
  return  if util.isNullOrUndefined(stream)
  stream.write "\u001b[0J"
  return

###*
Returns the number of columns required to display the given string.
###
getStringWidth = (str) ->
  width = 0
  str = stripVTControlCharacters(str)
  i = 0
  len = str.length

  while i < len
    code = codePointAt(str, i)
    # surrogates
    i++  if code >= 0x10000
    if isFullWidthCodePoint(code)
      width += 2
    else
      width++
    i++
  width

###*
Returns true if the character represented by a given
Unicode code point is full-width. Otherwise returns false.
###
isFullWidthCodePoint = (code) ->
  return false  if isNaN(code)
  
  # Code points are derived from:
  # http://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt
  # Hangul Jamo
  # LEFT-POINTING ANGLE BRACKET
  # RIGHT-POINTING ANGLE BRACKET
  # CJK Radicals Supplement .. Enclosed CJK Letters and Months
  
  # Enclosed CJK Letters and Months .. CJK Unified Ideographs Extension A
  
  # CJK Unified Ideographs .. Yi Radicals
  
  # Hangul Jamo Extended-A
  
  # Hangul Syllables
  
  # CJK Compatibility Ideographs
  
  # Vertical Forms
  
  # CJK Compatibility Forms .. Small Form Variants
  
  # Halfwidth and Fullwidth Forms
  
  # Kana Supplement
  
  # Enclosed Ideographic Supplement
  
  # CJK Unified Ideographs Extension B .. Tertiary Ideographic Plane
  return true  if code >= 0x1100 and (code <= 0x115f or 0x2329 is code or 0x232a is code or (0x2e80 <= code and code <= 0x3247 and code isnt 0x303f) or 0x3250 <= code and code <= 0x4dbf or 0x4e00 <= code and code <= 0xa4c6 or 0xa960 <= code and code <= 0xa97c or 0xac00 <= code and code <= 0xd7a3 or 0xf900 <= code and code <= 0xfaff or 0xfe10 <= code and code <= 0xfe19 or 0xfe30 <= code and code <= 0xfe6b or 0xff01 <= code and code <= 0xff60 or 0xffe0 <= code and code <= 0xffe6 or 0x1b000 <= code and code <= 0x1b001 or 0x1f200 <= code and code <= 0x1f251 or 0x20000 <= code and code <= 0x3fffd)
  false

###*
Returns the Unicode code point for the character at the
given index in the given string. Similar to String.charCodeAt(),
but this function handles surrogates (code point >= 0x10000).
###
codePointAt = (str, index) ->
  code = str.charCodeAt(index)
  low = undefined
  if 0xd800 <= code and code <= 0xdbff # High surrogate
    low = str.charCodeAt(index + 1)
    code = 0x10000 + (code - 0xd800) * 0x400 + (low - 0xdc00)  unless isNaN(low)
  code

###*
Tries to remove all VT control characters. Use to estimate displayed
string width. May be buggy due to not running a real state machine
###
stripVTControlCharacters = (str) ->
  str = str.replace(new RegExp(functionKeyCodeReAnywhere.source, "g"), "")
  str.replace new RegExp(metaKeyCodeReAnywhere.source, "g"), ""
"use strict"
kHistorySize = 30
util = require("util")
inherits = require("util").inherits
EventEmitter = require("events").EventEmitter
exports.createInterface = (input, output, completer, terminal) ->
  rl = undefined
  if arguments.length is 1
    rl = new Interface(input)
  else
    rl = new Interface(input, output, completer, terminal)
  rl

inherits Interface, EventEmitter
Interface::__defineGetter__ "columns", ->
  columns = Infinity
  columns = @output.columns  if @output and @output.columns
  columns

Interface::setPrompt = (prompt) ->
  @_prompt = prompt
  return

Interface::_setRawMode = (mode) ->
  @input.setRawMode mode  if util.isFunction(@input.setRawMode)

Interface::prompt = (preserveCursor) ->
  @resume()  if @paused
  if @terminal
    @cursor = 0  unless preserveCursor
    @_refreshLine()
  else
    @_writeToOutput @_prompt
  return

Interface::question = (query, cb) ->
  if util.isFunction(cb)
    if @_questionCallback
      @prompt()
    else
      @_oldPrompt = @_prompt
      @setPrompt query
      @_questionCallback = cb
      @prompt()
  return

Interface::_onLine = (line) ->
  if @_questionCallback
    cb = @_questionCallback
    @_questionCallback = null
    @setPrompt @_oldPrompt
    cb line
  else
    @emit "line", line
  return

Interface::_writeToOutput = _writeToOutput = (stringToWrite) ->
  throw new TypeError("stringToWrite must be a string")  unless util.isString(stringToWrite)
  @output.write stringToWrite  unless util.isNullOrUndefined(@output)
  return

Interface::_addHistory = ->
  return ""  if @line.length is 0
  if @history.length is 0 or @history[0] isnt @line
    @history.unshift @line
    @history.pop()  if @history.length > kHistorySize
  @historyIndex = -1
  @history[0]

Interface::_refreshLine = ->
  line = @_prompt + @line
  dispPos = @_getDisplayPos(line)
  lineCols = dispPos.cols
  lineRows = dispPos.rows
  cursorPos = @_getCursorPos()
  prevRows = @prevRows or 0
  exports.moveCursor @output, 0, -prevRows  if prevRows > 0
  exports.cursorTo @output, 0
  exports.clearScreenDown @output
  @_writeToOutput line
  @_writeToOutput " "  if lineCols is 0
  exports.cursorTo @output, cursorPos.cols
  diff = lineRows - cursorPos.rows
  exports.moveCursor @output, 0, -diff  if diff > 0
  @prevRows = cursorPos.rows
  return

Interface::close = ->
  return  if @closed
  @pause()
  @_setRawMode false  if @terminal
  @closed = true
  @emit "close"
  return

Interface::pause = ->
  return  if @paused
  @input.pause()
  @paused = true
  @emit "pause"
  this

Interface::resume = ->
  return  unless @paused
  @input.resume()
  @paused = false
  @emit "resume"
  this

Interface::write = (d, key) ->
  @resume()  if @paused
  (if @terminal then @_ttyWrite(d, key) else @_normalWrite(d))
  return

lineEnding = /\r?\n|\r(?!\n)/
Interface::_normalWrite = (b) ->
  return  if util.isUndefined(b)
  string = @_decoder.write(b)
  if @_sawReturn
    string = string.replace(/^\n/, "")
    @_sawReturn = false
  newPartContainsEnding = lineEnding.test(string)
  if @_line_buffer
    string = @_line_buffer + string
    @_line_buffer = null
  if newPartContainsEnding
    @_sawReturn = /\r$/.test(string)
    lines = string.split(lineEnding)
    string = lines.pop()
    @_line_buffer = string
    lines.forEach ((line) ->
      @_onLine line
      return
    ), this
  else @_line_buffer = string  if string
  return

Interface::_insertString = (c) ->
  if @cursor < @line.length
    beg = @line.slice(0, @cursor)
    end = @line.slice(@cursor, @line.length)
    @line = beg + c + end
    @cursor += c.length
    @_refreshLine()
  else
    @line += c
    @cursor += c.length
    if @_getCursorPos().cols is 0
      @_refreshLine()
    else
      @_writeToOutput c
    @_moveCursor 0
  return

Interface::_tabComplete = ->
  self = this
  self.pause()
  self.completer self.line.slice(0, self.cursor), (err, rv) ->
    self.resume()
    return  if err
    completions = rv[0]
    completeOn = rv[1]
    if completions and completions.length
      if completions.length is 1
        self._insertString completions[0].slice(completeOn.length)
      else
        self._writeToOutput "\r\n"
        width = completions.reduce((a, b) ->
          (if a.length > b.length then a else b)
        ).length + 2
        maxColumns = Math.floor(self.columns / width) or 1
        group = []
        c = undefined
        i = 0
        compLen = completions.length

        while i < compLen
          c = completions[i]
          if c is ""
            handleGroup self, group, width, maxColumns
            group = []
          else
            group.push c
          i++
        handleGroup self, group, width, maxColumns
        f = completions.filter((e) ->
          e  if e
        )
        prefix = commonPrefix(f)
        self._insertString prefix.slice(completeOn.length)  if prefix.length > completeOn.length
      self._refreshLine()
    return

  return

Interface::_wordLeft = ->
  if @cursor > 0
    leading = @line.slice(0, @cursor)
    match = leading.match(/([^\w\s]+|\w+|)\s*$/)
    @_moveCursor -match[0].length
  return

Interface::_wordRight = ->
  if @cursor < @line.length
    trailing = @line.slice(@cursor)
    match = trailing.match(/^(\s+|\W+|\w+)\s*/)
    @_moveCursor match[0].length
  return

Interface::_deleteLeft = ->
  if @cursor > 0 and @line.length > 0
    @line = @line.slice(0, @cursor - 1) + @line.slice(@cursor, @line.length)
    @cursor--
    @_refreshLine()
  return

Interface::_deleteRight = ->
  @line = @line.slice(0, @cursor) + @line.slice(@cursor + 1, @line.length)
  @_refreshLine()
  return

Interface::_deleteWordLeft = ->
  if @cursor > 0
    leading = @line.slice(0, @cursor)
    match = leading.match(/([^\w\s]+|\w+|)\s*$/)
    leading = leading.slice(0, leading.length - match[0].length)
    @line = leading + @line.slice(@cursor, @line.length)
    @cursor = leading.length
    @_refreshLine()
  return

Interface::_deleteWordRight = ->
  if @cursor < @line.length
    trailing = @line.slice(@cursor)
    match = trailing.match(/^(\s+|\W+|\w+)\s*/)
    @line = @line.slice(0, @cursor) + trailing.slice(match[0].length)
    @_refreshLine()
  return

Interface::_deleteLineLeft = ->
  @line = @line.slice(@cursor)
  @cursor = 0
  @_refreshLine()
  return

Interface::_deleteLineRight = ->
  @line = @line.slice(0, @cursor)
  @_refreshLine()
  return

Interface::clearLine = ->
  @_moveCursor +Infinity
  @_writeToOutput "\r\n"
  @line = ""
  @cursor = 0
  @prevRows = 0
  return

Interface::_line = ->
  line = @_addHistory()
  @clearLine()
  @_onLine line
  return

Interface::_historyNext = ->
  if @historyIndex > 0
    @historyIndex--
    @line = @history[@historyIndex]
    @cursor = @line.length
    @_refreshLine()
  else if @historyIndex is 0
    @historyIndex = -1
    @cursor = 0
    @line = ""
    @_refreshLine()
  return

Interface::_historyPrev = ->
  if @historyIndex + 1 < @history.length
    @historyIndex++
    @line = @history[@historyIndex]
    @cursor = @line.length
    @_refreshLine()
  return

Interface::_getDisplayPos = (str) ->
  offset = 0
  col = @columns
  row = 0
  code = undefined
  str = stripVTControlCharacters(str)
  i = 0
  len = str.length

  while i < len
    code = codePointAt(str, i)
    i++  if code >= 0x10000
    if code is 0x0a
      offset = 0
      row += 1
      continue
    if isFullWidthCodePoint(code)
      offset++  if (offset + 1) % col is 0
      offset += 2
    else
      offset++
    i++
  cols = offset % col
  rows = row + (offset - cols) / col
  cols: cols
  rows: rows

Interface::_getCursorPos = ->
  columns = @columns
  strBeforeCursor = @_prompt + @line.substring(0, @cursor)
  dispPos = @_getDisplayPos(stripVTControlCharacters(strBeforeCursor))
  cols = dispPos.cols
  rows = dispPos.rows
  if cols + 1 is columns and @cursor < @line.length and isFullWidthCodePoint(codePointAt(@line, @cursor))
    rows++
    cols = 0
  cols: cols
  rows: rows

Interface::_moveCursor = (dx) ->
  oldcursor = @cursor
  oldPos = @_getCursorPos()
  @cursor += dx
  if @cursor < 0
    @cursor = 0
  else @cursor = @line.length  if @cursor > @line.length
  newPos = @_getCursorPos()
  if oldPos.rows is newPos.rows
    diffCursor = @cursor - oldcursor
    diffWidth = undefined
    if diffCursor < 0
      diffWidth = -getStringWidth(@line.substring(@cursor, oldcursor))
    else diffWidth = getStringWidth(@line.substring(@cursor, oldcursor))  if diffCursor > 0
    exports.moveCursor @output, diffWidth, 0
    @prevRows = newPos.rows
  else
    @_refreshLine()
  return

Interface::_ttyWrite = (s, key) ->
  key = key or {}
  return  if key.name is "escape"
  if key.ctrl and key.shift
    switch key.name
      when "backspace"
        @_deleteLineLeft()
      when "delete"
        @_deleteLineRight()
  else if key.ctrl
    switch key.name
      when "c"
        if EventEmitter.listenerCount(this, "SIGINT") > 0
          @emit "SIGINT"
        else
          @close()
      when "h"
        @_deleteLeft()
      when "d"
        if @cursor is 0 and @line.length is 0
          @close()
        else @_deleteRight()  if @cursor < @line.length
      when "u"
        @cursor = 0
        @line = ""
        @_refreshLine()
      when "k"
        @_deleteLineRight()
      when "a"
        @_moveCursor -Infinity
      when "e"
        @_moveCursor +Infinity
      when "b"
        @_moveCursor -1
      when "f"
        @_moveCursor +1
      when "l"
        exports.cursorTo @output, 0, 0
        exports.clearScreenDown @output
        @_refreshLine()
      when "n"
        @_historyNext()
      when "p"
        @_historyPrev()
      when "z"
        break  if process.platform is "win32"
        if EventEmitter.listenerCount(this, "SIGTSTP") > 0
          @emit "SIGTSTP"
        else
          process.once "SIGCONT", ((self) ->
            ->
              unless self.paused
                self.pause()
                self.emit "SIGCONT"
              self._setRawMode true
              self._refreshLine()
              return
          )(this)
          @_setRawMode false
          process.kill process.pid, "SIGTSTP"
      when "w", "backspace"
        @_deleteWordLeft()
      when "delete"
        @_deleteWordRight()
      when "left"
        @_wordLeft()
      when "right"
        @_wordRight()
  else if key.meta
    switch key.name
      when "b"
        @_wordLeft()
      when "f"
        @_wordRight()
      when "d", "delete"
        @_deleteWordRight()
      when "backspace"
        @_deleteWordLeft()
  else
    @_sawReturn = false  if @_sawReturn and key.name isnt "enter"
    switch key.name
      when "return"
        @_sawReturn = true
        @_line()
      when "enter"
        if @_sawReturn
          @_sawReturn = false
        else
          @_line()
      when "backspace"
        @_deleteLeft()
      when "delete"
        @_deleteRight()
      when "tab"
        @_tabComplete()
      when "left"
        @_moveCursor -1
      when "right"
        @_moveCursor +1
      when "home"
        @_moveCursor -Infinity
      when "end"
        @_moveCursor +Infinity
      when "up"
        @_historyPrev()
      when "down"
        @_historyNext()
      else
        s = s.toString("utf-8")  if util.isBuffer(s)
        if s
          lines = s.split(/\r\n|\n|\r/)
          i = 0
          len = lines.length

          while i < len
            @_line()  if i > 0
            @_insertString lines[i]
            i++
  return

exports.Interface = Interface
exports.emitKeypressEvents = emitKeypressEvents
metaKeyCodeReAnywhere = /(?:\x1b)([a-zA-Z0-9])/
metaKeyCodeRe = new RegExp("^" + metaKeyCodeReAnywhere.source + "$")
functionKeyCodeReAnywhere = new RegExp("(?:\u001b+)(O|N|\\[|\\[\\[)(?:" + [
  "(\\d+)(?:;(\\d+))?([~^$])"
  "(?:M([@ #!a`])(.)(.))"
  "(?:1;)?(\\d+)?([a-zA-Z])"
].join("|") + ")")
functionKeyCodeRe = new RegExp("^" + functionKeyCodeReAnywhere.source)
escapeCodeReAnywhere = new RegExp([
  functionKeyCodeReAnywhere.source
  metaKeyCodeReAnywhere.source
  /\x1b./.source
].join("|"))
exports.cursorTo = cursorTo
exports.moveCursor = moveCursor
exports.clearLine = clearLine
exports.clearScreenDown = clearScreenDown
exports.getStringWidth = getStringWidth
exports.isFullWidthCodePoint = isFullWidthCodePoint
exports.codePointAt = codePointAt
exports.stripVTControlCharacters = stripVTControlCharacters
