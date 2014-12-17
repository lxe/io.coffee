require("child_process").exec "dir-bin",
  stdio: "pipe"
  env: process.env
, (err) ->
  throw new Error("exited badly with code = " + err.code)  if err and err.code
  return

