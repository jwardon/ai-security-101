#!/usr/bin/env bash
# Prepare the content diff or a deterministic summary since the previous release.
# Usage: scripts/summarize_diff.sh <previous-ref> <content-diff-output>
set -euo pipefail

prev="${1:-}"
diff_output="${2:-}"
max_diff_bytes=60000

if [ -z "$prev" ]; then
  echo "Initial release."
  exit 0
fi

if git diff --quiet "$prev" HEAD; then
  echo "No changes since the previous release."
  exit 0
fi

changed_files="$(git diff --name-only "$prev" HEAD)"
if ! grep -Eq '^guide/[0-9][0-9]_[^/]+\.md$' <<<"$changed_files"; then
  echo "Build and release automation updated."
  exit 0
fi

if [ -z "$diff_output" ]; then
  echo "A content diff output path is required for semantic summaries." >&2
  exit 1
fi

git diff --no-color --find-renames "$prev" HEAD -- \
  ':(glob)[0-9][0-9]_*.md' \
  ':(glob)guide/[0-9][0-9]_*.md' > "$diff_output"
diff_size="$(wc -c < "$diff_output")"
if [ "$diff_size" -gt "$max_diff_bytes" ]; then
  echo "Guide-content diff exceeds the ${max_diff_bytes}-byte semantic summary limit." >&2
  exit 1
fi

echo "SEMANTIC_SUMMARY_REQUIRED"
