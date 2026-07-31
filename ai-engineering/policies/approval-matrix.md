# Human Approval Matrix

[established practice — segregation of duties / change-management approval gates]

| Change | Required approver |
|---|---|
| User outcome and business rule | Business or project owner |
| New stack or major architecture | Technical owner |
| Authentication, confidential data, security exception | Security or technical owner |
| Database migration or destructive data operation | Database and technical owners |
| CI/CD, infrastructure, production configuration | Release or infrastructure owner |
| Production deployment | Authorized release owner |
| Protected test or quality threshold change | Technical owner independent of implementer |

If the organization lacks formal roles, assign at least one Business Owner and one Technical Owner before Controlled Lane work. [design choice — rationale: this framework's own minimum-viable-governance fallback for organizations without formal approval roles]
