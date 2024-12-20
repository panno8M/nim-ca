import std/[strutils, httpclient, xmlparser, xmltree]

var client = newHttpClient()

var content = client.getContent("https://www.colordic.org")
  .replace("<br>", "")

let tableBegin = content.find("<table class=\"colortable\">")
content = content[tableBegin .. content.find("</table>", tableBegin)+7]

let table = content.parseXml()

var names, codes: seq[string]
var longestName: string

for tr in table:
  if tr.kind != xnElement: continue
  for td in tr:
    for elem in td[0]:
      let s = ($elem).replace("\t", "").splitLines
      let (name, code) = (s[0].capitalizeAscii, s[1])
      names.add name
      codes.add code
      if name.len > longestName.len:
        longestname = name

proc rightAlign(s, other: string): string =
  " ".repeat(other.len - s.len) & s


for i in 0..names.high:
  echo "const ", names[i].rightAlign(longestname), "*: Color = hex\"", codes[i], "\""