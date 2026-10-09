-- Pandoc Lua filter: render ```mermaid code blocks to PNG images with mermaid-cli (mmdc).
-- MMDC overrides the mmdc command; MERMAID_CHROME points at a Chrome/Chromium binary.
local out_dir = os.getenv("MERMAID_OUT_DIR") or "build/diagrams"
local mmdc = os.getenv("MMDC") or "mmdc"
local chrome = os.getenv("MERMAID_CHROME")

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
  write(name .. ".mmd", block.text)
  local puppeteer = name .. ".puppeteer.json"
  local launch = '{"args": ["--no-sandbox", "--disable-setuid-sandbox"]'
  if chrome and chrome ~= "" then
    launch = launch .. ', "executablePath": "' .. chrome .. '"'
  end
  write(puppeteer, launch .. "}")
  local config = name .. ".config.json"
  write(config, '{"flowchart": {"nodeSpacing": 20, "rankSpacing": 30, "padding": 8, "htmlLabels": true}}')
  local cmd = string.format("%s -q -i '%s.mmd' -o '%s.png' -p '%s' -c '%s' -b white -s 3",
    mmdc, name, name, puppeteer, config)
  local ok = os.execute(cmd)
  if not ok then
    io.stderr:write("mermaid.lua: failed to render diagram:\n" .. block.text .. "\n")
    os.exit(1)
  end
  return pandoc.Para({ pandoc.Image({}, name .. ".png") })
end
