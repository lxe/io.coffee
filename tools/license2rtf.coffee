
#
# * This filter consumes a stream of characters and emits one string per line.
# 
LineSplitter = ->
  self = this
  buffer = ""
  Stream.call this
  @writable = true
  @write = (data) ->
    lines = (buffer + data).split(/\r\n|\n\r|\n|\r/)
    i = 0

    while i < lines.length - 1
      self.emit "data", lines[i]
      i++
    buffer = lines[lines.length - 1]
    true

  @end = (data) ->
    @write data or ""
    self.emit "data", buffer  if buffer
    self.emit "end"
    return

  return

#
# * This filter consumes lines and emits paragraph objects.
# 
ParagraphParser = ->
  resetParagraph = ->
    is_first_line_in_paragraph = true
    paragraph_line_indent = -1
    paragraph =
      li: ""
      in_license_block: block_is_license_block
      lines: []

    return
  resetBlock = (is_license_block) ->
    block_is_license_block = is_license_block
    block_has_c_style_comment = false
    resetParagraph()
    return
  flushParagraph = ->
    self.emit "data", paragraph  if paragraph.lines.length or paragraph.li
    resetParagraph()
    return
  parseLine = (line) ->
    
    # Strip trailing whitespace
    line = line.replace(/\s*$/, "")
    
    # Detect block separator
    if /^\s*(=|"){3,}\s*$/.test(line)
      flushParagraph()
      resetBlock not block_is_license_block
      return
    
    # Strip comments around block
    if block_is_license_block
      block_has_c_style_comment = /^\s*(\/\*)/.test(line)  unless block_has_c_style_comment
      if block_has_c_style_comment
        prev = line
        line = line.replace(/^(\s*?)(?:\s?\*\/|\/\*\s|\s\*\s?)/, "$1")
        line = line.replace(/^\s{2}/, "")  if prev is line
        block_has_c_style_comment = false  if /\*\//.test(prev)
      else
        
        # Strip C++ and perl style comments.
        line = line.replace(/^(\s*)(?:\/\/\s?|#\s?)/, "$1")
    
    # Detect blank line (paragraph separator)
    unless /\S/.test(line)
      flushParagraph()
      return
    
    # Detect separator "lines" within a block. These mark a paragraph break
    # and are stripped from the output.
    if /^\s*[=*\-]{5,}\s*$/.test(line)
      flushParagraph()
      return
    
    # Find out indentation level and the start of a lied or numbered list;
    result = /^(\s*)(\d+\.|\*|-)?\s*/.exec(line)
    assert.ok result
    
    # The number of characters that will be stripped from the beginning of
    # the line.
    line_strip_length = result[0].length
    
    # The indentation size that will be used to detect indentation jumps.
    # Fudge by 1 space.
    line_indent = Math.floor(result[0].length / 2) * 2
    
    # The indentation level that will be exported
    level = Math.floor(result[1].length / 2)
    
    # The list indicator that precedes the actual content, if any.
    line_li = result[2]
    
    # Flush the paragraph when there is a li or an indentation jump
    if line_li or (line_indent isnt paragraph_line_indent and paragraph_line_indent isnt -1)
      flushParagraph()
      paragraph.li = line_li
    
    # Set the paragraph indent that we use to detect indentation jumps. When
    # we just detected a list indicator, wait
    # for the next line to arrive before setting this.
    paragraph_line_indent = line_indent  if not line_li and paragraph_line_indent isnt -1
    
    # Set the output indent level if it has not been set yet.
    paragraph.level = level  if paragraph.level is `undefined`
    
    # Strip leading whitespace and li.
    line = line.slice(line_strip_length)
    paragraph.lines.push line  if line
    is_first_line_in_paragraph = false
    return
  self = this
  block_is_license_block = false
  block_has_c_style_comment = undefined
  is_first_line_in_paragraph = undefined
  paragraph_line_indent = undefined
  paragraph = undefined
  Stream.call this
  @writable = true
  resetBlock false
  @write = (data) ->
    parseLine data + ""
    true

  @end = (data) ->
    parseLine data + ""  if data
    flushParagraph()
    self.emit "end"
    return

  return

#
# * This filter consumes paragraph objects and emits modified paragraph objects.
# * The lines within the paragraph are unwrapped where appropriate. It also
# * replaces multiple consecutive whitespace characters by a single one.
# 
Unwrapper = ->
  self = this
  Stream.call this
  @writable = true
  @write = (paragraph) ->
    lines = paragraph.lines
    break_after = []
    i = undefined
    i = 0
    while i < lines.length - 1
      line = lines[i]
      
      # When a line is really short, the line was probably kept separate for a
      # reason.
      if line.length < 50
        
        # If the first word on the next line really didn't fit after the line,
        # it probably was just ordinary wrapping after all.
        next_first_word_length = lines[i + 1].replace(/\s.*$/, "").length
        break_after[i] = true  if line.length + next_first_word_length < 60
      i++
    i = 0
    while i < lines.length - 1
      unless break_after[i]
        lines[i] += " " + lines.splice(i + 1, 1)[0]
      else
        i++
    i = 0
    while i < lines.length
      
      # Replace multiple whitespace characters by a single one, and strip
      # trailing whitespace.
      lines[i] = lines[i].replace(/\s+/g, " ").replace(/\s+$/, "")
      i++
    self.emit "data", paragraph
    return

  @end = (data) ->
    self.write data  if data
    self.emit "end"
    return

  return

#
# * This filter generates an rtf document from a stream of paragraph objects.
# 
RtfGenerator = ->
  toHex = (number, length) ->
    hex = (~~number).toString(16)
    hex = "0" + hex  while hex.length < length
    hex
  rtfEscape = (string) ->
    string.replace(/[\\\{\}]/g, (m) ->
      "\\" + m
    ).replace(/\t/g, ->
      "\\tab "
    ).replace(/[\x00-\x1f\x7f-\xff]/g, (m) ->
      "\\'" + toHex(m.charCodeAt(0), 2)
    ).replace(/\ufeff/g, "").replace /[\u0100-\uffff]/g, (m) ->
      "\\u" + toHex(m.charCodeAt(0), 4) + "?"

  emitHeader = ->
    self.emit "data", "{\\rtf1\\ansi\\ansicpg1252\\uc1\\deff0\\deflang1033" + "{\\fonttbl{\\f0\\fswiss\\fcharset0 Tahoma;}}\\fs20\n" + "{\\*\\generator txt2rtf 0.0.1;}\n"
    return
  emitFooter = ->
    self.emit "data", "}"
    return
  self = this
  did_write_anything = false
  Stream.call this
  @writable = true
  @write = (paragraph) ->
    unless did_write_anything
      emitHeader()
      did_write_anything = true
    li = paragraph.li
    level = paragraph.level + ((if li then 1 else 0))
    lic = paragraph.in_license_block
    rtf = "\\pard"
    rtf += "\\sa150\\sl300\\slmult1"
    rtf += "\\li" + (level * 240)  if level > 0
    if li
      rtf += "\\tx" + (level) * 240
      rtf += "\\fi-240"
    rtf += "\\ri240"  if lic
    rtf += "\\b"  unless lic
    rtf += " " + li + "\\tab"  if li
    rtf += " "
    rtf += paragraph.lines.map(rtfEscape).join("\\line ")
    rtf += "\\b0"  unless lic
    rtf += "\\par\n"
    self.emit "data", rtf
    return

  @end = (data) ->
    self.write data  if data
    emitFooter()  if did_write_anything
    self.emit "end"
    return

  return
assert = require("assert")
Stream = require("stream")
inherits = require("util").inherits
inherits LineSplitter, Stream
inherits ParagraphParser, Stream
inherits Unwrapper, Stream
inherits RtfGenerator, Stream
stdin = process.stdin
stdout = process.stdout
line_splitter = new LineSplitter()
paragraph_parser = new ParagraphParser()
unwrapper = new Unwrapper()
rtf_generator = new RtfGenerator()
stdin.setEncoding "utf-8"
stdin.resume()
stdin.pipe line_splitter
line_splitter.pipe paragraph_parser
paragraph_parser.pipe unwrapper
unwrapper.pipe rtf_generator
rtf_generator.pipe stdout
