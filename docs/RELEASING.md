# Releasing the PDF

The Markdown files are the canonical source. The **Release PDF** workflow (`.github/workflows/release-pdf.yml`) builds a PDF from them and publishes it as a GitHub Release. Nothing generated is committed to the repository.

## Workflow behavior

- **Pull requests** (touching Markdown, `scripts/`, or the workflow): build and validate the PDF, then upload it as the `ai-security-101-pdf` Actions artifact. Download it from the workflow run to inspect it before merging. No release is created.
- **Pushes to `main`**: when the guide content (`README.md`, `NN_*.md` chapters) or the build/release machinery (`scripts/`, this workflow) changes, build the PDF the same way, then publish that exact PDF as a GitHub Release. Other changes, such as issue templates or `AGENTS.md`, do not create a release. Releases are only ever created from `main`.
- **Manual runs** (`workflow_dispatch`): build and upload the artifact only.

## Versioning

Releases use the UTC date as the tag, such as `2026-01-31`. Additional releases on the same date get a numeric suffix: `2026-01-31.2`, `2026-01-31.3`, and so on. Runs on `main` are serialized, and release creation fails rather than overwriting an existing tag.

## Document contents

The build reads the Markdown with pandoc's Markdown dialect, relaxed so that a heading directly after a list item or paragraph (no blank line) is still a heading, matching GitHub's rendering. The sources are not modified.

The PDF contains, in order: the README introduction, sections 1–11 in filename order (`NN_*.md`), the README Core Takeaways, and a Revisions section.

The guide's Mermaid diagrams are rendered to images for the PDF (see [Diagrams](#diagrams)).

The Revisions section is a table of date, author, and summary. It is generated at build time from GitHub release metadata (publish date, author, and release notes of previous releases) plus a row for the release being built. It is not maintained in the Markdown source.

## Revision authorship

The author in a revision is the human who originated the change, not the agent or bot that implemented or published it. The build resolves it, in order, as:

1. The author of an issue that the pull request closes (for example through `Fixes #123`).
2. The author of the pull request, if it is a human account.
3. The user who merged the pull request.
4. The user who triggered the workflow run, for runs without an associated pull request such as manual runs.

Bot accounts, including Copilot, are skipped in steps 1–3. The pull request is the one passed in by the `pull_request` event or, on pushes to `main`, the one associated with the pushed commit. In the Revisions table, the author is shown as `Display Name (@login)`, using the public name on the user's GitHub profile (looked up through the users API at build time, so nothing is hard-coded). If the account has no public name, or the lookup fails, only `@login` is shown. The resolved login is stored in a hidden `<!-- author: login -->` comment at the end of the release notes, so later builds credit the same person instead of the account that published the release. Releases without that comment fall back to the release publisher.

## Diagrams

Diagrams in the guide are Mermaid code blocks. GitHub renders them natively in Markdown. For the PDF, `scripts/mermaid.lua` (a pandoc Lua filter) renders each block to a PNG with [mermaid-cli](https://github.com/mermaid-js/mermaid-cli). Simple inline arrow examples stay as plain text. All diagrams are rendered with one shared Mermaid configuration (font size, spacing, theme) and at their natural size, so type size is consistent. Anything wider than the text block is scaled down to fit, so keep diagrams narrow: use short labels, wrap with `<br/>`, and prefer vertical layouts over long horizontal chains.

## Release summary

The release notes, and the matching Revisions row, summarize the change since the previous release. Pull-request preview PDFs include this prospective revision row using the same summary as a release. Commit messages and PR titles are not used.

When guide content changes, the deterministic workflow prepares a diff of the changed guide Markdown and enforces a 60 KB limit before passing it to a dedicated GitHub Agentic Workflow using Copilot. The agent has no repository checkout, GitHub read tools, shell access, PDF tools, or release permissions. It runs in the default Agent Workflow Firewall sandbox with only the capabilities needed to read the supplied diff and return a candidate summary artifact. The diff is untrusted data, and the agent is instructed not to follow instructions inside it.

The summarizer activates only for actors with write access, plus the Copilot bot, which is allowlisted with `on.bots` in `release-summary.md` so Copilot-authored pull requests exercise the same path. `roles: all` is deliberately not used, so other outside actors cannot trigger it. After changing `release-summary.md`, recompile `release-summary.lock.yml` with `gh aw compile`.

The summary artifact is untrusted model output. Before using it in release notes or the Revisions table, deterministic validation requires a nonempty, single sentence of at most 40 words and rejects generic summaries such as "AI security guide content updated." Invalid output or an agent failure fails the build; there is no low-quality fallback. Pull-request builds use the same diff preparation, summarization, and validation path as builds on `main`, so they fail on the same conditions.

Build or automation-only changes use the deterministic summary "Build and release automation updated." The first release uses "Initial release." No semantic-summary agent is run for either case.

Pull-request PDF artifacts are clearly marked as previews: the text `- PREVIEW` is appended to the document title, and `-PREVIEW` is appended to the PDF filename. The title uses the existing Pandoc title treatment. Preview status is not added to the Revisions table; its summary remains about the actual content change.

## Repository configuration

- Actions and GitHub Agentic Workflows with Copilot must be enabled for the repository or its organization. The summarization agent receives only `copilot-requests: write`; it has no repository content or release permissions. Its isolated safe-output job can upload only the one temporary summary artifact. The PDF build job requests `contents: read` and the permissions required to resolve revision authors, while `contents: write` is limited to the publish job.
- To keep releases immutable, enable **Settings → General → Releases → Enable release immutability**. Changes should then be published as a new release.
- Third-party actions are pinned to commit SHAs. Update the pins deliberately, for example with Dependabot.
- The PDF build installs `pandoc` and TeX packages from the runner's Ubuntu package repositories, so output can vary slightly over time. A separately maintained, versioned build container with pinned dependencies is planned as follow-up work.

## Local build

Requires `pandoc`, `xelatex` (`texlive-xetex`), the `lmodern` package, and, for diagrams, `mermaid-cli` (`mmdc`) with a Chrome or Chromium binary. Point the build at them with `MMDC` and `MERMAID_CHROME` if they are not on the default path:

```sh
scripts/build_pdf.sh 2026-01-31
```

The output is written to `build/`, which is git-ignored.
