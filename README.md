# AI Security 101

AI Security 101 is a practical introduction to the concepts needed to understand and secure AI and machine-learning systems. It begins with AI/ML and cybersecurity foundations, then moves through system reconnaissance, major AI attack classes, defenses, threat modeling, monitoring, and incident response. The central theme is simple: AI security does not replace traditional cybersecurity; it gives it a few new moving parts to secure. Established security principles still apply, but they must cover new assets and trust relationships such as training corpora, learned weights, model artifacts, retrieved context, and agent tools.

## Contents

1. [Foundations: AI/ML](1_foundations_ai_ml.md)
2. [Foundations: Security](2_foundations_security.md)
3. [AI/ML System Recon](3_ai_ml_system_recon.md)
4. [Attacks: Prompt Injection and Jailbreaking](4_attacks_prompt_injection_and_jailbreaking.md)
5. [Attacks: AI Supply Chain](5_attacks_ai_supply_chain.md)
6. [Attacks: Data Poisoning](6_attacks_data_poisoning.md)
7. [Attacks: Sensitive Information Disclosure and Privacy](7_attacks_sensitive_information_disclosure_and_privacy.md)
8. [Security Controls for AI Systems](8_security_controls_for_ai_systems.md)
9. [Guardrail Bypass](9_guardrail_bypass.md)
10. [Threat Modeling and Risk Assessment](10_threat_modeling_and_risk_assessment.md)
11. [Monitoring and Incident Response](11_monitoring_and_incident_response.md)
12. [Core Takeaways](#core-takeaways)

## Core Takeaways

**AI security extends traditional cybersecurity.** The core defensive ideas—identity, authorization, least privilege, supply-chain security, validation, monitoring, incident response, and defense in depth—still work. AI adds new assets and trust relationships that those ideas must cover.

**Treat models, data, and retrieval content as dependencies with provenance.** Training corpora, base models, adapters, packages, and RAG knowledge can all change system behavior. Know where they came from, who can modify them, and where each version is deployed.

**Do not give statistical controls deterministic authority.** LLMs, classifiers, alignment, and guardrails can guide or detect behavior but have error rates and can be evaded. Authorization, secret access, and tool permissions should be enforced by auditable application controls.

**Behavioral testing catches what static controls miss.** A model can have the expected hash and still contain a backdoor, and a system can drift without an intentional deployment. Re-run stable tests over time and investigate meaningful changes in outputs, retrieval, refusals, or tool use.

Secure the whole AI system, not only the model. The highest-impact failures often occur in surrounding software: exposed notebooks, weak RAG authorization, poisoned data, unsafe serialization, vulnerable dependencies, or over-privileged tools. Follow the data, artifacts, identities, and authority across the full lifecycle.
