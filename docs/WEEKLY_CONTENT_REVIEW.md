# Weekly content review automation

The weekly review runs every Monday at 09:17 UTC and can also be started with **Actions → Weekly content review → Run workflow**. It searches current AI security developments and creates at most one `content` issue when a verified development materially warrants reconsidering the guide. It does not edit guide files or create pull requests.

The workflow uses GitHub Agentic Workflows with Copilot and Tavily's `tavily-mcp` 0.2.22 search server. Before enabling it, configure the repository Actions secret `TAVILY_API_KEY` with a Tavily API key. Copilot CLI usage billed to the organization must also be enabled for the repository's organization. GitHub Actions' built-in token is used for repository access and issue creation; no personal access token or other model credential is required.

The agent only has read access to repository contents and issues. A separate safe-output job receives the permission to create one issue, labeled `content`; title deduplication is also enabled. The source is `.github/workflows/weekly-content-review.md`, compiled to `.github/workflows/weekly-content-review.lock.yml` with `gh aw compile`. Keep the generated lock file in sync with its source.
