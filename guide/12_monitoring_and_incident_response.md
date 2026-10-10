# 12. Monitoring and Incident Response

Monitoring closes the loop between preventive controls and real behavior. AI systems need infrastructure telemetry—requests, errors, latency, resource use, authentication events, and tool actions—plus behavioral testing. Hashes and versions tell you what you deployed; behavior tells you what it actually did. Useful monitoring can correlate a change with the exact model, adapter, prompt/configuration, vector index, dependency, or provider version involved.

## Incident-response goals and evidence

Incident response aims to contain the threat, preserve evidence, determine scope and root cause, eradicate the cause, recover a trusted state, and reduce recurrence. AI incidents rely on these same core principles, but responders may need AI-specific evidence to determine which model, data source, artifact, retrieval path, or tool behavior was involved.

Useful evidence includes model and adapter versions and hashes, provenance records, package and container versions, training-corpus and vector-index versions, prompts or context where policy permits, retrieval traces, tool calls, authentication and authorization events, evaluation results, and provider model versions. This evidence helps responders reproduce suspicious behavior, determine what changed, identify affected deployments or tenants, establish the likely attack path, and verify that recovery has restored expected behavior.

## Indicators and response by attack category

The indicators below cover only the attack categories in this guide. Use them to form an initial hypothesis and choose what evidence and containment steps to investigate first. This stays intentionally high level: organizations should fold AI incidents into a full incident-response plan and maintain system-specific playbooks with roles, escalation paths, evidence procedures, containment steps, recovery criteria, and other prescriptive details.

### Supply-chain compromise

- Unexpected hashes or signatures, unknown artifact sources, new custom code, unexpected package/version changes, or the same artifact behaving differently across environments.
- New outbound connections or credential access from a model-loading, notebook, build, or serving process.
Containment and recovery should isolate the affected notebook/build/runtime, stop deployment of suspect artifacts, revoke exposed credentials where needed, identify every deployment that shares the component, and restore from verified artifacts or dependencies.

### Data poisoning

- Unexpected training-corpus or RAG-corpus changes, suspicious duplicates or floods, unusual source/label distributions, changed metadata, unexpected retrieval sources, or targeted behavior that appears after data/index changes.
- Baseline tests begin failing even though the application code appears unchanged.
Containment and recovery should quarantine suspect data, stop affected ingestion/training jobs, compare with trusted snapshots, rebuild indexes or retrain from known-good sources when necessary, and verify behavior against the baseline before returning to service.

### Prompt injection, jailbreak, and guardrail bypass

- Outputs contradict higher-priority application instructions, reveal hidden context, or act on instructions found in retrieved documents or tool results.
- Known adversarial tests begin passing through a classifier, classifier confidence changes unexpectedly, or the protected LLM responds to malicious content the screening layer did not flag.
Containment and recovery should preserve the relevant prompt/context and guardrail decisions where policy permits, identify the untrusted content that influenced the model, disable dangerous downstream actions if needed, and strengthen deterministic controls rather than relying only on prompt changes.

### Sensitive-information disclosure

- Cross-user or cross-tenant data appears in responses, secrets appear in output or logs, unauthorized records are retrieved, or repeated probing seems designed to reconstruct or extract protected information.
Containment and recovery should stop the disclosure path, revoke exposed secrets, correct authorization or isolation failures, remove unnecessarily retained sensitive data, and determine which users, tenants, logs, or downstream systems received the information.

### Agent/tool abuse and availability attacks

- Unexpected tool calls, unusual parameters, high-impact actions without matching user intent, repeated denied operations, or spikes in downstream API use.
- Abnormal request volume, token/compute spikes, queue saturation, repeated expensive operations, or resource exhaustion tied to a user or workflow.
Containment and recovery should disable or narrow the affected tool or credential, stop unsafe actions, rate-limit or block abusive workloads, preserve tool and authorization logs, and restore service with least-privileged permissions.
