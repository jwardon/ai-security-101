# 4. Attacks: Prompt Injection and Jailbreaking

LLM applications combine instructions and data inside a model context. A system prompt is application-supplied text that describes the model's role and operating instructions; developer instructions may add application-specific rules; user prompts, retrieved documents, tool results, and other external content add less-trusted material. These layers influence behavior, but they do not create hard security boundaries.

Models and model-based classifiers are statistical systems. Deterministic inference does not turn learned decision boundaries into perfect security rules: ambiguous inputs, distribution shifts, and adversarially crafted examples can still produce errors. Compact classifiers are often cheaper and faster than the LLM they protect, which can create a capability gap attackers try to exploit. Model-based controls can reduce risk; they cannot guarantee 100% detection.

## Prompt injection

Prompt injection is the insertion of attacker-controlled instructions into input that becomes part of an LLM's prompt or context, causing the model to follow those instructions in a way the application did not intend. There is no separate command channel involved: the malicious instruction is text in the same overall context the model uses to decide what to do next.

For example, an application may intend a retrieved webpage to be data to summarize. If the page contains text telling the model to ignore that task and reveal other context, the model may treat the embedded text as an instruction. The application intended different authority levels; the model still has to infer that distinction from context.

The system prompt matters because it typically contains high-priority application instructions that shape the model's role and behavior. Prompt injection tries to redirect behavior away from those intended instructions. A system prompt can guide the model, but it should not contain secrets or be relied on to enforce authorization, transaction limits, or tool permissions.

Common delivery and manipulation techniques include:

- **Direct injection:** Malicious instructions are supplied directly in the user prompt.
  - *Example: a user tells a document assistant to ignore its assigned summarization task and instead reveal the hidden instructions that govern its behavior.*
- **Indirect injection:** Instructions are embedded in content the application later reads, such as webpages, email, documents, RAG records, code comments, or tool output.
  - *Example: a webpage contains hidden text instructing an AI browsing assistant to disregard the user’s request and copy private context into its response.*
- **Instruction override / conflict:** The input explicitly asks the model to ignore, replace, reinterpret, or supersede earlier instructions.
  - *Example: a prompt says that a new “administrator policy” supersedes the application’s earlier rule not to disclose internal configuration.*
- **Context manipulation:** The attacker supplies examples, role framing, quoted text, or other context intended to change how later instructions are interpreted.
  - *Example: an attacker gives several fabricated examples in which the assistant treats confidential records as public, then asks it to handle a real confidential record the same way.*
- **Obfuscation or alternate representations:** The malicious instruction is hidden or transformed so a human or upstream filter is less likely to recognize it while the downstream model may still recover the meaning.
  - *Example: an attacker writes a blocked instruction with inserted punctuation and look-alike characters, such as disguising a request to reveal a password, so a simple screening model misses the phrase while the LLM still interprets the request correctly.*

## Prompt injection in agent workflows

When an LLM can request actions through tools, prompt injection can hijack the agent's goal and turn a changed response into a real operation. If the application executes the request without independently checking its authority, a legitimate tool can be misused for the attacker's purpose. For example, hidden instructions in a vendor email may cause a document assistant to use its search and email tools to retrieve confidential pricing and send it to the attacker. A broad user or service identity can give the attacker access the email sender did not have, and an automated follow-up may trigger further disclosures. The attack uses existing prompt-injection techniques; tools and delegated authority change what the attacker can achieve, not whether model instructions are authorization.

Delegating work between agents creates a similar path: a receiving agent may act on an instruction or result from another agent without knowing its source or scope. For example, an attacker who can influence a research agent's input may cause it to send a misleading recommendation to a purchasing agent, which then initiates an unauthorized order. The attacker gains a way to affect downstream actions through the handoff; the same concern applies to untrusted tool output and other inputs, not only agent messages.

## Multi-turn and context-building attacks

Prompt injection can be spread across a conversation. No single message has to look dangerous; the combined context can gradually move the model toward an unsafe state.

- **Gradual instruction drift:** Repeatedly reframe the task until the model accepts behavior it would have rejected directly.
  - *Example: several turns progressively redefine a private-data analysis task until the assistant begins revealing individual records rather than the aggregate statistics originally requested.*
- **Task decomposition:** Split a prohibited or sensitive objective into benign-looking subtasks and combine the results.
  - *Example: instead of asking for a protected secret directly, an attacker asks separate questions about its format, prefix, suffix, and surrounding context, then combines the answers.*
- **Context priming:** Establish assumptions, examples, roles, or fictional framing that make a later instruction more likely to be followed.
  - *Example: the attacker first establishes a fictional “security audit” scenario in which disclosure is portrayed as authorized, then introduces a real request for restricted information.*
- **Adaptive probing:** Use refusals and partial successes to learn which wording or intermediate steps are effective.
  - *Example: after a guardrail rejects a request to reveal a confidential project codename, the attacker tries progressively less direct variants—asking for the name used internally, then its initials, then a clue about what it rhymes with—using each response to shape the next attempt.*
- **Persistent-context abuse (memory/context poisoning):** Plant instructions or false state in conversation history or application memory so they influence later turns.
  - *Example: an attacker causes shared memory to record that they are an approved administrator, and a later session uses that false state when deciding how to answer, potentially exposing information or authorizing actions the attacker could not request directly.*
## Jailbreaking

Jailbreaking is prompt injection aimed at bypassing safety restrictions on model behavior. Those restrictions can come from safety/alignment training, system or developer instructions, and runtime guardrails. The goal is what makes it a jailbreak: getting the application to produce behavior its safety policy was intended to prevent, regardless of which layer is bypassed.

Jailbreaks may use role-play, hypothetical framing, encoded or obfuscated instructions, multi-turn decomposition, or other prompt-injection techniques. Prompt injection is broader: it can also redirect an application toward unauthorized data or tool use even when the requested content is not itself prohibited.

*Example: after a model refuses to provide instructions for a prohibited action, the user asks it to write a fictional scene in which a character explains those same instructions step by step, attempting to make the safety restriction seem inapplicable.*
