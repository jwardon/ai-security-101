#!/usr/bin/env node
const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

const root = path.resolve(__dirname, "..");
const guide = path.join(root, "guide");
const output = path.join(root, "build", "diagrams");
const mermaidCli = "/home/mermaidcli/node_modules/.bin/mmdc";
const config = {
  theme: "neutral",
  themeVariables: { fontSize: "13px" },
  flowchart: {
    nodeSpacing: 25,
    rankSpacing: 30,
    padding: 8,
    htmlLabels: true,
    useMaxWidth: false,
    subGraphTitleMargin: { top: 12, bottom: 24 },
  },
  sequence: {
    mirrorActors: false,
    useMaxWidth: false,
    actorMargin: 30,
    width: 100,
    messageFontSize: 13,
    noteFontSize: 13,
  },
};

function mermaidBlocks(markdown) {
  const lines = markdown.split(/\r?\n/);
  const blocks = [];

  for (let i = 0; i < lines.length; i += 1) {
    const opening = /^( {0,3})(`{3,}|~{3,})(.*)$/.exec(lines[i]);
    if (!opening) continue;

    const indent = opening[1].length;
    const fence = opening[2];
    const info = opening[3].trim();
    const isMermaid = info.split(/\s+/, 1)[0] === "mermaid" || /^\{[^}]*\.mermaid(?:\s|})/.test(info);
    const content = [];
    const closing = new RegExp(`^ {0,3}${fence[0]}{${fence.length},}\\s*$`);
    let j = i + 1;
    for (; j < lines.length && !closing.test(lines[j]); j += 1) {
      content.push(lines[j].replace(new RegExp(`^ {0,${indent}}`), ""));
    }
    if (j === lines.length) {
      if (isMermaid) throw new Error("Unclosed Mermaid code fence");
      break;
    }
    i = j;
    if (!isMermaid) continue;

    const text = content.join("\n");
    const hash = crypto.createHash("sha1").update(text).digest("hex");
    blocks.push({ hash, text });
  }

  return blocks;
}

fs.rmSync(output, { recursive: true, force: true });
fs.mkdirSync(output, { recursive: true });
fs.writeFileSync(path.join(output, "mermaid.config.json"), `${JSON.stringify(config, null, 2)}\n`);

const files = fs.readdirSync(guide)
  .filter((file) => /^[0-9]{2}_.*\.md$/.test(file))
  .sort();
let count = 0;
for (const file of files) {
  const markdown = fs.readFileSync(path.join(guide, file), "utf8");
  for (const { hash, text } of mermaidBlocks(markdown)) {
    const input = path.join(output, `${hash}.mmd`);
    const image = path.join(output, `${hash}.png`);
    if (fs.existsSync(image)) continue;
    fs.writeFileSync(input, text);
    execFileSync(mermaidCli, [
      "-q",
      "-i", input,
      "-o", image,
      "-p", "/puppeteer-config.json",
      "-c", path.join(output, "mermaid.config.json"),
      "-b", "white",
      "-s", "3",
    ], { stdio: "inherit" });
    count += 1;
  }
}

if (count === 0) throw new Error("No Mermaid diagrams were found");
console.log(`Rendered ${count} unique Mermaid diagrams`);
