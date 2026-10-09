#!/usr/bin/env bash
# Print the login of the human who originated the change being released.
# Usage: scripts/resolve_author.sh <commit-sha> <pr-number-or-empty> <fallback-login>
# Order of preference (bots are skipped):
#   1. author of an issue the pull request closes
#   2. author of the pull request
#   3. user who merged the pull request
#   4. the fallback login (the user who triggered the run)
# Requires GH_TOKEN and GITHUB_REPOSITORY.
set -euo pipefail

sha="$1" pr="${2:-}" fallback="$3"

if [ -z "$pr" ]; then
  pr="$(gh api "repos/${GITHUB_REPOSITORY}/commits/${sha}/pulls" --jq '.[0].number // empty' 2>/dev/null || true)"
fi

if [ -n "$pr" ]; then
  # shellcheck disable=SC2016
  human="$(gh api graphql \
    -F owner="${GITHUB_REPOSITORY%/*}" -F name="${GITHUB_REPOSITORY#*/}" -F number="$pr" \
    -f query='query($owner: String!, $name: String!, $number: Int!) {
      repository(owner: $owner, name: $name) {
        pullRequest(number: $number) {
          author { login __typename }
          mergedBy { login __typename }
          closingIssuesReferences(first: 10) { nodes { author { login __typename } } }
        }
      }
    }' \
    --jq '.data.repository.pullRequest
      | [(.closingIssuesReferences.nodes[].author), .author, .mergedBy]
      | map(select(. != null and .__typename == "User"))
      | (.[0].login // empty)' 2>/dev/null || true)"
  if [ -n "$human" ]; then
    echo "$human"
    exit 0
  fi
fi

echo "$fallback"
