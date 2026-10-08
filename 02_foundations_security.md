# 2. Foundations: Security

AI security extends traditional cybersecurity. Confidentiality, integrity, availability, identity, access control, secure software supply chains, monitoring, and incident response still matter. Start with those familiar concepts, then apply them to AI-specific assets such as training corpora, model artifacts, vector indexes, prompts, and tool-enabled actions.

## Impact: the CIA triad

Confidentiality, integrity, and availability (CIA) remain a widely used starting point for describing security impact. Modern security frameworks also use properties such as authenticity, accountability, non-repudiation, reliability, and assurance where they matter. CIA is a compact baseline, not the whole picture.

| Property | Traditional example | AI example |
| --- | --- | --- |
| Confidentiality | A database exposes customer records. | A RAG corpus, prompt, training corpus, model output, memory store, or log reveals information to an unauthorized party. |
| Integrity | Application code or records are changed without authorization. | Training data, model weights, adapters, prompts, RAG content, or agent state are maliciously changed. |
| Availability | A service is disrupted or exhausted. | Inference capacity, GPUs, vector stores, queues, or token budgets are exhausted or made unavailable. |

AI supply chains put a few additional properties front and center. Authenticity helps answer whether an artifact really came from the claimed source; accountability helps trace changes and actions to identities and components; assurance asks how much confidence we have that controls work as intended.

## Threat modeling, trust boundaries, and attack surface

Threat modeling is a form of risk assessment that asks how a system can be attacked and defended. Start with the system, its data flows, actors, assets, and trust boundaries; then identify threats, evaluate controls, and record the residual risk that remains after defenses are applied. Section 10 develops this process in more detail.

A trust boundary is a line where the level or assumption of trust changes—for example, between a user and an application, an application and external RAG content, or an LLM and a privileged tool. The attack surface is the set of reachable interfaces and behaviors through which an attacker can influence the system.

user | application | LLM service

^ trust changes here

external content | RAG ingestion / vector index

LLM tool request | privileged tool

## Secure design principles

The following principles recur throughout the defensive sections. Each is a general cybersecurity concept with a direct AI application:

- **Authentication and authorization:** Authentication establishes which user or service is making a request; authorization determines what that identity may access or do.
  - *Example: authenticate a RAG user, then restrict retrieval to documents that user may read.*
- **Least privilege:** Give each user, service, model, and tool only the access it needs.
  - *Example: an assistant that drafts email should not automatically receive permission to send or delete it.*
- **Zero trust:** Do not grant trust solely because a request comes from an internal network or familiar component; verify identity and authorization where access is requested.
  - *Example: an internal model registry does not make every artifact automatically approved for production.*
- **Validate at trust boundaries:** Treat data crossing a boundary as potentially malformed or malicious and validate it for the receiving component. This is broader than identity: for example, validate model-generated SQL parameters or tool arguments even after the caller has been authenticated.
- **Fail closed:** If a required security decision cannot be made safely, deny the action.
  - *Example: if document-authorization metadata is missing, exclude the document from retrieval.*
- **Protect secrets:** Keep credentials out of prompts and model context, scope them narrowly, and rotate them after suspected exposure.
- **Defense in depth:** Use independent layers so one failure does not defeat the whole design.
  - *Example: combine prompt-injection detection with RAG authorization, least-privileged tools, argument validation, and monitoring.*
