#!/usr/bin/env bash
# Decide how the release summary is produced and write the step outputs.
# Usage: scripts/prepare_summary_input.sh <previous-ref>
# Outputs (to $GITHUB_OUTPUT): summary_mode, and either summary (deterministic) or guide_diff (semantic).
set -euo pipefail

diff_file=build/guide-content.diff
mkdir -p build
summary="$(scripts/summarize_diff.sh "${1:-}" "$diff_file")"

if [ "$summary" = "SEMANTIC_SUMMARY_REQUIRED" ]; then
  delimiter="ghaw_$(cat /proc/sys/kernel/random/uuid)"
  while grep -Fqx "$delimiter" "$diff_file"; do
    delimiter="ghaw_$(cat /proc/sys/kernel/random/uuid)"
  done
  {
    echo "guide_diff<<$delimiter"
    cat "$diff_file"
    echo "$delimiter"
    echo "summary_mode=semantic"
  } >> "$GITHUB_OUTPUT"
else
  test -n "$summary"
  {
    echo "summary_mode=deterministic"
    echo "summary=$summary"
  } >> "$GITHUB_OUTPUT"
fi
