-- Pandoc Lua filter: replace Mermaid blocks with images from the rendering job.
local out_dir = os.getenv("MERMAID_OUT_DIR") or "build/diagrams"

function CodeBlock(block)
  if not block.classes:includes("mermaid") then
    return nil
  end
  os.execute("mkdir -p '" .. out_dir .. "'")
  local name = out_dir .. "/" .. pandoc.sha1(block.text)
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
