# AGENTS.md

## Project Purpose

AI Security 101 is a practical introduction to AI security for both:

- Security practitioners who need enough AI/ML knowledge to understand AI-specific security risks.
- AI/ML practitioners who need enough security knowledge to understand how traditional and AI-specific security principles apply to AI systems.

The Markdown files in `guide/` are the canonical source for the guide.

## General Guidelines

- Make changes that are scoped to the assigned issue.
- Preserve the existing organization unless the issue explicitly requires structural changes.
- Avoid unrelated cleanup, rewriting, or refactoring.
- Prefer simple, maintainable solutions over unnecessary complexity.
- Do not manually modify generated artifacts.
- Follow existing repository conventions unless the issue explicitly changes them.

## Content Guidelines

- Prioritize technical accuracy over style.
- Use established AI/ML and cybersecurity terminology.
- Introduce specialist terminology only when it adds useful precision.
- Treat AI security as an extension of traditional cybersecurity rather than an entirely separate discipline.
- Distinguish related concepts when conflating them would be misleading.
- Give concrete examples for attack techniques and other concepts where examples improve understanding.
- Do not elevate speculative, narrowly demonstrated, or minor techniques into major attack categories without strong justification.
- Clearly distinguish established guidance from emerging research or uncertain claims.

## Markdown Formatting

- Do not hard-wrap Markdown prose. Keep each paragraph on a single source line.
- Code blocks, YAML, and shell may be wrapped where useful.

## Writing Style

Match the existing voice of the guide:

- Direct and concise.
- Professional but slightly casual.
- Prefer plain language over unnecessary jargon.
- Use occasional understated or dry humor only when it helps a concept stick.
- Do not sacrifice technical precision for personality.
- Avoid strained metaphors, excessive cleverness, or unnecessary words.
- Preserve existing terminology and phrasing when there is no substantive reason to change them.

## Sources

When researching or adding factual material:

- Prefer authoritative primary sources.
- Prefer sources such as NIST, MITRE, OWASP, original research, standards bodies, and official framework or vendor documentation where appropriate.
- Use secondary sources when they add useful context, but do not rely on them when a suitable primary source is available.
- Verify claims against the cited source rather than citing a source that only discusses a related topic.
- Prefer current guidance when authoritative sources have changed.

## Automation and Repository Changes

- Keep automation deterministic where practical.
- Keep source material separate from generated artifacts.
- Prefer version-controlled configuration over manual or out-of-band configuration when GitHub supports it.
- Do not weaken repository security, review, or validation controls unless explicitly required by the issue.
- Do not introduce secrets, credentials, or environment-specific values into the repository.
- Grant workflows only the permissions they require.
- Keep workflow YAML focused on orchestration. Straightforward command sequences and small, locally understandable shell expressions can stay inline; substantial control flow, parsing, validation, or reusable behavior belongs in a script under `scripts/`. Don't extract simple inline logic just because it contains a conditional or shell operator.
- Prefer built-in platform capabilities and straightforward implementations over unnecessary dependencies.

## Validation

Before considering work complete:

- Run the repository's applicable validation and build checks.
- Ensure Markdown changes pass the configured Markdown linting rules.
- Verify that new or changed automation behaves as required by the issue.
- Check that links, filenames, and references introduced by the change are valid.
- Review the final diff for unrelated changes.

If a required validation cannot be performed, state that clearly in the pull request rather than assuming it passed.

## Pull Requests

Pull requests should:

- Clearly summarize what changed.
- Reference the issue being addressed.
- Explain any significant implementation decisions.
- Identify validation that was performed.
- Call out limitations, unresolved questions, or follow-up work when applicable.

Satisfy the issue's acceptance criteria without expanding the scope unnecessarily.
