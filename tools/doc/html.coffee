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
toHTML = (input, filename, template, cb) ->
  lexed = marked.lexer(input)
  fs.readFile template, "utf8", (er, template) ->
    return cb(er)  if er
    render lexed, filename, template, cb
    return

  return
render = (lexed, filename, template, cb) ->
  
  # get the section
  section = getSection(lexed)
  filename = path.basename(filename, ".markdown")
  lexed = parseLists(lexed)
  
  # generate the table of contents.
  # this mutates the lexed contents in-place.
  buildToc lexed, filename, (er, toc) ->
    return cb(er)  if er
    template = template.replace(/__FILENAME__/g, filename)
    template = template.replace(/__SECTION__/g, section)
    template = template.replace(/__VERSION__/g, process.version)
    template = template.replace(/__TOC__/g, toc)
    
    # content has to be the last thing we do with
    # the lexed tokens, because it's destructive.
    content = marked.parser(lexed)
    template = template.replace(/__CONTENT__/g, content)
    cb null, template
    return

  return

# just update the list item text in-place.
# lists that come right after a heading are what we're after.
parseLists = (input) ->
  state = null
  depth = 0
  output = []
  output.links = input.links
  input.forEach (tok) ->
    if tok.type is "code" and tok.text.match(/Stability:.*/g)
      tok.text = parseAPIHeader(tok.text)
      output.push
        type: "html"
        text: tok.text

      return
    if state is null
      state = "AFTERHEADING"  if tok.type is "heading"
      output.push tok
      return
    if state is "AFTERHEADING"
      if tok.type is "list_start"
        state = "LIST"
        if depth is 0
          output.push
            type: "html"
            text: "<div class=\"signature\">"

        depth++
        output.push tok
        return
      state = null
      output.push tok
      return
    if state is "LIST"
      if tok.type is "list_start"
        depth++
        output.push tok
        return
      if tok.type is "list_end"
        depth--
        if depth is 0
          state = null
          output.push
            type: "html"
            text: "</div>"

        output.push tok
        return
      tok.text = parseListItem(tok.text)  if tok.text
    output.push tok
    return

  output
parseListItem = (text) ->
  parts = text.split("`")
  i = undefined
  i = 0
  while i < parts.length
    parts[i] = parts[i].replace(/\{([^\}]+)\}/, "<span class=\"type\">$1</span>")
    i += 2
  
  #XXX maybe put more stuff here?
  parts.join "`"
parseAPIHeader = (text) ->
  text = text.replace(/(.*:)\s(\d)([\s\S]*)/, "<pre class=\"api_stability_$2\">$1 $2$3</pre>")
  text

# section is just the first heading
getSection = (lexed) ->
  section = ""
  i = 0
  l = lexed.length

  while i < l
    tok = lexed[i]
    return tok.text  if tok.type is "heading"
    i++
  ""
buildToc = (lexed, filename, cb) ->
  indent = 0
  toc = []
  depth = 0
  lexed.forEach (tok) ->
    return  if tok.type isnt "heading"
    return cb(new Error("Inappropriate heading level\n" + JSON.stringify(tok)))  if tok.depth - depth > 1
    depth = tok.depth
    id = getId(filename + "_" + tok.text.trim())
    toc.push new Array((depth - 1) * 2 + 1).join(" ") + "* <a href=\"#" + id + "\">" + tok.text + "</a>"
    tok.text += "<span><a class=\"mark\" href=\"#" + id + "\" " + "id=\"" + id + "\">#</a></span>"
    return

  toc = marked.parse(toc.join("\n"))
  cb null, toc
  return
getId = (text) ->
  text = text.toLowerCase()
  text = text.replace(/[^a-z0-9]+/g, "_")
  text = text.replace(/^_+|_+$/, "")
  text = text.replace(/^([^a-z])/, "_$1")
  if idCounters.hasOwnProperty(text)
    text += "_" + (++idCounters[text])
  else
    idCounters[text] = 0
  text
fs = require("fs")
marked = require("marked")
path = require("path")
module.exports = toHTML
idCounters = {}
