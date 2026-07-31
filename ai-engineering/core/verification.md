# Verification Contract

## Minimum for every change

[established practice — TDD / Definition of Done]

- Acceptance criteria evaluated
- Relevant focused checks or tests
- Build, startup, or runnable validation
- Final diff review
- Limitations and unverified areas reported

## Risk-based additions

[design choice — rationale: maps verification depth to `ai-engineering/policies/risk-classification.md`'s categories; this framework's own risk-to-check mapping, not a named external standard]

- UI: responsive and visual verification
- API: integration and contract tests
- Database: migration, rollback, and integrity checks
- Authentication: role and abuse-case verification
- Refactoring: regression and behavior-equivalence evidence
- Dependency: vulnerability, license, and compatibility review
- Performance: benchmark or load evidence
- Deletion: backup, recovery, and authorization checks

## Evidence format

[design choice — rationale: a fixed, fill-in-the-blank format keeps verification evidence comparable and complete across unrelated changes, rather than free-form per reporter]

For each check report:

```text
Command or procedure:
Result:
Pass or fail:
Evidence location:
Remaining risk:
```

## Prohibited verification manipulation

[established practice — testing-integrity norms (e.g. ISTQB testing principles) against gaming the check rather than meeting it]

Do not delete failing tests, weaken assertions, lower thresholds, disable lint or security rules, hide exceptions, over-mock behavior, or rewrite acceptance criteria to match the implementation.
