# 8. Attacks: Evasion Against Predictive AI

An evasion attack deliberately crafts an input at inference time—the stage when a trained model handles new inputs—so a predictive model makes a desired incorrect classification. “Evasion” in adversarial-ML terminology means evading the model's intended classification behavior; it does not necessarily mean bypassing a security control.

*Example: an attacker places a small, carefully designed sticker on a stop sign, changing the image a self-driving car's camera sends to its road-sign classifier. The classifier labels the sign as a speed-limit sign instead of a stop sign, which could cause the car to enter the intersection without stopping and create a collision risk.*

This attack targets predictive AI, which classifies or predicts outcomes. By contrast, prompt injection targets generative AI such as an LLM: the attacker supplies instructions or content intended to change what the system generates or how it follows its task.
