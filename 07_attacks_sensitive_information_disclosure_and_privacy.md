# 7. Attacks: Sensitive Information Disclosure and Privacy

Sensitive information disclosure covers cases where an AI system reveals information that should not be exposed. Some are straightforward leaks: excessive access, unsafe logging, weak RAG authorization, or secrets placed in context. Others are active privacy attacks that probe a model or representation to infer protected information.

## Where sensitive information can leak

Sensitive data can enter or emerge from several parts of an AI system:

- **Prompts and runtime context:** Sensitive data may be supplied directly by users or added by the application.
  - *Example: a user pastes an API key, or a retrieved private document enters context and part of it appears in the response.*
- **RAG and vector stores:** Retrieved documents, vector records, and associated access metadata can expose data across users or tenants.
  - *Example: weak tenant filtering lets one customer retrieve another customer's document.*
- **Training corpora and model behavior:** Sensitive training content may be memorized or inferred from model behavior.
  - *Example: a confidential product formula accidentally included in fine-tuning data is memorized by the model and later reproduced under targeted prompting.*
- **Persistent memory:** Application-managed state can be saved across sessions and later reinserted into context; unlike model weights, it can change without retraining.
  - *Example: a shared or mis-scoped memory causes one user's stored information to appear in another user's session.*
- **Logs, traces, and caches:** Observability and performance systems can become secondary repositories of sensitive AI data.
  - *Example: a debugging system stores complete prompts, retrieved documents, tool arguments, or credentials in a system with broader access than the production application.*
## Active privacy attacks

Active privacy attacks deliberately analyze model behavior or representations to learn protected information:

- **Membership inference:** Compare responses, confidence, loss, or related behavior to estimate whether a particular record was part of a protected training set.
  - *Example: an attacker compares a model’s confidence on known members and non-members, then uses the difference to estimate whether a particular patient record was included in a private training dataset.*
- **Data reconstruction (often called model inversion):** Use model outputs or exposed representations to reconstruct sensitive training information, attributes, or representative inputs.
  - *Example: repeated queries to a face-recognition model are used to reconstruct an approximation of facial features represented in its private training data.*
- **Training-data extraction:** Repeatedly or strategically query a generative model to elicit memorized training sequences.
  - *Example: targeted prompts cause a model to reproduce passages from a confidential document that was accidentally included in its training corpus.*
- **Embedding inversion:** Analyze an embedding—sometimes with an auxiliary model or search process—to infer text, attributes, or semantically similar content that could have produced it.
  - *Example: an attacker steals an embedding for an internal project note and uses an inversion model to reconstruct text close enough to reveal that “Project Orion” has been delayed until March.*
