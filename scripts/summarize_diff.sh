#!/usr/bin/env bash
# Print a one-line summary of the diff between a previous release and HEAD.
# Usage: scripts/summarize_diff.sh <previous-ref>
# Summaries are deterministic so release builds do not depend on an external model.
set -euo pipefail

prev="${1:-}"

if [ -z "$prev" ]; then
  echo "Initial release."
  exit 0
fi

if git diff --quiet "$prev" HEAD; then
  echo "No changes since the previous release."
  exit 0
fi

changed_files="$(git diff --name-only "$prev" HEAD)"
if ! grep -Eq '^(README\.md|[0-9][0-9]_[^/]+\.md)$' <<<"$changed_files"; then
  echo "Build and release automation updated."
  exit 0
fi

echo "AI security guide content updated."
