# 6. Attacks: Data Poisoning

Poisoning attacks manipulate information an AI system learns from or relies on to change its behavior. In standard adversarial-ML terminology, data poisoning targets training data. GenAI security discussions also commonly use terms such as RAG or knowledge-base poisoning for tampering with retrieval content used at inference time. They are related integrity attacks, but they hit different parts of the system.

## Training-data poisoning

Training-data poisoning changes a model's training corpus so the poisoned examples influence learned weights. It can affect LLMs, classifiers, embedding models, recommendation systems, vision models, and other learned models.

*Example: an attacker contributes many manipulated fine-tuning examples that associate a particular product with positive recommendations. After training, the LLM may favor that product even when the attacker is no longer present. For a classifier, poisoned examples could instead cause a targeted class of malicious files to be labeled benign.*

Label poisoning is a supervised-learning variant in which the attacker changes expected labels.

*Example: selected malicious samples are relabeled as “benign,” shifting what the classifier learns to accept.*

## RAG corpus poisoning

RAG corpus poisoning changes the external knowledge searched at inference time. Adding documents to a RAG knowledge source normally does not retrain the LLM; instead, the poisoned content can be retrieved later and supplied in context. A RAG stack may use its own embedding model, but the attack described here targets the knowledge corpus/index rather than changing the LLM's learned weights.

*Example: an attacker adds a convincing internal-looking document that falsely states that payments should be sent to a new bank account. The document only needs to land within the top-k retrieved chunks for a relevant query—not necessarily rank first—to influence the generated answer.*

Other RAG-poisoning strategies include flooding the corpus with near-duplicates, imitating authoritative sources, manipulating metadata, or inserting indirect prompt-injection instructions into documents. Section 10 maps controls to training and RAG poisoning separately.
