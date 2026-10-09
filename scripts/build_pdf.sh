#!/usr/bin/env bash
# Build the guide as a PDF from the canonical Markdown. Does not modify the sources.
# Usage: scripts/build_pdf.sh <version> [revisions.md]
set -euo pipefail

version="${1:?usage: build_pdf.sh <version> [revisions.md]}"
revisions="${2:-}"
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/build"
mkdir -p "$out"
cd "$root"

combined="$out/ai-security-101.md"
{
  # README introduction: everything before the Contents list, minus the title.
  awk '/^## Contents/{exit} NR>1' README.md | sed '/./,$!d'
} > "$out/intro.md"

{
  echo "# Introduction"
  echo
  cat "$out/intro.md"
  # Chapters in filename order (NN_name.md).
  for f in [0-9][0-9]_*.md; do
    echo
    cat "$f"
  done
  # README Core Takeaways, promoted to a top-level section.
  echo
  echo "# Core Takeaways"
  echo
  awk '/^## Core Takeaways/{found=1; next} found' README.md | sed '/./,$!d'
  if [ -n "$revisions" ] && [ -s "$revisions" ]; then
    echo
    echo "# Revisions"
    echo
    cat "$revisions"
  fi
} > "$combined"

# Mermaid diagrams are rendered by scripts/mermaid.lua. MMDC and MERMAID_CHROME can override the defaults.
export MERMAID_OUT_DIR="$out/diagrams"

pandoc "$combined" \
  --from markdown-smart-tex_math_dollars-raw_tex-yaml_metadata_block-blank_before_header+autolink_bare_uris+pipe_tables \
  --pdf-engine=xelatex \
  --lua-filter="$root/scripts/mermaid.lua" \
  --toc --toc-depth=2 \
  --metadata title="AI Security 101" \
  --metadata subtitle="Version $version" \
  -V documentclass=report \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue \
  -o "$out/ai-security-101-$version.pdf"

echo "$out/ai-security-101-$version.pdf"
