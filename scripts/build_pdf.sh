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

pandoc_image="docker.io/pandoc/latex:3.8.3@sha256:dd0dd153f681ec264094c04011e34459e8de61fe95712020ab4dfbff1117b015"
mermaid_image="docker.io/minlag/mermaid-cli:11.12.0@sha256:bad64c9d9ad917c8dfbe9d9e9c162b96f6615ff019b37058638d16eb27ce7783"
container_user="$(id -u):$(id -g)"

title="AI Security 101"
suffix=""
if [ "$preview" = "preview" ]; then
  title+=" - PREVIEW"
  suffix="-PREVIEW"
fi

combined="$out/ai-security-101.md"
{
  # Guide sources in filename order (guide/NN_name.md).
  for f in guide/[0-9][0-9]_*.md; do
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

rm -rf "$out/diagrams"
mkdir -p "$out/diagrams"

docker run --rm \
  --user "$container_user" \
  --volume "$root:/data" \
  --workdir /data \
  --env MERMAID_EXTRACT=true \
  --env MERMAID_OUT_DIR=build/diagrams \
  "$pandoc_image" \
  build/ai-security-101.md \
  --from markdown-smart-tex_math_dollars-raw_tex-yaml_metadata_block-blank_before_header+autolink_bare_uris+pipe_tables \
  --lua-filter=scripts/mermaid.lua \
  --to=native \
  --output=/dev/null

shopt -s nullglob
diagrams=("$out"/diagrams/*.mmd)
if ((${#diagrams[@]})); then
  docker run --rm \
    --user "$container_user" \
    --env HOME=/tmp \
    --volume "$out/diagrams:/data" \
    --workdir /data \
    --entrypoint /bin/sh \
    "$mermaid_image" \
    -eu -c '
      for input in *.mmd; do
        /home/mermaidcli/node_modules/.bin/mmdc -q -i "$input" -o "${input%.mmd}.png" \
          -p /puppeteer-config.json -c mermaid.config.json -b white -s 3
      done
    '
fi

docker run --rm \
  --user "$container_user" \
  --volume "$root:/data" \
  --workdir /data \
  --env MERMAID_OUT_DIR=build/diagrams \
  "$pandoc_image" \
  build/ai-security-101.md \
  --from markdown-smart-tex_math_dollars-raw_tex-yaml_metadata_block-blank_before_header+autolink_bare_uris+pipe_tables \
  --pdf-engine=xelatex \
  --lua-filter=scripts/mermaid.lua \
  --toc --toc-depth=2 \
  --metadata title="$title" \
  --metadata subtitle="Version $version" \
  -V documentclass=report \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue \
  -o "build/ai-security-101-$version$suffix.pdf"

echo "$out/ai-security-101-$version$suffix.pdf"
