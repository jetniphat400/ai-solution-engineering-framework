# Risk Classification

[design choice — rationale: this framework's own four-tier risk taxonomy and its criteria; broadly consistent with common impact-x-likelihood risk-matrix practice but not derived from one named external standard]

Assess impact, likelihood, reversibility, blast radius, data sensitivity, security boundary, operational criticality, and verification availability.

- Low: local, reversible, no sensitive boundary, easy verification
- Medium: multiple files or integrations, limited business impact, recoverable
- High: security, sensitive data, migration, broad business impact, difficult recovery
- Critical: production safety, major data loss, regulatory or enterprise-wide impact

Any authentication bypass, destructive production action, unreviewed data migration, or secret exposure is at least High. [established practice — floor-rating security/data-loss categories regardless of other factors, the same convention severity frameworks like CVSS apply to high-impact categories]
