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
repl = require("./helper-debugger-repl.js")
repl.startDebugger "breakpoints.js"
addTest = repl.addTest

# Next
addTest "n", [
  /break in .*:11/
  /9/
  /10/
  /11/
  /12/
  /13/
]

# Watch
addTest "watch(\"'x'\")"

# Continue
addTest "c", [
  /break in .*:5/
  /Watchers/
  /0:\s+'x' = "x"/
  /()/
  /3/
  /4/
  /5/
  /6/
  /7/
]

# Show watchers
addTest "watchers", [/0:\s+'x' = "x"/]

# Unwatch
addTest "unwatch(\"'x'\")"

# Step out
addTest "o", [
  /break in .*:12/
  /10/
  /11/
  /12/
  /13/
  /14/
]

# Continue
addTest "c", [
  /break in .*:5/
  /3/
  /4/
  /5/
  /6/
  /7/
]

# Set breakpoint by function name
addTest "sb(\"setInterval()\", \"!(setInterval.flag++)\")", [
  /1/
  /2/
  /3/
  /4/
  /5/
  /6/
  /7/
  /8/
  /9/
  /10/
]

# Continue
addTest "c", [
  /break in node.js:\d+/
  /\d/
  /\d/
  /\d/
  /\d/
  /\d/
]

# REPL and process.env regression
addTest "repl", [/Ctrl/]
addTest "for (var i in process.env) delete process.env[i]", []
addTest "process.env", [/\{\}/]
