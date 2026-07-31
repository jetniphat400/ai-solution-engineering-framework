# Release and Operations

## Release flow

[established practice — continuous delivery pipeline discipline, Humble & Farley]

```text
Change record or pull request
-> CI verification
-> independent review
-> staging when risk requires it
-> human approval
-> deployment pipeline
-> smoke and post-deployment checks
```

## Release evidence

[design choice — rationale: this framework's own fixed evidence checklist, paired with `ai-engineering/core/verification.md`'s evidence format rather than left free-form]

- Requirement or issue reference
- Change summary and affected areas
- Architecture and security impact
- Verification evidence
- Migration and rollback procedure
- Known limitations and monitoring plan

## Production controls

[established practice — segregation of duties in release approval, change-management discipline]

- No agent self-approval.
- No direct production credential by default.
- Deploy through a controlled pipeline.
- Protect production configuration and migration recovery procedures.
- Stop rollout and roll back when critical health or user-flow checks fail.

## Learning loop

[established practice — SRE postmortem culture / continuous-improvement feedback loop]

Convert incidents, review findings, and user feedback into updated requirements, tests, architecture decisions, policies, and backlog items.
