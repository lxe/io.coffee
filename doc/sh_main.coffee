#
#SHJS - Syntax Highlighting in JavaScript
#Copyright (C) 2007, 2008 gnombat@users.sourceforge.net
#License: http://shjs.sourceforge.net/doc/gplv3.html
#
sh_isEmailAddress = (url) ->
  return false  if /^mailto:/.test(url)
  url.indexOf("@") isnt -1
sh_setHref = (tags, numTags, inputString) ->
  url = inputString.substring(tags[numTags - 2].pos, tags[numTags - 1].pos)
  url = url.substr(1, url.length - 2)  if url.length >= 2 and url.charAt(0) is "<" and url.charAt(url.length - 1) is ">"
  url = "mailto:" + url  if sh_isEmailAddress(url)
  tags[numTags - 2].node.href = url
  return

#
#Konqueror has a bug where the regular expression /$/g will not match at the end
#of a line more than once:
#
#  var regex = /$/g;
#  var match;
#
#  var line = '1234567890';
#  regex.lastIndex = 10;
#  match = regex.exec(line);
#
#  var line2 = 'abcde';
#  regex.lastIndex = 5;
#  match = regex.exec(line2);  // fails
#
sh_konquerorExec = (s) ->
  result = [""]
  result.index = s.length
  result.input = s
  result

###*
Highlights all elements containing source code in a text string.  The return
value is an array of objects, each representing an HTML start or end tag.  Each
object has a property named pos, which is an integer representing the text
offset of the tag. Every start tag also has a property named node, which is the
DOM element started by the tag. End tags do not have this property.
@param  inputString  a text string
@param  language  a language definition object
@return  an array of tag objects
###
sh_highlightString = (inputString, language) ->
  if /Konqueror/.test(navigator.userAgent)
    unless language.konquered
      s = 0

      while s < language.length
        p = 0

        while p < language[s].length
          r = language[s][p][0]
          r.exec = sh_konquerorExec  if r.source is "$"
          p++
        s++
      language.konquered = true
  a = document.createElement("a")
  span = document.createElement("span")
  
  # the result
  tags = []
  numTags = 0
  
  # each element is a pattern object from language
  patternStack = []
  
  # the current position within inputString
  pos = 0
  
  # the name of the current style, or null if there is no current style
  currentStyle = null
  output = (s, style) ->
    length = s.length
    
    # this is more than just an optimization - we don't want to output empty <span></span> elements
    return  if length is 0
    unless style
      stackLength = patternStack.length
      if stackLength isnt 0
        pattern = patternStack[stackLength - 1]
        
        # check whether this is a state or an environment
        
        # it's not a state - it's an environment; use the style for this environment
        style = pattern[1]  unless pattern[3]
    if currentStyle isnt style
      if currentStyle
        tags[numTags++] = pos: pos
        sh_setHref tags, numTags, inputString  if currentStyle is "sh_url"
      if style
        clone = undefined
        if style is "sh_url"
          clone = a.cloneNode(false)
        else
          clone = span.cloneNode(false)
        clone.className = style
        tags[numTags++] =
          node: clone
          pos: pos
    pos += length
    currentStyle = style
    return

  endOfLinePattern = /\r\n|\r|\n/g
  endOfLinePattern.lastIndex = 0
  inputStringLength = inputString.length
  while pos < inputStringLength
    start = pos
    end = undefined
    startOfNextLine = undefined
    endOfLineMatch = endOfLinePattern.exec(inputString)
    if endOfLineMatch is null
      end = inputStringLength
      startOfNextLine = inputStringLength
    else
      end = endOfLineMatch.index
      startOfNextLine = endOfLinePattern.lastIndex
    line = inputString.substring(start, end)
    matchCache = []
    loop
      posWithinLine = pos - start
      stateIndex = undefined
      stackLength = patternStack.length
      if stackLength is 0
        stateIndex = 0
      else
        
        # get the next state
        stateIndex = patternStack[stackLength - 1][2]
      state = language[stateIndex]
      numPatterns = state.length
      mc = matchCache[stateIndex]
      mc = matchCache[stateIndex] = []  unless mc
      bestMatch = null
      bestPatternIndex = -1
      i = 0

      while i < numPatterns
        match = undefined
        if i < mc.length and (mc[i] is null or posWithinLine <= mc[i].index)
          match = mc[i]
        else
          regex = state[i][0]
          regex.lastIndex = posWithinLine
          match = regex.exec(line)
          mc[i] = match
        if match isnt null and (bestMatch is null or match.index < bestMatch.index)
          bestMatch = match
          bestPatternIndex = i
          break  if match.index is posWithinLine
        i++
      if bestMatch is null
        output line.substring(posWithinLine), null
        break
      else
        
        # got a match
        output line.substring(posWithinLine, bestMatch.index), null  if bestMatch.index > posWithinLine
        pattern = state[bestPatternIndex]
        newStyle = pattern[1]
        matchedString = undefined
        if newStyle instanceof Array
          subexpression = 0

          while subexpression < newStyle.length
            matchedString = bestMatch[subexpression + 1]
            output matchedString, newStyle[subexpression]
            subexpression++
        else
          matchedString = bestMatch[0]
          output matchedString, newStyle
        switch pattern[2]
          
          # do nothing
          when -1, -2
            
            # exit
            patternStack.pop()
          when -3
            
            # exitall
            patternStack.length = 0
          else
            
            # this was the start of a delimited pattern or a state/environment
            patternStack.push pattern
    
    # end of the line
    if currentStyle
      tags[numTags++] = pos: pos
      sh_setHref tags, numTags, inputString  if currentStyle is "sh_url"
      currentStyle = null
    pos = startOfNextLine
  tags

#//////////////////////////////////////////////////////////////////////////////
# DOM-dependent functions
sh_getClasses = (element) ->
  result = []
  htmlClass = element.className
  if htmlClass and htmlClass.length > 0
    htmlClasses = htmlClass.split(" ")
    i = 0

    while i < htmlClasses.length
      result.push htmlClasses[i]  if htmlClasses[i].length > 0
      i++
  result
sh_addClass = (element, name) ->
  htmlClasses = sh_getClasses(element)
  i = 0

  while i < htmlClasses.length
    return  if name.toLowerCase() is htmlClasses[i].toLowerCase()
    i++
  htmlClasses.push name
  element.className = htmlClasses.join(" ")
  return

###*
Extracts the tags from an HTML DOM NodeList.
@param  nodeList  a DOM NodeList
@param  result  an object with text, tags and pos properties
###
sh_extractTagsFromNodeList = (nodeList, result) ->
  length = nodeList.length
  i = 0

  while i < length
    node = nodeList.item(i)
    switch node.nodeType
      when 1
        if node.nodeName.toLowerCase() is "br"
          terminator = undefined
          if /MSIE/.test(navigator.userAgent)
            terminator = "\r"
          else
            terminator = "\n"
          result.text.push terminator
          result.pos++
        else
          result.tags.push
            node: node.cloneNode(false)
            pos: result.pos

          sh_extractTagsFromNodeList node.childNodes, result
          result.tags.push pos: result.pos
      when 3, 4
        result.text.push node.data
        result.pos += node.length
    i++
  return

###*
Extracts the tags from the text of an HTML element. The extracted tags will be
returned as an array of tag objects. See sh_highlightString for the format of
the tag objects.
@param  element  a DOM element
@param  tags  an empty array; the extracted tag objects will be returned in it
@return  the text of the element
@see  sh_highlightString
###
sh_extractTags = (element, tags) ->
  result = {}
  result.text = []
  result.tags = tags
  result.pos = 0
  sh_extractTagsFromNodeList element.childNodes, result
  result.text.join ""

###*
Merges the original tags from an element with the tags produced by highlighting.
@param  originalTags  an array containing the original tags
@param  highlightTags  an array containing the highlighting tags - these must not overlap
@result  an array containing the merged tags
###
sh_mergeTags = (originalTags, highlightTags) ->
  numOriginalTags = originalTags.length
  return highlightTags  if numOriginalTags is 0
  numHighlightTags = highlightTags.length
  return originalTags  if numHighlightTags is 0
  result = []
  originalIndex = 0
  highlightIndex = 0
  while originalIndex < numOriginalTags and highlightIndex < numHighlightTags
    originalTag = originalTags[originalIndex]
    highlightTag = highlightTags[highlightIndex]
    if originalTag.pos <= highlightTag.pos
      result.push originalTag
      originalIndex++
    else
      result.push highlightTag
      if highlightTags[highlightIndex + 1].pos <= originalTag.pos
        highlightIndex++
        result.push highlightTags[highlightIndex]
        highlightIndex++
      else
        
        # new end tag
        result.push pos: originalTag.pos
        
        # new start tag
        highlightTags[highlightIndex] =
          node: highlightTag.node.cloneNode(false)
          pos: originalTag.pos
  while originalIndex < numOriginalTags
    result.push originalTags[originalIndex]
    originalIndex++
  while highlightIndex < numHighlightTags
    result.push highlightTags[highlightIndex]
    highlightIndex++
  result

###*
Inserts tags into text.
@param  tags  an array of tag objects
@param  text  a string representing the text
@return  a DOM DocumentFragment representing the resulting HTML
###
sh_insertTags = (tags, text) ->
  doc = document
  result = document.createDocumentFragment()
  tagIndex = 0
  numTags = tags.length
  textPos = 0
  textLength = text.length
  currentNode = result
  
  # output one tag or text node every iteration
  while textPos < textLength or tagIndex < numTags
    tag = undefined
    tagPos = undefined
    if tagIndex < numTags
      tag = tags[tagIndex]
      tagPos = tag.pos
    else
      tagPos = textLength
    if tagPos <= textPos
      
      # output the tag
      if tag.node
        
        # start tag
        newNode = tag.node
        currentNode.appendChild newNode
        currentNode = newNode
      else
        
        # end tag
        currentNode = currentNode.parentNode
      tagIndex++
    else
      
      # output text
      currentNode.appendChild doc.createTextNode(text.substring(textPos, tagPos))
      textPos = tagPos
  result

###*
Highlights an element containing source code.  Upon completion of this function,
the element will have been placed in the "sh_sourceCode" class.
@param  element  a DOM <pre> element containing the source code to be highlighted
@param  language  a language definition object
###
sh_highlightElement = (element, language) ->
  sh_addClass element, "sh_sourceCode"
  originalTags = []
  inputString = sh_extractTags(element, originalTags)
  highlightTags = sh_highlightString(inputString, language)
  tags = sh_mergeTags(originalTags, highlightTags)
  documentFragment = sh_insertTags(tags, inputString)
  element.removeChild element.firstChild  while element.hasChildNodes()
  element.appendChild documentFragment
  return
sh_getXMLHttpRequest = ->
  if window.ActiveXObject
    return new ActiveXObject("Msxml2.XMLHTTP")
  else return new XMLHttpRequest()  if window.XMLHttpRequest
  throw "No XMLHttpRequest implementation available"return
sh_load = (language, element, prefix, suffix) ->
  if language of sh_requests
    sh_requests[language].push element
    return
  sh_requests[language] = [element]
  request = sh_getXMLHttpRequest()
  url = prefix + "sh_" + language + suffix
  request.open "GET", url, true
  request.onreadystatechange = ->
    if request.readyState is 4
      try
        if not request.status or request.status is 200
          eval request.responseText
          elements = sh_requests[language]
          i = 0

          while i < elements.length
            sh_highlightElement elements[i], sh_languages[language]
            i++
        else
          throw "HTTP error: status " + request.status
      finally
        request = null
    return

  request.send null
  return

###*
Highlights all elements containing source code on the current page. Elements
containing source code must be "pre" elements with a "class" attribute of
"sh_LANGUAGE", where LANGUAGE is a valid language identifier; e.g., "sh_java"
identifies the element as containing "java" language source code.
###
highlight = (prefix, suffix, tag) ->
  nodeList = document.getElementsByTagName(tag)
  i = 0

  while i < nodeList.length
    element = nodeList.item(i)
    htmlClasses = sh_getClasses(element)
    highlighted = false
    donthighlight = false
    j = 0

    while j < htmlClasses.length
      htmlClass = htmlClasses[j].toLowerCase()
      if htmlClass is "sh_none"
        donthighlight = true
        continue
      if htmlClass.substr(0, 3) is "sh_"
        language = htmlClass.substring(3)
        if language of sh_languages
          sh_highlightElement element, sh_languages[language]
          highlighted = true
        else if typeof (prefix) is "string" and typeof (suffix) is "string"
          sh_load language, element, prefix, suffix
        else
          throw "Found <" + tag + "> element with class=\"" + htmlClass + "\", but no such language exists"
        break
      j++
    sh_highlightElement element, sh_languages["javascript"]  if highlighted is false and donthighlight is false
    i++
  return
sh_highlightDocument = (prefix, suffix) ->
  highlight prefix, suffix, "tt"
  highlight prefix, suffix, "code"
  highlight prefix, suffix, "pre"
  return
@sh_languages = {}  unless @sh_languages
sh_requests = {}
