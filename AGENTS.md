# Repository Engineering Contract

This file is the vendor-neutral source of repository instructions for coding agents.

## Project identity

- Project: [PROJECT NAME]
- Purpose: [PROJECT PURPOSE]
- Project state: [GREENFIELD | EXISTING_MAINTENANCE | NEW_MODULE | MODERNIZATION | MIGRATION | PROTOTYPE | BUG_FIX]
- Default risk: [LOW | MEDIUM | HIGH | CRITICAL]
- Technical owner: [NAME OR ROLE]
- Business owner: [NAME OR ROLE]

## Required behavior

1. Understand the user outcome before proposing a solution.
2. Separate confirmed facts, assumptions, constraints, and unknowns.
3. Classify the project state, change type, risk, trust level, and processing lane.
4. For non-trivial work, design and plan before modifying files.
5. Prefer the simplest architecture that satisfies the requirements.
6. Preserve valid repository conventions and improve unsafe conventions explicitly.
7. Build in small, reviewable vertical slices.
8. Do not declare completion without verifiable evidence.
9. Stop for human review on protected or high-risk changes.

## Conventions

[LIST PROJECT-SPECIFIC, HUMAN-APPROVED CONSTRAINTS: NAMING, STYLE, MODULE LAYOUT, OR PROCESS RULES ALREADY AGREED BY THE TEAM. LEAVE EMPTY IF NONE EXIST YET RATHER THAN INVENTING ONE.]

Conventions recorded here rank as "human-approved project constraints" in the resolution order in `ai-engineering/policies/instruction-authority.md` — second only to legal, security, and organization policy, and above the Common Engineering Core and everything ranked below it. That still-required safety valve applies regardless of rank: any conflict affecting security, data, architecture, or protected verification gets stopped and reported, never resolved silently by rank alone.

## Engineering baseline

- No committed secrets or environment-specific credentials.
- Do not hardcode deployment-specific URLs, ports, paths, tokens, or connection strings.
- Use validated configuration and named domain constants.
- Apply separation of concerns, high cohesion, and low coupling.
- Avoid circular dependencies, global mutable state, god files, and utility dumping grounds.
- Keep UI, application logic, domain logic, data access, and integrations appropriately separated.
- Reuse code only when the behavior and responsibility are genuinely shared.
- Do not add dependencies or abstractions without a demonstrated need.
- Do not refactor unrelated code in the same change.
- Validate input at trust boundaries and use parameterized database access.
- Handle errors explicitly and avoid logging secrets or sensitive data.

## Project commands

Replace every placeholder before allowing autonomous edits.

```text
Install:    [COMMAND]
Run:        [COMMAND]
Build:      [COMMAND]
Format:     [COMMAND]
Lint:       [COMMAND]
Type check: [COMMAND]
Unit tests: [COMMAND]
Integration tests: [COMMAND]
Smoke test: [COMMAND]
```

## Architecture summary

[DESCRIBE MODULES, DEPENDENCY DIRECTION, DATA STORES, EXTERNAL INTEGRATIONS, AND DEPLOYMENT TARGET]

Detailed framework references:

- Workflow: `ai-engineering/core/workflow.md`
- Engineering principles: `ai-engineering/core/engineering-principles.md`
- Architecture and refactoring: `ai-engineering/core/architecture-and-refactoring.md`
- Verification: `ai-engineering/core/verification.md`
- Red team: `ai-engineering/core/redteam.md`
- Security: `ai-engineering/core/security.md`
- Release and operations: `ai-engineering/core/release-and-operations.md`

## Processing lanes

Use `ai-engineering/policies/processing-lanes.md`.

- Fast Lane only when the change is small, clear, low-risk, and does not affect architecture, security, data migration, production configuration, or protected assets.
- Standard Lane is the default.
- Controlled Lane is mandatory for authentication, authorization, financial logic, confidential data, migrations, deletion, infrastructure, production configuration, stack migration, or major architecture change.
- When uncertain, escalate the lane.

## Protected assets

Do not change these without explicit human approval:

- Acceptance and security tests
- Golden fixtures and approved snapshots
- CI/CD workflows and quality thresholds
- Production configuration and deployment safeguards
- Data migration recovery procedures
- Secret stores and credentials

Project-specific protected paths:

```text
[ADD PATHS]
```

## Verification contract

At minimum, verify acceptance criteria, relevant tests, a build or runnable check, and the final diff.
Run additional checks required by the change type and risk.
Never make a failing check pass by deleting tests, weakening assertions, reducing thresholds, suppressing errors, or changing acceptance criteria after implementation.

## Human approval required

- New technology stack or major architecture decision
- Authentication or authorization changes
- Database migration, data deletion, or destructive commands
- Confidential, personal, financial, or safety-critical logic
- CI/CD, protected tests, production configuration, and deployment
- Security exceptions and new external plugins, MCP servers, or dependencies with elevated access

## Completion status

End with exactly one status and the evidence supporting it:

- `DONE_VERIFIED`
- `CONDITIONAL_PASS`
- `REPLAN_REQUIRED`
- `REQUIREMENT_AMBIGUOUS`
- `SECURITY_BLOCKED`
- `ENVIRONMENT_UNAVAILABLE`
- `NEEDS_HUMAN`

Work tracked in a multi-item register or through a Gate (see
`ai-engineering/core/workflow.md`) maps its own per-item status onto
one of the statuses above at closeout via that section's crosswalk —
this list is not restated per item.
