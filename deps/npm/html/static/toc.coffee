(->
  wrapper = document.getElementById("wrapper")
  els = Array::slice.call(wrapper.getElementsByTagName("*"), 0).filter((el) ->
    el.parentNode is wrapper and el.tagName.match(/H[1-6]/) and el.id
  )
  l = 2
  toc = document.createElement("ul")
  toc.innerHTML = els.map((el) ->
    i = el.tagName.charAt(1)
    out = ""
    while i > l
      out += "<ul>"
      l++
    while i < l
      out += "</ul>"
      l--
    out += "<li><a href='#" + el.id + "'>" + (el.innerText or el.text or el.innerHTML) + "</a>"
    out
  ).join("\n")
  toc.id = "toc"
  document.body.appendChild toc
  return
)()
