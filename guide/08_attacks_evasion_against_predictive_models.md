# 8. Attacks: Evasion Against Predictive AI

Adversarial machine learning means attacks that exploit or manipulate machine-learning systems. In this field, an evasion attack crafts an input at inference time—the stage when a trained model handles new inputs—to make a model misclassify it, or assign it to the wrong category. “Evasion” here means causing the model to fail at its intended classification task, not necessarily bypassing a security control. For example, an attacker could make subtle, carefully chosen changes to a photo of a dog so an image classifier labels it as a wolf, even though a person still recognizes the dog.

This differs from prompt injection: prompt injection supplies instructions intended to influence how an LLM follows its task or policies, while evasion changes an input so a predictive model assigns it the wrong category. Both use crafted inputs at inference time, but target different model behavior.

Evasion attacks target AI systems themselves, not the use of AI to attack unrelated systems. NIST AI 100-2e2025, [*Adversarial Machine Learning: A Taxonomy and Terminology of Attacks and Mitigations*](https://doi.org/10.6028/NIST.AI.100-2e2025), provides the taxonomy and terminology used here. Section 10 covers testing and techniques to improve how well models handle crafted inputs.
