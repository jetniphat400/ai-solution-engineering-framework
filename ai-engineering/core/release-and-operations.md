# Release and Operations

## Release flow

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

- Requirement or issue reference
- Change summary and affected areas
- Architecture and security impact
- Verification evidence
- Migration and rollback procedure
- Known limitations and monitoring plan

## Production controls

- No agent self-approval.
- No direct production credential by default.
- Deploy through a controlled pipeline.
- Protect production configuration and migration recovery procedures.
- Stop rollout and roll back when critical health or user-flow checks fail.

## Learning loop

Convert incidents, review findings, and user feedback into updated requirements, tests, architecture decisions, policies, and backlog items.
