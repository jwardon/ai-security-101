#!/usr/bin/env bash
# Validate an untrusted semantic release summary before it enters release metadata.
# Usage: scripts/validate_release_summary.sh <summary-file>
set -euo pipefail

summary_file="${1:?usage: scripts/validate_release_summary.sh <summary-file>}"
summary="$(cat "$summary_file")"

if [ -z "${summary//[$' \t\r\n']/}" ]; then
  echo "Semantic summary is empty." >&2
  exit 1
fi

if [[ "$summary" == *$'\n'* || "$summary" == *$'\r'* ]]; then
  echo "Semantic summary must be a single line." >&2
  exit 1
fi

if [[ ! "$summary" =~ [.!?]$ ]] || [[ "$summary" =~ [.!?].*[.!?] ]]; then
  echo "Semantic summary must contain exactly one sentence." >&2
  exit 1
fi

word_count="$(awk '{ print NF }' <<<"$summary")"
if [ "$word_count" -gt 40 ]; then
  echo "Semantic summary must be at most 40 words." >&2
  exit 1
fi

normalized="$(printf '%s' "$summary" | tr '[:upper:]' '[:lower:]' | sed -E 's/[.!?]+$//; s/[[:space:]]+/ /g')"
generic_summary_pattern='^(the )?(ai security )?(guide )?(content|guide|documentation|material|changes?)( (is|are|was|were|has been|have been|has|have))? (updated|changed|modified|improved)$|^(updated|changed|modified|improved) (the )?(ai security )?(guide( content)?|content|documentation|material)$'
if [[ "$normalized" =~ $generic_summary_pattern ]]; then
  echo "Semantic summary is too generic to describe the substantive change." >&2
  exit 1
fi

printf '%s\n' "$summary"
