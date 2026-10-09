#!/usr/bin/env bash
# Print the Revisions table (date, author, summary) as Markdown.
# Usage: scripts/revisions_table.sh <version> <date> <author> <summary>
# The first row is the revision being built; the rest come from published
# GitHub release metadata (requires GH_TOKEN and GITHUB_REPOSITORY). A release's
# author is the human recorded in its "<!-- author: login -->" notes marker, or
# the release publisher if there is no marker. Authors are shown as
# "Display Name (@login)", or just "@login" when no public name is set.
set -euo pipefail

version="$1" date="$2" author="$3" summary="$4"

label() { if [ "$1" = "$2" ]; then echo "$2"; else echo "$2 ($1)"; fi; }
# "Display Name (@login)" when the account has a public name, otherwise "@login".
declare -A names=()
display() {
  local login="$1" name
  if [ -z "${names[$login]+x}" ]; then
    name="$(gh api "users/${login}" --jq '.name // empty' 2>/dev/null || true)"
    names[$login]="$name"
  fi
  if [ -n "${names[$login]}" ]; then echo "${names[$login]} (@${login})"; else echo "@${login}"; fi
}
cell() { tr '\r\n\t' '   ' | sed 's/  */ /g; s/^ //; s/ $//; s/|/\\|/g'; }

echo "| Date | Author | Summary |"
echo "| ---------------- | ------------------------ | ------------------------------------------ |"
printf '| %s | %s | %s |\n' "$(label "$version" "$date")" "$(display "$author" | cell)" "$(cell <<<"$summary")"
gh api --paginate "repos/${GITHUB_REPOSITORY}/releases" \
  --jq '.[] | select(.draft == false)
    | (.body // "") as $body
    | [.tag_name, .published_at[0:10],
       ($body | capture("<!-- author: (?<a>[A-Za-z0-9-]+) -->").a // null) // .author.login,
       ($body | gsub("<!-- author: [A-Za-z0-9-]+ -->"; "") | gsub("\\s+"; " ") | gsub("^ | $"; ""))] | @tsv' |
  while IFS=$'\t' read -r tag rdate rauthor body; do
    printf '| %s | %s | %s |\n' "$(label "$tag" "$rdate")" "$(display "$rauthor" | cell)" "$(cell <<<"$body")"
  done
