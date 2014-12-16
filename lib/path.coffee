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

# resolves . and .. elements in a path array with directory names there
# must be no slashes or device names (c:\) in the array
# (so also no leading and trailing slashes - it does not distinguish
# relative and absolute paths)
normalizeArray = (parts, allowAboveRoot) ->
  res = []
  i = 0

  while i < parts.length
    p = parts[i]
    
    # ignore empty parts
    continue  if not p or p is "."
    if p is ".."
      if res.length and res[res.length - 1] isnt ".."
        res.pop()
      else res.push ".."  if allowAboveRoot
    else
      res.push p
    i++
  res

# Regex to split a windows path into three parts: [*, device, slash,
# tail] windows-only

# Regex to split the tail part of the above into [*, dir, basename, ext]

# Function to split a filename into [root, dir, basename, ext]
win32SplitPath = (filename) ->
  
  # Separate device+slash from tail
  result = splitDeviceRe.exec(filename)
  device = (result[1] or "") + (result[2] or "")
  tail = result[3] or ""
  
  # Split the tail into dir, basename and extension
  result2 = splitTailRe.exec(tail)
  dir = result2[1]
  basename = result2[2]
  ext = result2[3]
  [
    device
    dir
    basename
    ext
  ]

# path.resolve([from ...], to)

# Windows has the concept of drive-specific current working
# directories. If we've resolved a drive letter but not yet an
# absolute path, get cwd for that drive. We're sure the device is not
# an unc path at this points, because unc paths are always absolute.

# Verify that a drive-local cwd was found and that it actually points
# to our drive. If not, default to the drive's root.

# Skip empty and invalid entries

# This path points to another device so it is not applicable

# Convert slashes to backslashes when `resolvedDevice` points to an UNC
# root. Also squash multiple slashes into a single one where appropriate.

# At this point the path should be resolved to a full absolute path,
# but handle relative paths to be safe (might happen when process.cwd()
# fails)

# Normalize the tail path

# Normalize the tail path

# Convert slashes to backslashes when `device` points to an UNC root.
# Also squash multiple slashes into a single one where appropriate.

# UNC paths are always absolute

# Make sure that the joined path doesn't start with two slashes, because
# normalize() will mistake it for an UNC path then.
#
# This step is skipped when it is very clear that the user actually
# intended to point at an UNC path. This is assumed when the first
# non-empty string arguments starts with exactly two slashes followed by
# at least one more non-slash character.
#
# Note that for normalize() to treat a path as an UNC path it needs to
# have at least 2 components, so we don't filter for that here.
# This means that the user can use join to construct UNC paths from
# a server name and a share name; for example:
#   path.join('//server', 'share') -> '\\\\server\\share\')

# path.relative(from, to)
# it will solve the relative path from 'from' to 'to', for instance:
# from = 'C:\\orandea\\test\\aaa'
# to = 'C:\\orandea\\impl\\bbb'
# The output of the function should be: '..\\..\\impl\\bbb'

# windows is not case sensitive

# Note: this will *probably* throw somewhere.

# path is local filesystem path, which needs to be converted
# to long UNC path.

# path is network UNC path, which needs to be converted
# to long UNC path.

# No dirname whatsoever

# It has a dirname, strip trailing slash

# TODO: make this comparison case-insensitive on windows?

# Split a filename into [root, dir, basename, ext], unix version
# 'root' is just a slash, or nothing.
posixSplitPath = (filename) ->
  splitPathRe.exec(filename).slice 1
"use strict"
isWindows = process.platform is "win32"
util = require("util")
splitDeviceRe = /^([a-zA-Z]:|[\\\/]{2}[^\\\/]+[\\\/]+[^\\\/]+)?([\\\/])?([\s\S]*?)$/
splitTailRe = /^([\s\S]*?)((?:\.{1,2}|[^\\\/]+?|)(\.[^.\/\\]*|))(?:[\\\/]*)$/
win32 = {}
normalizeUNCRoot = (device) ->
  "\\\\" + device.replace(/^[\\\/]+/, "").replace(/[\\\/]+/g, "\\")

win32.resolve = ->
  resolvedDevice = ""
  resolvedTail = ""
  resolvedAbsolute = false
  i = arguments.length - 1

  while i >= -1
    path = undefined
    if i >= 0
      path = arguments[i]
    else unless resolvedDevice
      path = process.cwd()
    else
      path = process.env["=" + resolvedDevice]
      path = resolvedDevice + "\\"  if not path or path.substr(0, 3).toLowerCase() isnt resolvedDevice.toLowerCase() + "\\"
    unless util.isString(path)
      throw new TypeError("Arguments to path.resolve must be strings")
    else continue  unless path
    result = splitDeviceRe.exec(path)
    device = result[1] or ""
    isUnc = device and device.charAt(1) isnt ":"
    isAbsolute = win32.isAbsolute(path)
    tail = result[3]
    continue  if device and resolvedDevice and device.toLowerCase() isnt resolvedDevice.toLowerCase()
    resolvedDevice = device  unless resolvedDevice
    unless resolvedAbsolute
      resolvedTail = tail + "\\" + resolvedTail
      resolvedAbsolute = isAbsolute
    break  if resolvedDevice and resolvedAbsolute
    i--
  resolvedDevice = normalizeUNCRoot(resolvedDevice)  if isUnc
  resolvedTail = normalizeArray(resolvedTail.split(/[\\\/]+/), not resolvedAbsolute).join("\\")
  (resolvedDevice + ((if resolvedAbsolute then "\\" else "")) + resolvedTail) or "."

win32.normalize = (path) ->
  result = splitDeviceRe.exec(path)
  device = result[1] or ""
  isUnc = device and device.charAt(1) isnt ":"
  isAbsolute = win32.isAbsolute(path)
  tail = result[3]
  trailingSlash = /[\\\/]$/.test(tail)
  tail = normalizeArray(tail.split(/[\\\/]+/), not isAbsolute).join("\\")
  tail = "."  if not tail and not isAbsolute
  tail += "\\"  if tail and trailingSlash
  device = normalizeUNCRoot(device)  if isUnc
  device + ((if isAbsolute then "\\" else "")) + tail

win32.isAbsolute = (path) ->
  result = splitDeviceRe.exec(path)
  device = result[1] or ""
  isUnc = !!device and device.charAt(1) isnt ":"
  !!result[2] or isUnc

win32.join = ->
  f = (p) ->
    throw new TypeError("Arguments to path.join must be strings")  unless util.isString(p)
    p
  paths = Array::filter.call(arguments, f)
  joined = paths.join("\\")
  joined = joined.replace(/^[\\\/]{2,}/, "\\")  unless /^[\\\/]{2}[^\\\/]/.test(paths[0])
  win32.normalize joined

win32.relative = (from, to) ->
  trim = (arr) ->
    start = 0
    while start < arr.length
      break  if arr[start] isnt ""
      start++
    end = arr.length - 1
    while end >= 0
      break  if arr[end] isnt ""
      end--
    return []  if start > end
    arr.slice start, end + 1
  from = win32.resolve(from)
  to = win32.resolve(to)
  lowerFrom = from.toLowerCase()
  lowerTo = to.toLowerCase()
  toParts = trim(to.split("\\"))
  lowerFromParts = trim(lowerFrom.split("\\"))
  lowerToParts = trim(lowerTo.split("\\"))
  length = Math.min(lowerFromParts.length, lowerToParts.length)
  samePartsLength = length
  i = 0

  while i < length
    if lowerFromParts[i] isnt lowerToParts[i]
      samePartsLength = i
      break
    i++
  return to  if samePartsLength is 0
  outputParts = []
  i = samePartsLength

  while i < lowerFromParts.length
    outputParts.push ".."
    i++
  outputParts = outputParts.concat(toParts.slice(samePartsLength))
  outputParts.join "\\"

win32._makeLong = (path) ->
  return path  unless util.isString(path)
  return ""  unless path
  resolvedPath = win32.resolve(path)
  if /^[a-zA-Z]\:\\/.test(resolvedPath)
    return "\\\\?\\" + resolvedPath
  else return "\\\\?\\UNC\\" + resolvedPath.substring(2)  if /^\\\\[^?.]/.test(resolvedPath)
  path

win32.dirname = (path) ->
  result = win32SplitPath(path)
  root = result[0]
  dir = result[1]
  return "."  if not root and not dir
  dir = dir.substr(0, dir.length - 1)  if dir
  root + dir

win32.basename = (path, ext) ->
  f = win32SplitPath(path)[2]
  f = f.substr(0, f.length - ext.length)  if ext and f.substr(-1 * ext.length) is ext
  f

win32.extname = (path) ->
  win32SplitPath(path)[3]

win32.format = (pathObject) ->
  throw new TypeError("Parameter 'pathObject' must be an object, not " + typeof pathObject)  unless util.isObject(pathObject)
  root = pathObject.root or ""
  throw new TypeError("'pathObject.root' must be a string or undefined, not " + typeof pathObject.root)  unless util.isString(root)
  dir = pathObject.dir
  base = pathObject.base or ""
  return dir + base  if dir.slice(dir.length - 1, dir.length) is win32.sep
  return dir + win32.sep + base  if dir
  base

win32.parse = (pathString) ->
  throw new TypeError("Parameter 'pathString' must be a string, not " + typeof pathString)  unless util.isString(pathString)
  allParts = win32SplitPath(pathString)
  throw new TypeError("Invalid path '" + pathString + "'")  if not allParts or allParts.length isnt 4
  root: allParts[0]
  dir: allParts[0] + allParts[1].slice(0, allParts[1].length - 1)
  base: allParts[2]
  ext: allParts[3]
  name: allParts[2].slice(0, allParts[2].length - allParts[3].length)

win32.sep = "\\"
win32.delimiter = ";"
splitPathRe = /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/
posix = {}

# path.resolve([from ...], to)
# posix version
posix.resolve = ->
  resolvedPath = ""
  resolvedAbsolute = false
  i = arguments.length - 1

  while i >= -1 and not resolvedAbsolute
    path = (if (i >= 0) then arguments[i] else process.cwd())
    
    # Skip empty and invalid entries
    unless util.isString(path)
      throw new TypeError("Arguments to path.resolve must be strings")
    else continue  unless path
    resolvedPath = path + "/" + resolvedPath
    resolvedAbsolute = path.charAt(0) is "/"
    i--
  
  # At this point the path should be resolved to a full absolute path, but
  # handle relative paths to be safe (might happen when process.cwd() fails)
  
  # Normalize the path
  resolvedPath = normalizeArray(resolvedPath.split("/"), not resolvedAbsolute).join("/")
  (((if resolvedAbsolute then "/" else "")) + resolvedPath) or "."


# path.normalize(path)
# posix version
posix.normalize = (path) ->
  isAbsolute = posix.isAbsolute(path)
  trailingSlash = path.substr(-1) is "/"
  
  # Normalize the path
  path = normalizeArray(path.split("/"), not isAbsolute).join("/")
  path = "."  if not path and not isAbsolute
  path += "/"  if path and trailingSlash
  ((if isAbsolute then "/" else "")) + path


# posix version
posix.isAbsolute = (path) ->
  path.charAt(0) is "/"


# posix version
posix.join = ->
  path = ""
  i = 0

  while i < arguments.length
    segment = arguments[i]
    throw new TypeError("Arguments to path.join must be strings")  unless util.isString(segment)
    if segment
      unless path
        path += segment
      else
        path += "/" + segment
    i++
  posix.normalize path


# path.relative(from, to)
# posix version
posix.relative = (from, to) ->
  trim = (arr) ->
    start = 0
    while start < arr.length
      break  if arr[start] isnt ""
      start++
    end = arr.length - 1
    while end >= 0
      break  if arr[end] isnt ""
      end--
    return []  if start > end
    arr.slice start, end + 1
  from = posix.resolve(from).substr(1)
  to = posix.resolve(to).substr(1)
  fromParts = trim(from.split("/"))
  toParts = trim(to.split("/"))
  length = Math.min(fromParts.length, toParts.length)
  samePartsLength = length
  i = 0

  while i < length
    if fromParts[i] isnt toParts[i]
      samePartsLength = i
      break
    i++
  outputParts = []
  i = samePartsLength

  while i < fromParts.length
    outputParts.push ".."
    i++
  outputParts = outputParts.concat(toParts.slice(samePartsLength))
  outputParts.join "/"

posix._makeLong = (path) ->
  path

posix.dirname = (path) ->
  result = posixSplitPath(path)
  root = result[0]
  dir = result[1]
  
  # No dirname whatsoever
  return "."  if not root and not dir
  
  # It has a dirname, strip trailing slash
  dir = dir.substr(0, dir.length - 1)  if dir
  root + dir

posix.basename = (path, ext) ->
  f = posixSplitPath(path)[2]
  
  # TODO: make this comparison case-insensitive on windows?
  f = f.substr(0, f.length - ext.length)  if ext and f.substr(-1 * ext.length) is ext
  f

posix.extname = (path) ->
  posixSplitPath(path)[3]

posix.format = (pathObject) ->
  throw new TypeError("Parameter 'pathObject' must be an object, not " + typeof pathObject)  unless util.isObject(pathObject)
  root = pathObject.root or ""
  throw new TypeError("'pathObject.root' must be a string or undefined, not " + typeof pathObject.root)  unless util.isString(root)
  dir = (if pathObject.dir then pathObject.dir + posix.sep else "")
  base = pathObject.base or ""
  dir + base

posix.parse = (pathString) ->
  throw new TypeError("Parameter 'pathString' must be a string, not " + typeof pathString)  unless util.isString(pathString)
  allParts = posixSplitPath(pathString)
  throw new TypeError("Invalid path '" + pathString + "'")  if not allParts or allParts.length isnt 4
  allParts[1] = allParts[1] or ""
  allParts[2] = allParts[2] or ""
  allParts[3] = allParts[3] or ""
  root: allParts[0]
  dir: allParts[0] + allParts[1].slice(0, allParts[1].length - 1)
  base: allParts[2]
  ext: allParts[3]
  name: allParts[2].slice(0, allParts[2].length - allParts[3].length)

posix.sep = "/"
posix.delimiter = ":"
if isWindows
  module.exports = win32
# posix 
else
  module.exports = posix
module.exports.posix = posix
module.exports.win32 = win32
