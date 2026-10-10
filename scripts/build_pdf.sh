#!/usr/bin/env bash
# Build the guide as a PDF from the canonical Markdown. Does not modify the sources.
# Usage: scripts/build_pdf.sh <version> [revisions.md] [preview]
set -euo pipefail

version="${1:?usage: build_pdf.sh <version> [revisions.md]}"
revisions="${2:-}"
preview="${3:-}"
if [ -n "$preview" ] && [ "$preview" != "preview" ]; then
  echo "Unknown build mode: $preview" >&2
  exit 2
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/build"
mkdir -p "$out"
cd "$root"

title="AI Security 101"
suffix=""
if [ "$preview" = "preview" ]; then
  title+=" - PREVIEW"
  suffix="-PREVIEW"
fi

combined="$out/ai-security-101.md"
{
  # Guide sources in filename order (NN_name.md).
  for f in [0-9][0-9]_*.md; do
    echo
    cat "$f"
  done
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
  --metadata title="$title" \
  --metadata subtitle="Version $version" \
  -V documentclass=report \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue \
  -o "$out/ai-security-101-$version$suffix.pdf"

echo "$out/ai-security-101-$version$suffix.pdf"
