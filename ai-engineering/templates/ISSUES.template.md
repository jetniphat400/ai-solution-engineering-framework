# Issue Register: [PROJECT OR SCOPE]

When to use which record: verified defects and bugs go here. Design
decisions and their tradeoffs go in an ADR
(`ai-engineering/templates/ADR.template.md`). The two never duplicate —
if a decision record starts listing a bug, or this register starts
arguing tradeoffs, move that content to the other document.

If an audit is producing more findings than fit comfortably as
individual issues here before they're formalized (register-scale, not
single-issue), see `ai-engineering/core/workflow.md`'s "Register-scale
audits" section for the ID-prefix, lane-rationale, and status-crosswalk
conventions that keep such a register from colliding with this one's
numbering — not restated here.

Severity is ranked by the impact of the wrong decision it causes, not
by how hard the fix is.

| ID | Title | Severity | Status | Phase |
|---|---|---|---|---|
| ISSUE-001 | [One-line description] | Critical \| High \| Medium \| Low | OPEN \| FIXED (commit [REF]) | [Phase] |

## ISSUE-001: [One-line title]

- Severity: Critical | High | Medium | Low
- Status: OPEN | FIXED (commit [REF])
- Assigned phase: [Phase]

### Evidence

[File:line references and the observed behavior]

### User-facing impact

[What a user or downstream system experiences because of this issue]
