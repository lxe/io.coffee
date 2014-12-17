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
common = require("../common")
assert = require("assert")
module = require("module")
isWindows = process.platform is "win32"
partA = undefined
partB = undefined
if isWindows
  partA = "C:\\Users\\Rocko Artischocko\\AppData\\Roaming\\npm"
  partB = "C:\\Program Files (x86)\\nodejs\\"
  process.env["NODE_PATH"] = partA + ";" + partB
else
  partA = "/usr/test/lib/node_modules"
  partB = "/usr/test/lib/node"
  process.env["NODE_PATH"] = partA + ":" + partB
module._initPaths()
assert.ok module.globalPaths.indexOf(partA) isnt -1
assert.ok module.globalPaths.indexOf(partB) isnt -1
assert.ok Array.isArray(module.globalPaths)
