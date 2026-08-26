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

## Open items and terminal statuses for register-scale and Gate work

[design choice — rationale: the local five-state legend and crosswalk table this section used to define were retired 2026-08-26 after the crosswalk was found never followed in practice for its `NOT_STARTED` row, and the local set was found to carry no distinction `AGENTS.md`'s terminal set can't express — see `docs/field-tests/2026-08-26-status-vocabulary-study.md` for the study and decision, and `CHANGELOG.md` for which files predate the change and still use the retired vocabulary]

`AGENTS.md`'s terminal statuses describe **finished** work only.
Multi-item registers and Gates close each finished item with one of
those statuses directly — no separate local vocabulary, no crosswalk
step.

An **unfinished** item carries no status term. Write it in prose:

- `Status: open — scheduled <round/owner>` — a round or owner is
  already assigned.
- `Status: open — unscheduled` — neither is assigned yet.

Do not invent a replacement term for in-progress state. This is
deliberate, not an oversight.

## Register-scale audits

[design choice — rationale: guidance for any audit producing more findings than fit comfortably as individual `ISSUES.md` entries, after pilot #2 (`docs/field-tests/2026-08-19-pcc-pilot-2.md` frictions #6-#7) found lane assignments couldn't be audited after the fact and an ad hoc numbering scheme collided with `ISSUES.md`'s own authoritative numbers]

For any register-scale (multi-finding) audit:

- Use a distinct ID prefix from the start (e.g. `R1`, `R2`, ...) — never bare numbers. `ISSUES.md` is the single verified issue register per `ai-engineering/templates/ISSUES.template.md`; a register's own numbering must never be able to collide with it.
- Record a one-line lane-assignment rationale per item, not just the `Lane:` tag itself, so classification consistency can be audited after the fact rather than only trusted on the strength of visibly different rigor across items.
- Close each finished item with one of `AGENTS.md`'s terminal statuses directly; an unfinished item uses the open-item convention above instead.

## Gates: investigation, study-only, decision

[design choice — rationale: names and templates a look-before-you-leap pattern invented ad hoc during pilot #2's campaign (`docs/field-tests/2026-08-19-pcc-pilot-2.md` friction #3) so the next large campaign doesn't have to reinvent it]

Use a Gate when a proposed action needs a dedicated look-before-you-leap step distinct from the standard lane approval flow in `ai-engineering/policies/processing-lanes.md` — typically because the action is irreversible, the evidence is disputed, or the "identical"/"safe"/"dead" claim behind it was inherited rather than freshly derived (see `verification.md`'s claim-confidence convention).

Each Gate type closes with one of `AGENTS.md`'s terminal statuses directly — a Gate does not invent its own vocabulary:

- **Investigation gate.** Investigate a claim or proposed action against current code — and real data, when money or scoring is involved — before doing anything else. Closes `DONE_VERIFIED` (confirmed and, if warranted, actioned; or confirmed as a non-issue) or `REPLAN_REQUIRED` (the claim didn't hold up and needs a fresh decision).
- **Study-only gate.** Gather evidence — a reusable script, a real-data comparison, a formal proof — without changing any code. Always closes `NEEDS_HUMAN`: it informs a decision, it never makes one.
- **Decision gate.** Make the actual call, using a study-only gate's evidence when one preceded it. Closes `DONE_VERIFIED` (approved and executed), `CONDITIONAL_PASS` (postponed or accepted with a caveat, scoped as its own named future item with a round/owner already assigned), or `REPLAN_REQUIRED` (no agreement reached; escalate). A decision that postpones something with no round/owner assigned yet isn't finished — use the open-item convention above, not a terminal status.
