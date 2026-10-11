# 9. Security Controls for AI Systems

AI defenses mix traditional cybersecurity controls with controls aimed specifically at models, data, retrieval, and behavior. The subsections below mirror the main attack surfaces in this guide: first the goal, then the concrete controls.

## Frameworks for organizing controls

The [NIST Cybersecurity Framework (CSF) 2.0](https://www.nist.gov/cyberframework) is a general, risk-based framework for managing cybersecurity outcomes and applies to AI systems as well as other technology. Its Govern, Identify, Protect, Detect, Respond, and Recover functions offer a way to organize the controls below without prescribing a single implementation. For example, inventorying models and dependencies supports Identify; access checks and least privilege support Protect; behavioral testing and audit logs support Detect; and preserving known-good data for rollback supports Recover.

The [NIST AI Risk Management Framework (AI RMF)](https://www.nist.gov/itl/ai-risk-management-framework) complements CSF by providing a lifecycle-oriented process for managing risks specific to AI systems: Govern, Map, Measure, and Manage. Use it to frame the system's context and impacts, assess AI-specific risks such as data poisoning or model behavior drift, and prioritize and track responses; the relevant Section 9 controls are possible responses, not a complete AI RMF implementation. Neither framework is a certification that a system is secure.

NIST's [draft Cybersecurity Framework Profile for Artificial Intelligence (Cyber AI Profile)](https://csrc.nist.gov/pubs/ir/8596/iprd) and its work on AI security control overlays are relevant emerging efforts to apply cybersecurity practices to AI. The Cyber AI Profile remains draft material, and the overlays are still being developed; neither should be treated as finalized control guidance.

## Prompt injection and context controls

These controls aim to reduce the chance that untrusted content changes model behavior, prevent model output from bypassing access or privilege checks, limit what a successful injection can reach, and make injection attempts easier to detect and test:

- **Keep authorization outside the LLM:** System/developer prompts can guide behavior, but application logic should enforce access, transaction limits, and privileges.
- **Separate and label untrusted content:** Use message roles or structured formats such as JSON or XML to identify which fields are instructions and which are untrusted data, rather than concatenating everything into one undifferentiated text string. Structure helps the model interpret context correctly, but it is not a hard security boundary.
- **Minimize exposed authority:** Limit what data and tools the model can reach.
- **Use classifiers and filters as layers:** Screen suspicious input/output, while assuming some malicious content will evade detection.
- **Test multi-turn behavior:** Include gradual context manipulation, task decomposition, indirect injection, and persistent-context scenarios in adversarial testing.
## RAG and data-access controls

These controls aim to keep unauthorized data out of retrieval results, reduce the chance that poisoned or untrusted knowledge enters context, preserve the origin and version of retrieved content, and make suspicious corpus changes visible:

- **Authorize before ranking:** Authenticate the requester, determine which records they may read, filter candidates using tenant/access metadata, and only then perform similarity search.
- **Protect ingestion:** Restrict who can add or modify knowledge and preserve source/ownership metadata.
- **Detect corpus manipulation:** Watch for unusual duplication, rapid corpus growth, unexpected source changes, or suspicious metadata edits.
- **Version indexes and sources:** Record which corpus, embedding model, and vector-index version produced a retrieval result so incidents can be reproduced and scoped.
## Supply-chain controls

These controls aim to prevent untrusted or vulnerable artifacts and packages from entering the pipeline, detect tampering or unsafe loading behavior, preserve provenance and integrity, and identify every deployment affected by a compromised component:

- **Check provenance and integrity:** Record sources and lineage for models, adapters, datasets, packages, and containers; use hashes/signatures where appropriate. These establish identity and change history, not benign behavior.
- **Prefer restricted formats and scan before loading:** Use non-executable tensor-only formats such as safetensors rather than general-purpose pickle-based serialization where possible; statically inspect artifacts that can execute code during deserialization and review custom model code before it runs.
- **Manage package dependencies:** Pin and review dependencies, scan packages/containers for known vulnerabilities, protect build systems, and watch for dependency confusion or typosquatting.
- **Maintain an artifact inventory:** Track deployed models, adapters, packages, containers, embedding models, prompts/configurations where relevant, and vector-index versions. Inventory supports CVE/advisory matching and lets responders find every system using a compromised component.
## Data-poisoning controls

Data-poisoning controls aim to prevent unauthorized changes to training and RAG data, preserve provenance and integrity, detect suspicious corpus changes or behavioral effects, and make it possible to recover from trusted data:

- **Use only reviewed and approved data sources:** Establish a review process for training and RAG data sources, and reject sources that do not meet provenance, integrity, quality, or authorization requirements.
- **Track provenance and versions:** Record source, ownership, timestamps, and versions for datasets and RAG documents.
- **Protect integrity:** Use integrity checks and reviewed change workflows for high-value corpora and indexes.
- **Monitor corpus changes:** Detect unexpected duplicates, corpus floods, unusual source distributions, label changes, or metadata changes.
- **Restrict write access:** Limit which identities and services can modify training stores, RAG corpora, vector indexes, and ingestion pipelines.
- **Keep trusted recovery points:** Preserve known-good snapshots so poisoned datasets or indexes can be rolled back or rebuilt.
- **Test behavior against a baseline:** Compare model and retrieval behavior with a trusted baseline after data changes and periodically during normal operation.

## Predictive-model robustness and extraction controls

These controls aim to help predictive models handle inputs deliberately crafted to make them err, and to reduce opportunities to copy a model through its deployed interface:

- **Test against adversarial inputs:** Evaluate models on representative inputs, including plausible examples deliberately modified to make the model err, and track errors across relevant conditions. Reassess after model or data changes.
- **Use robustness techniques where appropriate:** Adversarial training adds deliberately modified examples, along with their correct categories, to training so the model learns to classify them correctly. This can improve performance against some evasion attacks, but does not guarantee resistance to new attack strategies.
- **Protect prediction interfaces:** Authenticate and authorize API clients, apply rate limits, and expose only the outputs clients need; detailed scores or probabilities can make systematic replication easier.
- **Monitor query behavior:** Look for unusually large, repetitive, or systematically varied query patterns that may indicate extraction, and investigate or limit them.

## Agent and tool controls

Agent and tool controls aim to prevent prompt injection or model errors from gaining privileged access to sensitive systems, limit the actions and data available to the agent, block malformed or unauthorized tool calls, contain dangerous execution, and preserve an audit trail:

- **Least privilege:** Give each tool only the permissions and data needed for its task.
- **Authorization:** Check the requesting user and requested action in application code before execution.
- **Argument validation:** Validate model-generated parameters against schemas and business rules.
- **Approval gates:** Require explicit human approval for high-impact, irreversible, or unusual actions.
- **Sandboxing:** Isolate code execution and other dangerous capabilities.
- **Rate and resource limits:** Limit repeated actions, token use, compute, and downstream API consumption.
- **Auditability:** Record identity, model/version, authorization decision, tool call, and outcome without unnecessarily logging sensitive content.
## Sensitive-information and privacy controls

Sensitive-information and privacy controls aim to reduce how much protected data enters AI workflows, prevent cross-user or cross-tenant access, limit retention and secondary copies, protect observability data, and reduce the chance that model behavior reveals training information:

- **Minimize data:** Avoid putting secrets or unnecessary personal data into training, prompts, RAG, memory, or logs.
- **Isolate users and tenants:** Enforce access controls on RAG, memory, tools, and stored artifacts.
- **Control retention:** Set deletion and expiration rules for prompts, logs, memory, and derived data.
- **Protect observability data:** Redact sensitive fields and restrict access to traces and debugging systems.
- **Use privacy-preserving training where appropriate:** Techniques such as differential privacy can reduce some training-data leakage risks, but do not replace access control and governance.
## Behavioral testing and drift detection

Behavioral testing matters because malicious behavior can exist even when hashes, signatures, dependency scans, and static code review all look normal. Run the model or complete AI system against a stable set of known inputs and compare the results with an approved baseline. Test after changes, but also on a schedule when nothing is supposed to have changed.

This can reveal poisoned or backdoored weights, malicious adapters, compromised provider versions, prompt/configuration changes, RAG-index manipulation, safety regressions, or unexplained behavioral drift. Results will not always be byte-for-byte identical—especially for generative systems—so compare the properties that matter: expected facts, classifications, refusals, retrieval sources, tool choices, or statistically meaningful output patterns.

## Guardrails and safety alignment

Safety alignment trains or fine-tunes a model toward desired behavioral policies, such as refusing certain harmful requests. Guardrails are runtime controls around the model—classifiers, filters, policy engines, output validators, or tool restrictions—that try to detect or constrain unsafe behavior.

Alignment and guardrails are valuable, but neither secures an AI system by itself. Learned behavior and model-based classifiers are statistical controls with error rates; prompts are instructions, not authorization boundaries. A sternly worded prompt is still a prompt. Hard requirements such as access control, secret handling, and tool permissions still need deterministic application enforcement.
