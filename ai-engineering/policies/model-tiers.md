# Provider-Neutral Model Tiers

[design choice — rationale: this framework's own provider-neutral capability-tier abstraction, so rules can name a required capability level without binding to one vendor's model catalog]

- FAST_MODEL: search, classification, and concise summaries
- STANDARD_CODING_MODEL: routine implementation following established patterns
- STRONG_REASONING_MODEL: architecture, broad refactoring, and complex debugging
- CRITICAL_REVIEW_MODEL: security, migration, high-risk design, and final adversarial review

Providers map these capabilities to their current model catalog. High-risk tasks must not be downgraded solely for cost. [established practice — risk-based assurance: controls are not relaxed to save cost, standard risk-management practice]
