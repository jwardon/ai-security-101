# Releasing the PDF

The Markdown files in `guide/` are the canonical source. The **Release PDF** workflow (`.github/workflows/release-pdf.yml`) builds a PDF from them and publishes it as a GitHub Release. Nothing generated is committed to the repository.

## Workflow behavior

- **Pull requests** (touching `guide/NN_*.md` sources, `scripts/`, or the release workflow): build and validate the PDF, then upload it as the `ai-security-101-pdf` Actions artifact. Download it from the workflow run to inspect it before merging. No release is created.
- **Pushes to `main`**: when guide content (`guide/NN_*.md`) or the build/release machinery (`scripts/`, this workflow) changes, build the PDF the same way, then publish that exact PDF as a GitHub Release. Other changes, such as `README.md`, issue templates, or `AGENTS.md`, do not create a release. Releases are only ever created from `main`.
- **Manual runs** (`workflow_dispatch`): build and upload the artifact only.

## Versioning

Releases use the UTC date as the tag, such as `2026-01-31`. Additional releases on the same date get a numeric suffix: `2026-01-31.2`, `2026-01-31.3`, and so on. Runs on `main` are serialized, and release creation fails rather than overwriting an existing tag.

## Document contents

The build reads the Markdown with pandoc's Markdown dialect, relaxed so that a heading directly after a list item or paragraph (no blank line) is still a heading, matching GitHub's rendering. The sources are not modified.

The PDF contains all numbered guide sources in filename order (`guide/NN_*.md`), followed by a Revisions section. `guide/00_introduction.md` contains the guide introduction and contents list, and `guide/12_core_takeaways.md` contains the takeaways. The repository `README.md` is not guide content.

The guide's Mermaid diagrams are rendered to images for the PDF (see [Diagrams](#diagrams)).

The Revisions section is a table of date, author, and summary. It is generated at build time from GitHub release metadata (publish date, author, and release notes of previous releases) plus a row for the release being built. It is not maintained in the Markdown source.

## Revision authorship

The author in a revision is the human who originated the change, not the agent or bot that implemented or published it. The build resolves it, in order, as:

1. The author of an issue that the pull request closes (for example through `Fixes #123`).
2. The author of the pull request, if it is a human account.
3. The user who merged the pull request.
4. The target commit's author, if linked to a human GitHub account.
5. The user who triggered the workflow run, for runs without an associated pull request such as manual runs.
Bot accounts, including Copilot, are skipped when resolving issue, pull request, merger, and commit authors. The pull request is the one passed in by the `pull_request` event or, on pushes to `main`, the one associated with the pushed commit. In the Revisions table, the author is shown as `Display Name (@login)`, using the public name on the user's GitHub profile (looked up through the users API at build time, so nothing is hard-coded). If the account has no public name, or the lookup fails, only `@login` is shown. The resolved login is stored in a hidden `<!-- author: login -->` comment at the end of the release notes, so later builds credit the same person instead of the account that published the release. Releases without a valid human author marker resolve the human associated with their target commit; the release publisher is only a final fallback.

## Diagrams

Diagrams in the guide are Mermaid code blocks. GitHub renders them natively in Markdown. For the PDF, the `render-diagrams` job extracts and renders the images in the official Mermaid CLI container, then passes them to the `build` job as an Actions artifact. The PDF job runs in the official Pandoc/LaTeX container; both image references are pinned by immutable digest in `.github/workflows/release-pdf.yml`. This Mermaid-to-Pandoc pipeline uses maintained upstream images rather than an AI Security 101-owned build image: the spike found no requirement that justifies owning a separate image and its publishing, scanning, and maintenance lifecycle. `scripts/mermaid.lua` embeds the matching PNG in the PDF, while `scripts/build_pdf.sh` handles deterministic document construction. Simple inline arrow examples stay as plain text. All diagrams are rendered with one shared Mermaid configuration (font size, spacing, theme) and at their natural size, so type size is consistent. Anything wider than the text block is scaled down to fit, so keep diagrams narrow: use short labels, wrap with `<br/>`, and prefer vertical layouts over long horizontal chains.

## Release summary

The release notes, and the matching Revisions row, summarize the change since the previous release. Pull-request preview PDFs include this prospective revision row using the same summary as a release. Commit messages and PR titles are not used.

When guide content changes, the deterministic workflow prepares a diff of the changed guide Markdown and enforces a 60 KB limit before passing it to a dedicated GitHub Agentic Workflow using Copilot. The agent has no repository checkout, GitHub read tools, shell access, PDF tools, or release permissions. It runs in the default Agent Workflow Firewall sandbox with only the capabilities needed to read the supplied diff and return a candidate summary artifact. The diff is untrusted data, and the agent is instructed not to follow instructions inside it.

For the one-time migration from root-level guide sources, the workflow verifies that the previous release's README introduction, contents, and takeaways match their relocated guide sources. If the move contains no substantive guide changes, it uses a deterministic structural summary instead of treating the relocated text as new content. When guide content also changes, unchanged relocated sections are excluded from the semantic diff and the migration is identified in its context; substantive edits remain subject to the same 60 KB limit.

The summarizer activates only for actors with write access, plus the Copilot bot, which is allowlisted with `on.bots` in `release-summary.md` so Copilot-authored pull requests exercise the same path. `roles: all` is deliberately not used, so other outside actors cannot trigger it. The agent uploads `release-summary.txt` unarchived, and gh-aw names such an artifact after the file (`release-summary.txt`) regardless of the `name` requested in the prompt, so the build downloads `release-summary.txt`. `release-summary.md` is the human-authored workflow source; `release-summary.lock.yml` is generated from it by `gh aw compile` and must not be edited manually. Recompile the lock file after changing the source.

The summary artifact is untrusted model output. Before using it in release notes or the Revisions table, deterministic validation requires a nonempty, single sentence of at most 40 words and rejects generic summaries such as "AI security guide content updated." Invalid output or an agent failure fails the build; there is no low-quality fallback. Pull-request builds use the same diff preparation, summarization, and validation path as builds on `main`, so they fail on the same conditions.

Build or automation-only changes use the deterministic summary "Build and release automation updated." The first release uses "Initial release." No semantic-summary agent is run for either case.

### Agentic-workflow lifecycle and trust boundary

The gh-aw lifecycle adds work around the semantic task: pre-activation and activation prepare the run and its isolated runtime; the agent receives only the prepared, untrusted guide diff; detection separately analyzes the agent run for threats; safe outputs mediate the explicitly allowed artifact transfer; and conclusion collects run results and completes cleanup. The release-summary workflow uses AWF with its supported default Docker runtime, no checkout, no GitHub or shell tools, minimal network access, and an allowlist limited to one small `release-summary.txt` artifact.

Threat detection and safe outputs serve different purposes. Threat detection is a defense-in-depth check on agent execution; safe outputs constrain how data leaves the agent environment, allowing only the configured artifact through an isolated job. Neither makes the generated summary trusted: deterministic validation still checks it before release notes or the Revisions table use it.

The spike measured two model requests totaling about four seconds; most semantic-summary latency came from the gh-aw lifecycle, including runtime setup, container startup, AWF and network isolation, threat detection, safe-output handling, and conclusion/cleanup. No worthwhile optimization was identified that preserves the current security model while materially reducing that latency. Keep AWF on its supported Docker runtime, threat detection, safe outputs, and the least-privilege restrictions rather than trading away these controls for modest performance gains. Semantic reasoning remains narrowly delegated; build, validation, versioning, and publication stay deterministic. Issue #18's broader performance work was explicitly closed as `not_planned`.

Pull-request PDF artifacts are clearly marked as previews: the text `- PREVIEW` is appended to the document title, and `-PREVIEW` is appended to the PDF filename. The title uses the existing Pandoc title treatment. Preview status is not added to the Revisions table; its summary remains about the actual content change.

## Repository configuration

- Actions and GitHub Agentic Workflows with Copilot must be enabled for the repository or its organization. The summarization agent receives only `copilot-requests: write`; it has no repository content or release permissions. Its isolated safe-output job can upload only the one temporary summary artifact. The PDF build job requests only `contents: read`; the `prepare` job additionally holds the `pull-requests: read` and `issues: read` permissions needed to resolve revision authors, and `contents: write` is limited to the publish job.
- To keep releases immutable, enable **Settings → General → Releases → Enable release immutability**. Changes should then be published as a new release.
- Third-party actions are pinned to commit SHAs. Update the pins deliberately, for example with Dependabot.
- The workflow uses digest-pinned upstream Mermaid CLI and Pandoc/LaTeX containers instead of installing Mermaid CLI, Chrome, Pandoc, or TeX on the runner.

## Local build

The build script requires `pandoc`, `xelatex`, and the rendered diagrams in `build/diagrams/`. In CI, separate jobs provide the diagrams and run the PDF build in the pinned containers. To render diagrams locally with Docker, run the official Mermaid CLI image and then build with a local Pandoc/LaTeX installation:

```sh
docker run --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --volume "$PWD:/data" \
  --workdir /data \
  --entrypoint /bin/sh \
  ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:11.12.0@sha256:bad64c9d9ad917c8dfbe9d9e9c162b96f6615ff019b37058638d16eb27ce7783 \
  -c 'node scripts/render_mermaid.js'
scripts/build_pdf.sh 2026-01-31
```

The output is written to `build/`, which is git-ignored.
