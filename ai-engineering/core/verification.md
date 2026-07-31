# Verification Contract

## Minimum for every change

- Acceptance criteria evaluated
- Relevant focused checks or tests
- Build, startup, or runnable validation
- Final diff review
- Limitations and unverified areas reported

## Risk-based additions

- UI: responsive and visual verification
- API: integration and contract tests
- Database: migration, rollback, and integrity checks
- Authentication: role and abuse-case verification
- Refactoring: regression and behavior-equivalence evidence
- Dependency: vulnerability, license, and compatibility review
- Performance: benchmark or load evidence
- Deletion: backup, recovery, and authorization checks

## Evidence format

For each check report:

```text
Command or procedure:
Result:
Pass or fail:
Evidence location:
Remaining risk:
```

## Prohibited verification manipulation

Do not delete failing tests, weaken assertions, lower thresholds, disable lint or security rules, hide exceptions, over-mock behavior, or rewrite acceptance criteria to match the implementation.
