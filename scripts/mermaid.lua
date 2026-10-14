-- Pandoc Lua filter: extract Mermaid blocks for container rendering or embed rendered PNGs.
local out_dir = os.getenv("MERMAID_OUT_DIR") or "build/diagrams"
local extract = os.getenv("MERMAID_EXTRACT") == "true"

local function write(path, text)
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

function CodeBlock(block)
  if not block.classes:includes("mermaid") then
    return nil
  end
  os.execute("mkdir -p '" .. out_dir .. "'")
  local name = out_dir .. "/" .. pandoc.sha1(block.text)
  if extract then
    write(name .. ".mmd", block.text)
    write(out_dir .. "/mermaid.config.json", [[{
  "theme": "neutral",
  "themeVariables": {"fontSize": "13px"},
  "flowchart": {"nodeSpacing": 25, "rankSpacing": 30, "padding": 8, "htmlLabels": true, "useMaxWidth": false,
                "subGraphTitleMargin": {"top": 12, "bottom": 24}},
  "sequence": {"mirrorActors": false, "useMaxWidth": false, "actorMargin": 30, "width": 100, "messageFontSize": 13, "noteFontSize": 13}
}]])
    return {}
  end

  local f = assert(io.open(name .. ".png", "rb"))
  local header = f:read(24)
  f:close()
  local px = string.unpack(">I4", header, 17)
  local scale = 3
  local width = string.format("%.3fin", math.min(px / scale / 96, 6.5))
  return {
    pandoc.RawBlock("latex", "\\begin{center}"),
    pandoc.Para({ pandoc.Image({}, name .. ".png", "", pandoc.Attr("", {}, { width = width })) }),
    pandoc.RawBlock("latex", "\\end{center}"),
  }
end
