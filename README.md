# AI Security 101

AI Security 101 is a practical introduction to the concepts needed to understand and secure AI and machine-learning systems. The guide is maintained as numbered Markdown source files and published as a PDF.

[Latest PDF release (download the PDF asset)](https://github.com/jwardon/ai-security-101/releases/latest)

## Guide contents

1. [Introduction](guide/00_introduction.md)
2. [Foundations: AI/ML](guide/01_foundations_ai_ml.md)
3. [Foundations: Security](guide/02_foundations_security.md)
4. [AI/ML System Recon](guide/03_ai_ml_system_recon.md)
5. [Attacks: Prompt Injection and Jailbreaking](guide/04_attacks_prompt_injection_and_jailbreaking.md)
6. [Attacks: AI Supply Chain](guide/05_attacks_ai_supply_chain.md)
7. [Attacks: Data Poisoning](guide/06_attacks_data_poisoning.md)
8. [Attacks: Sensitive Information Disclosure and Privacy](guide/07_attacks_sensitive_information_disclosure_and_privacy.md)
9. [Attacks: Evasion Against Predictive AI](guide/08_attacks_evasion_against_predictive_models.md)
10. [Security Controls for AI Systems](guide/09_security_controls_for_ai_systems.md)
11. [Guardrail Bypass](guide/10_guardrail_bypass.md)
12. [Threat Modeling and Risk Assessment](guide/11_threat_modeling_and_risk_assessment.md)
13. [Monitoring and Incident Response](guide/12_monitoring_and_incident_response.md)
14. [Core Takeaways](guide/13_core_takeaways.md)

## Project features

- **PDF generation and releases:** GitHub Actions builds and validates the PDF, uploads preview PDFs for pull requests, and publishes releases from `main`. See [releasing the PDF](docs/RELEASING.md) and the [release workflow](.github/workflows/release-pdf.yml).
- **Weekly AI-security content review:** An automated review checks recent developments and can open a content issue when a verified change may warrant an update to the guide. See [weekly review details](docs/WEEKLY_CONTENT_REVIEW.md).
- **Related applied project:** [AI Project Scanner](https://github.com/jwardon/ai-project-scanner) demonstrates some of the guide's ideas by inspecting AI/ML projects for security-relevant artifacts and risks. It complements the guide's concepts and practices, but does not cover every topic in it.

The guide's Markdown files are the canonical content; repository automation and maintenance information lives here and in `docs/`.
