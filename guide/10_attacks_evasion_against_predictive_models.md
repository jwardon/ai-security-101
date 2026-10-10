# 10. Attacks: Evasion Against Predictive AI

In adversarial-ML terminology, an evasion attack crafts an inference-time input to make a model misclassify it by exploiting the model's learned decision boundary. “Evasion” here means evading the model's expected classification behavior, not necessarily bypassing a security control. For example, an attacker could make subtle, carefully chosen changes to a photo of a dog so an image classifier labels it as a wolf, even though a person still recognizes the dog.

This differs from prompt injection: prompt injection supplies instructions intended to influence how an LLM follows its task or policies, while an evasion attack manipulates input features to change a predictive model's output. Both use crafted inputs at inference time, but target different model behavior.

Evasion attacks target AI systems themselves, not the use of AI to attack unrelated systems. NIST AI 100-2e2025, [*Adversarial Machine Learning: A Taxonomy and Terminology of Attacks and Mitigations*](https://doi.org/10.6028/NIST.AI.100-2e2025), provides the taxonomy and terminology used here. Section 8 covers adversarial testing and robustness techniques.
