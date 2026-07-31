# Module: onboard-inherited

Distilled playbook for joining an existing codebase with unknown or
undocumented history: no reliable narrative of how it got this way,
possibly no tests, possibly no working environment. Generic by
design — the specific facts of any one inherited codebase never
belong in this file, only the procedure for discovering them safely.

## Parameters

- `{TargetPath}` — the inherited codebase.

## Procedure

Eight steps, run in order. Each step names what it produces and the
status that closes it; a step producing anything other than its
"done" status blocks the next step until resolved.

### 1. Preflight before touching anything

Route to `setup-preflight.md`'s target-inspection step before any
edit. Expect `UPGRADE` or `PARTIAL_PREVIOUS_INSTALL` verdicts to be
the common case here, not the exception — an inherited codebase
rarely arrives as a clean `FRESH_INSTALL`.

- Produces: the `{InstallVerdict}` and a confirmed git-tree status.
- Status: whatever `setup-preflight.md` returns; do not proceed past
  `NEEDS_HUMAN` or `ENVIRONMENT_UNAVAILABLE`.

### 2. Git baseline "as received"

Before any change, establish a restorable point. If no repository
exists, create one and commit the code exactly as received. Nothing
gets edited before this baseline exists — it is the rollback anchor
for every step that follows.

- Produces: a baseline commit (and `git init` if needed).
- Status: `DONE_VERIFIED` once the baseline commit exists and the
  tree is otherwise clean; `NEEDS_HUMAN` if creating one requires a
  decision only the user can make (e.g. what to exclude).

### 3. RUN-FIRST

Get the software running and observe it before deep-reading its
logic. [design choice — pilot-validated: a prior field pilot found
that running software is faster to comprehend than static reading,
exercises the real environment (surfacing setup and dependency
problems reading alone would miss), and surfaces visible defects that
help prioritize which code to read next. Treat running before reading
as the default order for this step, not an optional shortcut.]

**Escape hatch:** if the software cannot be made to run within a
short, explicitly-timeboxed effort, stop attempting it. Record every
blocker encountered as a finding in the issue register (step 5) and
fall back to static reading for this pass. Do not let onboarding sink
into open-ended environment archaeology — a blocked run is itself a
finding, not a failure to escalate silently past.

- Produces: either a running-system observation log, or (via the
  escape hatch) a recorded set of blocking findings plus a note that
  this pass fell back to static reading.
- Status: `DONE_VERIFIED` (ran and observed) or `CONDITIONAL_PASS`
  (escape hatch used, blockers recorded, proceeding via static
  reading).

### 4. Documentation is claims, not facts

Treat every README, comment, architecture doc, and prior status report
as an unverified claim about the code, not a fact about it. Check each
material claim against the code it describes before relying on it.
Record drift (a claim contradicted by the code) as a finding, not as
a documentation-fix task performed silently in passing.

- Produces: a claims-vs-code drift list, feeding the issue register.
- Status: `DONE_VERIFIED` (claims checked, drift recorded) or
  `CONDITIONAL_PASS` (some claims not yet checkable — say which and
  why).

### 5. Establish the verified issue register

Initialize `ai-engineering/templates/ISSUES.template.md` as the single
record of verified defects from this point forward — before repair
starts, not after. Every finding from steps 3 and 4, and everything
found from here on, lands here with evidence, not in scattered notes
or commit messages alone. Design decisions still go in an ADR, never
in this register — see the register's own precedence rule.

- Produces: an initialized issue register with at least the step 3/4
  findings recorded.
- Status: `DONE_VERIFIED` once the register exists and captures the
  findings so far.

### 6. Locate and fence real-risk paths first

Before general exploration, actively search for paths with real
(non-synthetic) consequences: money movement, external side-effects
(emails sent, third-party API calls, physical actions), credential
handling, and data-destructive operations. Fence them — flag them as
requiring explicit human approval and Controlled Lane treatment per
`ai-engineering/policies/risk-classification.md` and
`processing-lanes.md` — before touching anything nearby, and before
they can be triggered accidentally by exploratory runs in step 3.

- Produces: a fenced real-risk-path list, cross-referenced into the
  issue register and `AGENTS.md`'s protected-paths field (via
  `context-mapping.md`).
- Status: `DONE_VERIFIED` (search done, paths fenced) or `NEEDS_HUMAN`
  (a found path's risk tier is ambiguous).

### 7. Repair in small batches, test-first

Work each issue-register entry as its own small, reviewable batch:
write or confirm a failing test that reproduces the defect, fix it,
verify, checkpoint. Every claim of "fixed" carries evidence per
`ai-engineering/core/verification.md`'s evidence format, cited against
the specific issue-register entry it closes.

- Produces: one commit (or small commit series) per batch, each with
  verification evidence and an updated issue-register status
  (`OPEN` -> `FIXED`, commit reference attached).
- Status: `DONE_VERIFIED` per batch; `REPLAN_REQUIRED` if a batch
  reveals the fix is larger than scoped.

### 8. Exit gate: independent verification

Before declaring the codebase's behavior or reported numbers
trustworthy, verify them against a source outside the codebase itself
— an external record, a second implementation, a domain expert, or
equivalent — not just the codebase's own tests re-run. Route to
`independent-reviewer` for a fresh-context check per
`ai-engineering/core/workflow.md` phase 7.

- Produces: an independent verification record, separate from the
  batch-level evidence in step 7.
- Status: `DONE_VERIFIED` (independently confirmed), `CONDITIONAL_PASS`
  (confirmed with noted residual risk), or `NEEDS_HUMAN` (no
  independent source was available to check against).

## Completion

The module as a whole ends `DONE_VERIFIED` only once all eight steps
have closed at `DONE_VERIFIED` or an accepted `CONDITIONAL_PASS`.
Otherwise report the step it stalled on and that step's own status.
