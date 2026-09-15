-- shields-badges.lua — pandoc Lua filter: shields.io <img> badges in raw HTML become
-- \badge{label}{message}{HEX} (tex/publisher-badges.sty), keeping a wrapping <a href> as \href.
-- Shields path grammar: badge/<label>-<message>-<color> or badge/<message>-<color>;
-- `--` is a literal dash, `__` a literal underscore, `_` a space, then percent-decoding.
-- Only active when writing LaTeX; a no-op for every other output format.
if FORMAT ~= "latex" then
  return {}
end

local NAMED = {
  brightgreen = "44CC11", green = "97CA00", yellowgreen = "A4A61D", yellow = "DFB317", orange = "FE7D37",
  red = "E05D44", blue = "007EC6", lightgrey = "9F9F9F", lightgray = "9F9F9F", grey = "555555", gray = "555555",
  success = "44CC11", important = "FE7D37", critical = "E05D44", informational = "007EC6", inactive = "9F9F9F",
}

local function urldecode(s)
  return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local TEX_SPECIAL = {
  ["\\"] = "\\textbackslash{}", ["{"] = "\\{", ["}"] = "\\}", ["&"] = "\\&", ["%"] = "\\%",
  ["$"] = "\\$", ["#"] = "\\#", ["_"] = "\\_", ["^"] = "\\^{}", ["~"] = "\\~{}",
}
local function tex_escape(s)
  return (s:gsub("[\\{}&%%$#_^~]", TEX_SPECIAL))
end

local function decode_text(s)
  s = s:gsub("__", "\1"):gsub("_", " "):gsub("\1", "_")
  return urldecode(s)
end

-- split on single dashes; a doubled dash is a literal dash
local function split_dashes(path)
  local parts, buf, i = {}, "", 1
  while i <= #path do
    local c = path:sub(i, i)
    if c == "-" then
      if path:sub(i + 1, i + 1) == "-" then
        buf, i = buf .. "-", i + 2
      else
        parts[#parts + 1], buf, i = buf, "", i + 1
      end
    else
      buf, i = buf .. c, i + 1
    end
  end
  parts[#parts + 1] = buf
  return parts
end

local function color_hex(c)
  c = urldecode(c):lower()
  if c:match("^%x%x%x%x%x%x$") then return c:upper() end
  if c:match("^%x%x%x$") then return (c:gsub(".", "%0%0")):upper() end
  return NAMED[c] or "9F9F9F"
end

local function badge_from_src(src)
  local path = src:match("^https?://img%.shields%.io/badge/([^?]+)")
  if not path then return nil end
  local parts = split_dashes(path)
  if #parts < 2 then return nil end
  local color = table.remove(parts)
  local message = decode_text(table.remove(parts))
  local label = #parts > 0 and decode_text(table.concat(parts, "-")) or ""
  return string.format("\\badge{%s}{%s}{%s}", tex_escape(label), tex_escape(message), color_hex(color))
end

-- Scan one HTML string: every shields <img> becomes a raw LaTeX inline, wrapped in \href when
-- an <a href> was opened right before it and not yet closed. Other images are dropped (warned).
local function scan(html)
  local inlines, found, pos = {}, false, 1
  while true do
    local s, e, attrs = html:find("<img(.-)/?>", pos)
    if not s then break end
    local src = attrs:match('src="([^"]*)"') or attrs:match("src='([^']*)'")
    local tex = src and badge_from_src(src)
    if tex then
      local href = html:sub(pos, s - 1):match('.*<a%s[^>]-href="([^"]*)"[^>]*>%s*$')
      if href then tex = string.format("\\href{%s}{%s}", href, tex) end
      if #inlines > 0 then inlines[#inlines + 1] = pandoc.Space() end
      inlines[#inlines + 1] = pandoc.RawInline("latex", tex)
      found = true
    elseif src then
      io.stderr:write("shields-badges: dropping non-shields image " .. src .. "\n")
    end
    pos = e + 1
  end
  return inlines, found
end

local function is_html_raw(el)
  return el.t == "RawInline" and el.format == "html"
end

local function is_badge(el)
  return el.t == "RawInline" and el.format == "latex"
    and (el.text:match("^\\badge") or el.text:match("^\\href{[^}]*}{\\badge")) ~= nil
end

-- Runs after Inlines (typewise traversal). A block made only of badges — a <p> badge group
-- becomes RawBlock "<p>", Plain [badges…], RawBlock "</p>", since pandoc parses the inside of
-- <p> as markdown — is set ragged-right so a wrapping row keeps its natural spacing instead
-- of being justified across the line.
local function badge_block(el)
  local badges = 0
  for _, x in ipairs(el.content) do
    if is_badge(x) then
      badges = badges + 1
    elseif x.t ~= "Space" and x.t ~= "SoftBreak" then
      return nil
    end
  end
  if badges == 0 then return nil end
  local content = el.content:clone()
  content:insert(1, pandoc.RawInline("latex", "{\\raggedright "))
  content:insert(pandoc.RawInline("latex", "\\par}"))
  return pandoc.Para(content)
end

return {
  {
    RawBlock = function(el)
      if el.format ~= "html" then return nil end
      local inlines, found = scan(el.text)
      if found then return pandoc.Para(inlines) end
    end,
    Inlines = function(inlines)
      local out, i = {}, 1
      while i <= #inlines do
        if is_html_raw(inlines[i]) then
          local j, html = i, ""
          while j <= #inlines and (is_html_raw(inlines[j]) or inlines[j].t == "Space" or inlines[j].t == "SoftBreak") do
            html = html .. (is_html_raw(inlines[j]) and inlines[j].text or " ")
            j = j + 1
          end
          local badges, found = scan(html)
          if found then
            for _, x in ipairs(badges) do out[#out + 1] = x end
          else
            for k = i, j - 1 do out[#out + 1] = inlines[k] end
          end
          i = j
        else
          out[#out + 1] = inlines[i]
          i = i + 1
        end
      end
      return out
    end,
    Plain = badge_block,
    Para = badge_block,
  },
}
