# Processing Lanes

[design choice — rationale: the number of lanes (3) and their exact thresholds are this framework's own risk-tiering scheme, not derived from one named external standard]

## Fast Lane

Use only when all are true:

- Small, clear, low-risk scope
- No architecture change
- No authentication, confidential data, financial logic, migration, deletion, infrastructure, production configuration, or protected asset change
- The entire change can be described in one sentence

Flow: understand -> implement -> focused verify -> diff review.

## Standard Lane

Default for features, APIs, business logic, integrations, and ordinary refactoring.
Use all nine phases in lightweight form.

## Controlled Lane

Mandatory for authentication, authorization, confidential or personal data, financial logic, migrations, deletion, infrastructure, production configuration, stack migration, and major architecture change.
Require formal artifacts, protected verification, specialist review, and human approval.

When uncertain, escalate. [established practice — precautionary principle / fail-safe default under uncertainty]
