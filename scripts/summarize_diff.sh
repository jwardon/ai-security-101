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

legacy_readme_migration=false
if ! git cat-file -e "$prev:guide/00_introduction.md" 2>/dev/null &&
  git cat-file -e "$prev:README.md" 2>/dev/null &&
  git ls-tree -r --name-only "$prev" | grep -Eq '^[0-9][0-9]_[^/]+\.md$' &&
  diff -q \
    <(git show "$prev:README.md" | awk '/^## Contents/{exit} NR>1' | sed '/./,$!d') \
    <(awk '/^## Contents/{exit} NR>1' guide/00_introduction.md | sed '/./,$!d') >/dev/null &&
  diff -q \
    <(git show "$prev:README.md" | awk '/^## Contents/{found=1; next} /^## Core Takeaways/{found=0} found' | sed -E 's/\]\([^)]*\)/]/' | awk 'NF') \
    <(awk '/^## Contents/{found=1; next} found' guide/00_introduction.md | sed -E 's/\]\([^)]*\)/]/' | awk 'NF') >/dev/null &&
  diff -q \
    <(git show "$prev:README.md" | awk '/^## Core Takeaways/{found=1; next} found' | sed '/./,$!d') \
    <(awk '/^# Core Takeaways/{found=1; next} found' guide/12_core_takeaways.md | sed '/./,$!d') >/dev/null; then
  legacy_readme_migration=true
fi

if [ "$legacy_readme_migration" = true ]; then
  if ! git diff --numstat --find-renames "$prev" HEAD -- \
    ':(glob)[0-9][0-9]_*.md' \
    ':(glob)guide/[0-9][0-9]_*.md' \
    ':(exclude)guide/00_introduction.md' \
    ':(exclude)guide/12_core_takeaways.md' |
    awk -F '\t' '$1 != "0" || $2 != "0" { changed=1 } END { exit !changed }'; then
    echo "Moved the existing guide introduction, contents, takeaways, and chapters into guide/; no substantive guide content changed."
    exit 0
  fi

  {
    git diff --no-color --find-renames "$prev" HEAD -- \
      ':(glob)[0-9][0-9]_*.md' \
      ':(glob)guide/[0-9][0-9]_*.md' \
      ':(exclude)guide/00_introduction.md' \
      ':(exclude)guide/12_core_takeaways.md'
    echo
    echo "Verified structural migration: the existing introduction, contents, and Core Takeaways moved from the legacy README into guide/00_introduction.md and guide/12_core_takeaways.md; the contents links were updated for the new paths."
  } > "$diff_output"
else
  git diff --no-color --find-renames "$prev" HEAD -- \
    ':(glob)[0-9][0-9]_*.md' \
    ':(glob)guide/[0-9][0-9]_*.md' > "$diff_output"
fi

diff_size="$(wc -c < "$diff_output")"
if [ "$diff_size" -gt "$max_diff_bytes" ]; then
  echo "Guide-content diff exceeds the ${max_diff_bytes}-byte semantic summary limit." >&2
  exit 1
fi

echo "SEMANTIC_SUMMARY_REQUIRED"
