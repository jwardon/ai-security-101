# Releasing the PDF

The Markdown files are the canonical source. The **Release PDF** workflow
(`.github/workflows/release-pdf.yml`) builds a PDF from them and publishes it as
a GitHub Release. Nothing generated is committed to the repository.

## Usage

1. Go to **Actions → Release PDF → Run workflow**.
2. Pick the branch to release (normally `main`) and enter a short summary of
   the changes.
3. The workflow builds the PDF and creates the release with the PDF attached.

## Versioning

Releases use the UTC date as the tag, such as `2026-01-31`. Additional
releases on the same date get a numeric suffix: `2026-01-31.2`,
`2026-01-31.3`, and so on. Runs are serialized, and release creation fails
rather than overwriting an existing tag.

## Document contents

The PDF contains, in order: the README introduction, sections 1–11 in filename
order (`NN_*.md`), the README Core Takeaways, and a Revisions section.

The Revisions section is generated at build time from GitHub release metadata
(tag, publish date, author, and release notes of previous releases) plus the
release being built. It is not maintained in the Markdown source.

## Repository configuration

- The workflow requests only `contents: write`, which is needed to create the
  tag and release.
- Actions must be enabled, and the default `GITHUB_TOKEN` must be allowed to
  write contents (or the workflow permission is granted explicitly, as it is
  here).
- To keep releases immutable, enable **Settings → General → Releases → Enable
  release immutability**. Changes should then be published as a new release.

## Local build

Requires `pandoc`, `xelatex` (`texlive-xetex`), and the `lmodern` package:

```sh
scripts/build_pdf.sh 2026-01-31
```

The output is written to `build/`, which is git-ignored.
