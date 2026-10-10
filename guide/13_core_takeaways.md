# Core Takeaways

**AI security extends traditional cybersecurity.** The core defensive ideas—identity, authorization, least privilege, supply-chain security, validation, monitoring, incident response, and defense in depth—still work. AI adds new assets and trust relationships that those ideas must cover.

**Treat models, data, and retrieval content as dependencies with provenance.** Training corpora, base models, adapters, packages, and RAG knowledge can all change system behavior. Know where they came from, who can modify them, and where each version is deployed.

**Do not give statistical controls deterministic authority.** LLMs, classifiers, alignment, and guardrails can guide or detect behavior but have error rates and can be evaded. Authorization, secret access, and tool permissions should be enforced by auditable application controls.

**Behavioral testing catches what static controls miss.** A model can have the expected hash and still contain a backdoor, and a system can drift without an intentional deployment. Re-run stable tests over time and investigate meaningful changes in outputs, retrieval, refusals, or tool use.

**Secure the whole AI system, not only the model**. The highest-impact failures often occur in surrounding software: exposed notebooks, weak RAG authorization, poisoned data, unsafe serialization, vulnerable dependencies, or over-privileged tools. Follow the data, artifacts, identities, and authority across the full lifecycle.
