envs = []
for e of process.env
  envs.push e + "=" + process.env[e]  if e.match(/npm|^path$/i)
envs.sort((a, b) ->
  (if a is b then 0 else (if a > b then -1 else 1))
).forEach (e) ->
  console.log e
  return

