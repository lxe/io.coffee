a = (x) ->
  i = 10
    until --i is 0
  debugger
  i
b = ->
  [
    "hello"
    "world"
  ].join " "
debugger
a()
a 1
b()
b()
setInterval (->
), 5000
now = new Date()
debugger
