# Reference: nine-phase workflow and Gates

Condensed from this framework's `ai-engineering/core/workflow.md`.
Read `SKILL.md` first — this file is the fuller version of its
"Gates" section and the phase structure implied throughout.

## Nine phases

1. **Intake and governance** — classify project state, change type,
   risk, trust, processing lane, permission profile, decision owners.
2. **User and project discovery** — understand user need, current
   process, evidence, constraints, project state. For existing
   systems: architecture, conventions, dependencies, tests, delivery,
   operational constraints.
3. **Problem definition and success criteria** — a testable problem
   contract: scope, non-scope, assumptions, measurable outcomes,
   acceptance criteria.
4. **Solution design and technology decision** — compare meaningful
   options, select the simplest design meeting user/security/
   reliability/maintainability/deployment needs, record major
   decisions in an ADR.
5. **Engineering plan and baseline** — break work into small vertical
   slices; identify files, interfaces, migrations, tests, risks,
   permissions, deployment, rollback, definition of done.
6. **Build in small batches** — implement one coherent slice, run
   focused checks, refactor, review the diff, checkpoint before
   continuing.
7. **Verify, red-team, and independently review** — deterministic
   checks, protect verification assets, challenge assumptions and
   failure modes, then a fresh-context review if available.
8. **Release and deploy** — a change record or PR, CI, risk-based
   approval, controlled deployment, smoke verification.
9. **Observe, learn, and improve** — verify health and user outcomes;
   roll back or contain failures; feed findings back into
   requirements, tests, architecture, and backlog.

## Return paths

- Wrong user need -> phase 2
- Ambiguous success criteria -> phase 3
- Invalid architecture -> phase 4
- Plan or baseline gap -> phase 5
- Implementation defect -> phase 6
- Verification or review failure -> phase 6 or phase 4
- Deployment failure -> rollback, then phase 5 or 6
- Production outcome failure -> phase 2 through 4

## Gates: investigation, study-only, decision

Use a Gate when a proposed action needs a dedicated look-before-you-leap
step distinct from the standard lane approval flow — typically because
the action is irreversible, the evidence is disputed, or the
"identical"/"safe"/"dead" claim behind it was inherited rather than
freshly derived (see `SKILL.md`'s claim-confidence section).

Each Gate type closes with one of `SKILL.md`'s terminal statuses
directly — a Gate does not invent its own vocabulary:

- **Investigation gate.** Investigate a claim or proposed action
  against current code — and real data, when money or scoring is
  involved — before doing anything else. Closes `DONE_VERIFIED`
  (confirmed and, if warranted, actioned; or confirmed as a non-issue)
  or `REPLAN_REQUIRED` (the claim didn't hold up and needs a fresh
  decision).
- **Study-only gate.** Gather evidence — a reusable script, a real-data
  comparison, a formal proof — without changing any code. Always
  closes `NEEDS_HUMAN`: it informs a decision, it never makes one.
- **Decision gate.** Make the actual call, using a study-only gate's
  evidence when one preceded it. Closes `DONE_VERIFIED` (approved and
  executed), `CONDITIONAL_PASS` (postponed or accepted with a caveat,
  scoped as its own named future item with a round/owner already
  assigned), or `REPLAN_REQUIRED` (no agreement reached; escalate). A
  decision that postpones something with no round/owner assigned isn't
  finished — use `SKILL.md`'s open-item convention instead.
