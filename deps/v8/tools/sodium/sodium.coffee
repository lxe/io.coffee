# Copyright 2013 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
Sodium = (->
  Code = (name, kind, sourceBegin, sourceEnd, asmBegin, asmEnd, firstSourcePosition, startAddress) ->
    @name = name
    @kind = kind
    @sourceBegin = sourceBegin
    @sourceEnd = sourceEnd
    @asmBegin = asmBegin
    @asmEnd = asmEnd
    @firstSourcePosition = firstSourcePosition
    @startAddress = startAddress
    return
  getCurrentCodeObject = ->
    functionSelect = document.getElementById("function-selector-id")
    functionSelect.options[functionSelect.selectedIndex].codeObject
  getCurrentSourceText = ->
    code = getCurrentCodeObject()
    return ""  if code.sourceBegin is -1 or code.sourceEnd is -1
    fileContent.substring code.sourceBegin, code.sourceEnd
  getCurrentAsmText = ->
    code = getCurrentCodeObject()
    return ""  if code.asmBegin is -1 or code.asmEnd is -1
    fileContent.substring code.asmBegin, code.asmEnd
  setKindByIndex = (index) ->
    selectedFunctionKind = kinds[index]
    return
  processLine = (text, begin, end) ->
    line = text.substring(begin, end)
    if readingSource
      if separatorFilter.exec(line)?
        readingSource = false
      else
        sourceBegin = begin  if sourceBegin is -1
        sourceEnd = end
    else
      if readingAsm
        if codeEndFinder.exec(line)?
          readingAsm = false
          asmEnd = begin
          newCode = new Code(currentFunctionName, currentFunctionKind, sourceBegin, sourceEnd, asmBegin, asmEnd, firstSourcePosition, startAddress)
          codeObjects.push newCode
          currentFunctionKind = null
        else
          if asmBegin is -1
            matches = instructionBeginFinder.exec(line)
            asmBegin = begin  if matches?
          if startAddress is ""
            matches = instructionFinder.exec(line)
            startAddress = matches[1]  if matches?
      else
        matches = kindFinder.exec(line)
        if matches?
          currentFunctionKind = matches[1]
          unless kindsWithSource[currentFunctionKind]
            sourceBegin = -1
            sourceEnd = -1
        else if currentFunctionKind?
          matches = nameFinder.exec(line)
          if matches?
            readingAsm = true
            asmBegin = -1
            currentFunctionName = matches[1]
        else if rawSourceFilter.exec(line)?
          readingSource = true
          sourceBegin = -1
        else
          matches = firstPositionFinder.exec(line)
          firstSourcePosition = parseInt(matches[1])  if matches?
    return
  processLines = (source, size, processLine) ->
    firstChar = 0
    x = 0

    while x < size
      curChar = source[x]
      if curChar is "\n" or curChar is "\r"
        processLine source, firstChar, x
        firstChar = x + 1
      x++
    processLine source, firstChar, size - 1  unless firstChar is size - 1
    return
  processFileContent = ->
    document.getElementById("source-text-pre").innerHTML = ""
    sourceBegin = -1
    codeObjects = []
    processLines fileContent, fileContent.length, processLine
    functionSelectElement = document.getElementById("function-selector-id")
    functionSelectElement.innerHTML = ""
    length = codeObjects.length
    i = 0

    while i < codeObjects.length
      code = codeObjects[i]
      if code.kind is selectedFunctionKind
        optionElement = document.createElement("option")
        optionElement.codeObject = code
        optionElement.text = code.name
        functionSelectElement.add optionElement, null
      ++i
    return
  asmClick = (element) ->
    return  if element is selectedAsm
    selectedAsm.classList.remove "highlight-yellow"  if selectedAsm?
    selectedAsm = element
    selectedAsm.classList.add "highlight-yellow"
    pc = element.firstChild.innerText
    sourceLine = null
    if addressFinder.exec(pc)?
      position = findSourcePosition(pc)
      line = findSourceLine(position)
      sourceLine = document.getElementById("source-line-" + line)
      sourceLineTop = sourceLine.offsetTop
      makeSourcePosVisible sourceLineTop
    return  if selectedSource is sourceLine
    if selectedSource?
      selectedSource.classList.remove "highlight-yellow"
      selectedSource.classList.add selectedSourceClass
    if sourceLine?
      selectedSourceClass = sourceLine.classList[0]
      sourceLine.classList.remove selectedSourceClass
      sourceLine.classList.add "highlight-yellow"
    selectedSource = sourceLine
    return
  makeContainerPosVisible = (container, newTop) ->
    height = container.offsetHeight
    margin = Math.floor(height / 4)
    if newTop < container.scrollTop + margin
      newTop -= margin
      newTop = 0  if newTop < 0
      container.scrollTop = newTop
      return
    if newTop > (container.scrollTop + 3 * margin)
      newTop = newTop - 3 * margin
      container.scrollTop = newTop
    return
  makeAsmPosVisible = (newTop) ->
    asmContainer = document.getElementById("asm-container")
    makeContainerPosVisible asmContainer, newTop
    return
  makeSourcePosVisible = (newTop) ->
    sourceContainer = document.getElementById("source-container")
    makeContainerPosVisible sourceContainer, newTop
    return
  addressClick = (element, event) ->
    event.stopPropagation()
    asmLineId = "address-" + element.innerText
    asmLineElement = document.getElementById(asmLineId)
    if asmLineElement?
      asmLineTop = asmLineElement.parentNode.offsetTop
      makeAsmPosVisible asmLineTop
      asmLineElement.classList.add "highlight-flash-blue"
      window.setTimeout (->
        asmLineElement.classList.remove "highlight-flash-blue"
        return
      ), 1500
    return
  prepareAsm = (originalSource) ->
    newSource = ""
    lineNumber = 1
    functionProcessLine = (text, begin, end) ->
      currentLine = text.substring(begin, end)
      matches = instructionFinder.exec(currentLine)
      clickHandler = ""
      if matches?
        restOfLine = matches[2]
        restOfLine = restOfLine.replace(addressReplacer, "<span class=\"hover-underline\" " + "onclick=\"Sodium.addressClick(this, event);\">$1</span>")
        currentLine = "<span id=\"address-" + matches[1] + "\" >" + matches[1] + "</span>" + restOfLine
        clickHandler = "onclick='Sodium.asmClick(this)' "
      else currentLine = "<br>"  if whiteSpaceLineFinder.exec(currentLine)
      newSource += "<pre style='margin-bottom: -12px;' " + clickHandler + ">" + currentLine + "</pre>"
      lineNumber++
      return

    processLines originalSource, originalSource.length, functionProcessLine
    newSource
  findSourcePosition = (pcToSearch) ->
    position = 0
    distance = 0x7fffffff
    pcToSearchOffset = parseInt(pcToSearch)
    processOneLine = (text, begin, end) ->
      currentLine = text.substring(begin, end)
      matches = positionFinder.exec(currentLine)
      if matches?
        pcOffset = parseInt(matches[1])
        if pcOffset <= pcToSearchOffset
          dist = pcToSearchOffset - pcOffset
          pos = parseInt(matches[2])
          if (dist < distance) or (dist is distance and pos > position)
            position = pos
            distance = dist
      return

    asmText = getCurrentAsmText()
    processLines asmText, asmText.length, processOneLine
    code = getCurrentCodeObject()
    return 0  if position is 0
    position - code.firstSourcePosition
  findSourceLine = (position) ->
    return 1  if position is 0
    line = 0
    processOneLine = (text, begin, end) ->
      line++  if begin < position
      return

    sourceText = getCurrentSourceText()
    processLines sourceText, sourceText.length, processOneLine
    line
  functionChangedHandler = ->
    functionSelect = document.getElementById("function-selector-id")
    source = getCurrentSourceText()
    sourceDivElement = document.getElementById("source-text")
    code = getCurrentCodeObject()
    newHtml = "<pre class=\"prettyprint linenums\" id=\"source-text\">" + "function " + code.name + source + "</pre>"
    sourceDivElement.innerHTML = newHtml
    try
      
      # Wrap in try to work when offline.
      PR.prettyPrint()
    sourceLineContainer = sourceDivElement.firstChild.firstChild
    lineCount = sourceLineContainer.childElementCount
    current = sourceLineContainer.firstChild
    i = 1

    while i < lineCount
      current.id = "source-line-" + i
      current = current.nextElementSibling
      ++i
    asm = getCurrentAsmText()
    document.getElementById("asm-text").innerHTML = prepareAsm(asm)
    return
  kindChangedHandler = (element) ->
    setKindByIndex element.selectedIndex
    processFileContent()
    functionChangedHandler()
    return
  readLog = (evt) ->
    
    #Retrieve the first (and only!) File from the FileList object
    f = evt.target.files[0]
    if f
      r = new FileReader()
      r.onload = (e) ->
        file = evt.target.files[0]
        currentFunctionKind = ""
        fileContent = e.target.result
        processFileContent()
        functionChangedHandler()
        return

      r.readAsText f
    else
      alert "Failed to load file"
    return
  buildFunctionKindSelector = (kindSelectElement) ->
    x = 0

    while x < kinds.length
      optionElement = document.createElement("option")
      optionElement.value = x
      optionElement.text = kinds[x]
      kindSelectElement.add optionElement, null
      ++x
    kindSelectElement.selectedIndex = 1
    setKindByIndex 1
    return
  "use strict"
  kinds = [
    "FUNCTION"
    "OPTIMIZED_FUNCTION"
    "STUB"
    "BUILTIN"
    "LOAD_IC"
    "KEYED_LOAD_IC"
    "CALL_IC"
    "KEYED_CALL_IC"
    "STORE_IC"
    "KEYED_STORE_IC"
    "BINARY_OP_IC"
    "COMPARE_IC"
    "COMPARE_NIL_IC"
    "TO_BOOLEAN_IC"
  ]
  kindsWithSource =
    FUNCTION: true
    OPTIMIZED_FUNCTION: true

  addressRegEx = "0x[0-9a-f]{8,16}"
  nameFinder = new RegExp("^name = (.+)$")
  kindFinder = new RegExp("^kind = (.+)$")
  firstPositionFinder = new RegExp("^source_position = (\\d+)$")
  separatorFilter = new RegExp("^--- (.)+ ---$")
  rawSourceFilter = new RegExp("^--- Raw source ---$")
  codeEndFinder = new RegExp("^--- End code ---$")
  whiteSpaceLineFinder = new RegExp("^\\W*$")
  instructionBeginFinder = new RegExp("^Instructions\\W+\\(size = \\d+\\)")
  instructionFinder = new RegExp("^(" + addressRegEx + ")(\\W+\\d+\\W+.+)")
  positionFinder = new RegExp("^(" + addressRegEx + ")\\W+position\\W+\\((\\d+)\\)")
  addressFinder = new RegExp("(" + addressRegEx + ")")
  addressReplacer = new RegExp("(" + addressRegEx + ")", "gi")
  fileContent = ""
  selectedFunctionKind = ""
  currentFunctionKind = ""
  currentFunctionName = ""
  firstSourcePosition = 0
  startAddress = ""
  readingSource = false
  readingAsm = false
  sourceBegin = -1
  sourceEnd = -1
  asmBegin = -1
  asmEnd = -1
  codeObjects = []
  selectedAsm = null
  selectedSource = null
  selectedSourceClass = ""
  buildFunctionKindSelector: buildFunctionKindSelector
  kindChangedHandler: kindChangedHandler
  functionChangedHandler: functionChangedHandler
  asmClick: asmClick
  addressClick: addressClick
  readLog: readLog
)()
