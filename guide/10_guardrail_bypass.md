# 10. Guardrail Bypass

Attackers may craft inputs specifically to evade model-based guardrails. Input classifiers are often much smaller than the LLMs they protect to keep latency, cost, and compute overhead low. The tradeoff is a potential capability gap: text the classifier misses may still be understood by the larger LLM.

## Common bypass techniques

Some techniques overlap with prompt injection because malicious content can both carry an instruction and hide it from a detector. Same input, different job: here the focus is specifically on getting past the guardrail.

- **Character-level obfuscation:** Misspellings, inserted characters, homoglyphs, unusual Unicode, or spacing can lower detector confidence while preserving meaning.
  - *Example: an attacker replaces characters in “ignore previous instructions” with visually similar Unicode letters and inserts extra spacing, causing a lightweight classifier to miss the phrase while the downstream LLM still interprets it.*
- **Representation changes:** Encode or transform an instruction so an intermediate step or downstream model recovers the meaning.
  - *Example: an attacker Base64-encodes an instruction to reveal hidden configuration and asks the LLM to decode and follow it, bypassing a filter that only inspects ordinary text.*
- **Paraphrasing:** Express the same objective using wording unlike the detector's training examples.
  - *Example: after a detector blocks the phrase “ignore previous instructions,” the attacker asks the model to treat all directions received before the current message as outdated and follow only the new policy below.*
- **Task decomposition:** Spread a prohibited objective across individually benign-looking requests.
  - *Example: instead of asking for a protected employee record directly, an attacker separately asks for the employee's department, start date, manager, and office location, then combines the individually disclosed details into a profile the guardrail would have blocked as a single request.*
- **Multi-turn adaptation:** Use refusals and partial successes to search for inputs that pass the guardrail.
  - *Example: after a classifier blocks a request to expose a hidden system instruction, the attacker retries with variants such as asking the model to quote its opening configuration, summarize its private setup text, or list the rules it received before the conversation until one formulation passes the filter.*
The defensive response is defense in depth: test guardrails adversarially, monitor bypasses, use more than one independent layer where warranted, and ensure a guardrail failure cannot directly grant access, disclose a secret, or authorize a tool action.
