# Nine-Phase Engineering Workflow

[design choice — rationale: the specific split into nine phases and their boundaries is this framework's own structure, not one named external model. The general lifecycle it's built from — intake through production feedback — is established practice, tagged per phase below.]

## 1. Intake and governance
Classify project state, change type, risk, trust, processing lane, permission profile, and decision owners. [established practice — SDLC intake/governance gate]

## 2. User and project discovery
Understand the user need, current process, evidence, constraints, and project state. For existing systems, inspect architecture, conventions, dependencies, tests, delivery, and operational constraints. [established practice — SDLC / DevOps discovery stage; the user-need framing also draws on Jobs-to-be-Done / 5-Whys]

## 3. Problem definition and success criteria
Create a testable problem contract with scope, non-scope, assumptions, measurable outcomes, and acceptance criteria. [established practice — SDLC requirements definition / Definition of Ready]

## 4. Solution design and technology decision
Compare meaningful options. Select the simplest design that meets user, security, reliability, maintainability, and deployment needs. Record major decisions in an ADR. [established practice — SDLC design phase; ADR, Nygard 2011]

## 5. Engineering plan and baseline
Break work into small vertical slices. Identify files, interfaces, migrations, tests, risks, permissions, deployment, rollback, and definition of done. [established practice — SDLC planning phase / small-batch planning, Agile / XP]

## 6. Build in small batches
Implement one coherent slice, run focused checks, refactor, review the diff, and create a checkpoint before continuing. [established practice — Agile / XP small batches]

## 7. Verify, red-team, and independently review
Run deterministic checks, protect verification assets, challenge assumptions and failure modes, then use a fresh-context reviewer. [established practice — TDD / Definition of Done, combined with independent-review practice]

## 8. Release and deploy
Use a change record or pull request, CI, risk-based approval, controlled deployment, and smoke verification. [established practice — SDLC release phase / continuous delivery, Humble & Farley]

## 9. Observe, learn, and improve
Verify health and user outcomes. Roll back or contain failures. Feed findings into requirements, tests, architecture, policies, and backlog. [established practice — SDLC / DevOps feedback loop]

## Return paths

[design choice — rationale: this framework's own explicit re-entry map from failure mode to phase; not part of a named external model]

- Wrong user need -> phase 2
- Ambiguous success criteria -> phase 3
- Invalid architecture -> phase 4
- Plan or baseline gap -> phase 5
- Implementation defect -> phase 6
- Verification or review failure -> phase 6 or phase 4
- Deployment failure -> rollback, then phase 5 or 6
- Production outcome failure -> phase 2 through 4

## Status legend for register-scale and Gate work

[design choice — rationale: one shared local-status legend for register-scale audits and Gates below, deliberately crosswalked to `AGENTS.md`'s terminal-status vocabulary rather than left as a parallel dialect, after pilot #2 (`docs/field-tests/2026-08-19-pcc-pilot-2.md` friction #5) found a register's own local legend never mapped back onto `AGENTS.md`'s mandated statuses]

Multi-item registers and Gates close each item or Gate with one of five local statuses:

- `DONE` — action taken (or investigation completed with nothing to fix) and verified.
- `NOT_STARTED` — not yet attempted; still needs scoping into a round.
- `DEFERRED` — investigated; a real decision was made to postpone or decline action, scoped as its own named future item.
- `NEEDS_DECISION` — evidence gathered (e.g. by a study-only Gate); a decision-owner's call is still pending.
- `CONTESTED` — an inherited claim failed re-verification, or two lines of evidence conflict; needs a fresh decision before it can close.

Crosswalk to `AGENTS.md`'s terminal-status vocabulary, used whenever a register closes out or a single Gate stands alone as the whole reported unit of work:

| Local status | `AGENTS.md` status |
|---|---|
| `DONE` | `DONE_VERIFIED` (or `CONDITIONAL_PASS` if shipped with a documented, approved caveat) |
| `NOT_STARTED` | `REPLAN_REQUIRED` |
| `DEFERRED` | `CONDITIONAL_PASS` if a round or owner is already assigned, else `NEEDS_HUMAN` |
| `NEEDS_DECISION` | `NEEDS_HUMAN` |
| `CONTESTED` | `REPLAN_REQUIRED` |

Every local status maps to exactly one `AGENTS.md` status — the two-branch rows (`DONE`, `DEFERRED`) are decidable from an observable fact (is a caveat documented? is an owner/round already assigned?), not left to per-instance judgment. `SECURITY_BLOCKED` and `ENVIRONMENT_UNAVAILABLE` have no per-item equivalent in this legend — they describe a whole-session blocker, not a per-item outcome, and apply directly at the register or Gate level when they occur.

**Tension reported, not forced:** pilot #2's own register used a single term, `OPEN`, for two distinct meanings — "not yet attempted" and "investigated, deliberately left as its own scoped future item" (e.g. its ten frontend-consolidation findings). Those two meanings need two different `AGENTS.md` targets (`REPLAN_REQUIRED` vs. `CONDITIONAL_PASS`/`NEEDS_HUMAN`), so a four-term legend reusing `OPEN` verbatim could not crosswalk cleanly onto `AGENTS.md`'s vocabulary. Splitting it into `NOT_STARTED` and `DEFERRED` above is the fix this friction required, not a cosmetic rename.

## Register-scale audits

[design choice — rationale: guidance for any audit producing more findings than fit comfortably as individual `ISSUES.md` entries, after pilot #2 (`docs/field-tests/2026-08-19-pcc-pilot-2.md` frictions #6-#7) found lane assignments couldn't be audited after the fact and an ad hoc numbering scheme collided with `ISSUES.md`'s own authoritative numbers]

For any register-scale (multi-finding) audit:

- Use a distinct ID prefix from the start (e.g. `R1`, `R2`, ...) — never bare numbers. `ISSUES.md` is the single verified issue register per `ai-engineering/templates/ISSUES.template.md`; a register's own numbering must never be able to collide with it.
- Record a one-line lane-assignment rationale per item, not just the `Lane:` tag itself, so classification consistency can be audited after the fact rather than only trusted on the strength of visibly different rigor across items.
- Close each item with one of the five local statuses above.
- At closeout, map the register's local statuses onto `AGENTS.md`'s terminal-status vocabulary per the crosswalk above, even though per-item tracking stays local throughout the work itself.

## Gates: investigation, study-only, decision

[design choice — rationale: names and templates a look-before-you-leap pattern invented ad hoc during pilot #2's campaign (`docs/field-tests/2026-08-19-pcc-pilot-2.md` friction #3) so the next large campaign doesn't have to reinvent it]

Use a Gate when a proposed action needs a dedicated look-before-you-leap step distinct from the standard lane approval flow in `ai-engineering/policies/processing-lanes.md` — typically because the action is irreversible, the evidence is disputed, or the "identical"/"safe"/"dead" claim behind it was inherited rather than freshly derived (see `verification.md`'s claim-confidence convention).

- **Investigation gate.** Investigate a claim or proposed action against current code — and real data, when money or scoring is involved — before doing anything else. Closes `DONE` (confirmed and, if warranted, actioned; or confirmed as a non-issue) or `CONTESTED` (the claim didn't hold up and needs a fresh decision).
- **Study-only gate.** Gather evidence — a reusable script, a real-data comparison, a formal proof — without changing any code. Always closes `NEEDS_DECISION`: it informs a decision, it never makes one.
- **Decision gate.** Make the actual call, using a study-only gate's evidence when one preceded it. Closes `DONE` (approved and executed), `DEFERRED` (rejected or postponed, scoped as its own named future item), or `CONTESTED` (no agreement reached; escalate).

A Gate's closing status is drawn from the same five-state legend defined above — a Gate does not invent its own vocabulary, and where a Gate is the whole reported unit of work rather than one item in a larger register, its closing status maps onto `AGENTS.md`'s terminal-status vocabulary via the same crosswalk.
