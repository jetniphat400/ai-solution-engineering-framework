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

## Claim confidence labels

[design choice — rationale: promotes the `verified`/`inferred`/`unknown` vocabulary already used for scenario/task detection in the `engineer` skill into a standing verification-contract rule, after two independent field-test incidents (cited below) found a claim acted on or restated as settled fact with no confidence tag anywhere in the chain]

Any claim persisted to a document, or restated across turns or sessions, carries one of three labels — `verified` (directly observed or re-derived from current code or data), `inferred` (derived from indirect signals, not yet re-checked), or `unknown` (no evidence behind it yet). Never silently upgrade `inferred` or `unknown` to `verified`.

A claim inherited from a prior audit or pass — "these are identical," "this is dead/unused code," "this dependency is safe to remove" — starts at most `inferred`, regardless of the confidence the prior pass assigned it, and must be re-derived from current code before being treated as `verified`; where money, scoring, or another real (non-synthetic) data path is involved, re-check against real data too, not just the diff.

Evidence this closes a real, repeated gap, not a hypothetical one: pilot #2 (`docs/field-tests/2026-08-19-pcc-pilot-2.md`) found five inherited "these look identical" dedup claims re-checked in a row, four of which needed correction or a fresh decision once actually re-derived — and, independently, a subagent's unverified suspicion was restated as fact across two turns before a direct challenge reversed it, the same failure mode pilot #1 (`docs/field-tests/2026-07-31-pcc-pilot.md`, friction #19) had already recorded once.

## Prohibited verification manipulation

[established practice — testing-integrity norms (e.g. ISTQB testing principles) against gaming the check rather than meeting it]

Do not delete failing tests, weaken assertions, lower thresholds, disable lint or security rules, hide exceptions, over-mock behavior, or rewrite acceptance criteria to match the implementation.
