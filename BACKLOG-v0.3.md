# Backlog v0.3

## Origin

Seeded from post-Round-3b discussion, once the v0.2 backlog closed and
the installer, conflict matrix, and onboard modules had all been
proven against the field-test pilot. Not yet scoped into rounds —
these are the two items on the table, recorded before they're lost.

Items 3-6 below were added after reconciling
`docs/field-tests/2026-08-19-pcc-pilot-2.md` (pilot #2: v0.2 in
operation, the first full campaign run through `/engineer` after
install — 56 findings, 40 executed, three lanes, one continuous
session) against this backlog. Pilot #2's seven friction findings are
all about coordination and vocabulary gaps that only surface at
campaign scale, not about the install/distribution mechanics Items 1-2
cover — so none of the seven were already addressed by an existing
seed; all seven are absorbed below as four new items (frictions #1+#2
combine into Item 3, #3 stands alone as Item 4, #5+#6+#7 combine into
Item 5 since all three are large-register-vs-framework-contract
mismatches, and #4 stands alone as Item 6).

## Items

### Item 1 — Tiered adoption

**Problem:** The only install path today is the full clone-install
ceremony (Steps 1-3 in `SETUP.md`) — a single tier, always requiring a
target repo to receive a full `AGENTS.md` + `ai-engineering/` +
`.claude/` copy before the agent can apply any framework discipline at
all.

**Proposal:** Three tiers, one GitHub source of truth:

- **Zero-install** — a personal-level `/engineer` skill (installed
  once, at the user's own agent-config level, not per-repo) that
  carries the framework's discipline (classify, propose before
  acting, evidence over assumption) into any repo the user opens,
  even one with no framework contract present. If it finds no
  `AGENTS.md`/`ai-engineering/` in the current repo, it offers the
  light or full install rather than silently operating without one.
- **Light** — a single `AGENTS.md`, produced via `context-mapping.md`,
  in one prompt. No `ai-engineering/` or `.claude/` copy. For a repo
  that wants the contract but not the full module tree.
- **Full** — the current ceremony: clone the framework source,
  install (merge-safe, per the Round 3a fix), then the clone itself is
  disposable — delete it once installed, since GitHub remains the
  durable source of truth and a future upgrade re-clones rather than
  keeping a long-lived local copy around to drift.

**Open questions:** how the zero-install tier is actually packaged and
installed at the personal level (mechanism is adapter-specific and
not yet designed); how a repo already on the light tier upgrades to
full without re-running the entire setup flow from scratch.

**Status:** Light tier DONE (Round 3, Part A) — `SETUP.md` now documents
it as a full equal to Full install, built entirely from the existing
`context-mapping.md` module (no new module or route needed); the
light-to-full upgrade question above is answered by reusing
`setup-install.md`'s existing conflict matrix, not new plumbing.
Zero-install tier: a personal-skill draft was prototyped externally
and will be contributed through a normal PR once re-tested — the
`BACKLOG-v1.1.md` zero-install item stands on its own without that
draft landing. Full tier
itself (the clone-install-delete ceremony) is unchanged in substance,
now properly documented per Item 2 below.

### Item 2 — Distribution polish

**Problem:** `SETUP.md` documents manual copy and the installer
script, but not the clone-install-delete pattern Item 1's full tier
now treats as the norm — the source clone is disposable, but nothing
tells a new user that.

**Proposal:** Document the clone → install → delete flow in
`SETUP.md` as the recommended full-install path, explicit about the
"delete the clone" step so users don't mistake it for something that
needs to persist locally. Consider a direct-from-URL install
(fetching the framework source without a manual clone step at all) as
a later polish item — deferred until the framework has left pilot
status, since it adds a new distribution mechanism to secure and
maintain and isn't needed to prove the tiered-adoption model first.

**Status:** DONE (Round 3, Part A). `SETUP.md` now states the clone (Step
0) -> install (Steps 1-3) -> delete (Step 4) flow explicitly, with the
deletion step spelled out on its own rather than left implicit. The
direct-from-URL install idea remains deferred, unscoped, for the same
reason stated above.

### Item 3 — Confidence-label convention for claims in flight

**Source:** pilot #2 friction #1 + #2.

**Problem:** An unverified finding (a subagent's suspicion, a prior
audit's "these look identical" claim) can be restated as settled fact
across turns or sessions with no confidence tag attached, and nothing
in `/engineer`, `redteam`, or the verification contract requires a
claim to carry a confidence label as it moves from one agent's output
into a persisted document or a later turn. Pilot #2 hit this twice
independently — once as a repeat of pilot #1's friction #19
(`frontend/AGENTS.md` false alarm), and once as a standing pattern
where five inherited "identical" dedup claims in a row needed literal
re-verification and four of five turned out wrong or incomplete, with
no rule requiring the re-check in the first place.

**Proposal:** Define a confidence-label convention that travels with a
claim wherever it's persisted or restated (register entries, review
comments, findings docs), plus a standing rule that any inherited
audit/dedup/"identical" claim must be re-derived from current code —
and re-checked against real data when money or scoring is involved —
before it's acted on. Reuses the framework's existing `verified` /
`inferred` / `unknown` vocabulary (already defined in the `engineer`
skill's DETECT step) rather than inventing a new label set — caught
during Round 1, see "Lessons from Round 1" below.

**Size:** M — touches `ai-engineering/core/verification.md` and
`ai-engineering/core/redteam.md`, needs worked examples from both
field-test reports to anchor the convention.

**Status:** DONE (Round 1). `ai-engineering/core/verification.md` gained
a "Claim confidence labels" section anchored to pilot #2's evidence;
`ai-engineering/core/redteam.md`'s universal rule now requires the same
label on findings; `.claude/skills/engineer/SKILL.md` now references
`verification.md` as the canonical definition instead of restating it.

### Item 4 — Named Gate procedure

**Source:** pilot #2 friction #3.

**Problem:** The investigate → approve → study → decide pattern did
real, traceable work twice in pilot #2's campaign (an explicit
three-gate split for one item, and the same investigate-then-approve
shape reused for a five-item money-path batch) — but it has no name or
template anywhere in `ai-engineering/core/workflow.md` or the
`engineer`/`redteam` skills. It was invented fresh mid-campaign and
would have to be reinvented by the next one.

**Proposal:** Name and template the pattern in `workflow.md` —
"investigation gate," "study-only gate," "decision gate" — as a
reusable procedure for cases where a proposed action needs a
look-before-you-leap step distinct from the standard lane approval
flow.

**Size:** M.

**Status:** DONE (Round 2). `ai-engineering/core/workflow.md` gained a
"Gates: investigation, study-only, decision" section naming and
templating the pattern; its closing states are drawn from the same
five-state legend Item 5 defines, not a separate vocabulary.

### Item 5 — Large-audit register conventions

**Source:** pilot #2 friction #5 + #6 + #7.

**Problem:** Three gaps surfaced only once a single audit produced 56
findings across 40 executed items — a scale neither `AGENTS.md` nor
`ISSUES.template.md` was written for:

- The register's own local status legend (`DONE`/`OPEN`/`NEEDS
  DECISION`/`CONTESTED`) never maps back onto `AGENTS.md`'s mandated
  terminal-status vocabulary (`DONE_VERIFIED`, `CONDITIONAL_PASS`,
  etc.) anywhere in either document.
- Every finding carries a `Lane:` tag and Controlled-lane items
  visibly got extra approval-gate treatment, but no document records
  *how* each tag was assigned — so lane assignments can't be audited
  for consistency after the fact, only trusted on the strength of
  visibly different rigor.
- The register's original informal numbering (bare numbers) collided
  with `ISSUES.md`'s own authoritative issue numbers once five
  findings were formalized, forcing a full renumber onto a separate
  prefixed scheme to disambiguate.

**Proposal:** Add guidance, scoped to any register-scale (multi-finding)
audit, covering all three: use a distinct ID prefix from the start
(never bare numbers) to avoid colliding with `ISSUES.md`'s numbering;
require a one-line lane-assignment rationale per item; require a
closing summary that maps the register's local legend onto
`AGENTS.md`'s terminal-status vocabulary, even where per-item
tracking stays local.

**Size:** L — three related sub-asks, touches
`ai-engineering/core/workflow.md`, `ISSUES.template.md`, and the
"Completion status" section of `AGENTS.md`.

**Status:** DONE (Round 2). `ai-engineering/core/workflow.md` gained a
"Status legend for register-scale and Gate work" section (the shared
five-state legend and its crosswalk to `AGENTS.md`) and a
"Register-scale audits" section (ID-prefix rule, lane-rationale rule,
closeout mapping); `ISSUES.template.md` and `AGENTS.md`'s "Completion
status" section each gained a one-line cross-reference rather than a
restatement. See "Lessons from Round 2" for the `OPEN`-split tension
this required.

### Item 6 — Temporary security-bypass hygiene

**Source:** pilot #2 friction #4.

**Problem:** Pilot #2's campaign temporarily used a protected
auth-bypass flag as a verification tool (started servers with it set,
called live endpoints, then stopped the servers) — handled responsibly
this time, but entirely by ad hoc discipline. The framework names
auth-bypass flags as protected assets but has no stated rule for the
adjacent, very-likely-to-recur case: temporarily *using* such a flag
for verification rather than permanently changing it.

**Proposal:** Add a general rule to `ai-engineering/core/security.md`:
when verification requires temporarily disabling a security control,
state so explicitly in the verification evidence, restore the control
before ending the session, and never leave a server or process running
with it set.

**Size:** S.

**Status:** DONE (Round 1). New bullet in `ai-engineering/core/security.md`,
placed alongside the credential-isolation bullet.

## Round 1 — confidence labels + bypass hygiene

Closes Items 3 and 6 against pilot #2's frictions #1, #2, and #4.

- **Claim confidence labels (Item 3)** — new `## Claim confidence
  labels` section in `ai-engineering/core/verification.md`, promoting
  the `verified`/`inferred`/`unknown` vocabulary that previously only
  existed inside the `engineer` skill's DETECT step into a standing
  verification-contract rule: any claim inherited from a prior
  audit/pass starts at most `inferred` and must be re-derived from
  current code (and real data, for money/scoring paths) before being
  treated as `verified`. Anchored directly to pilot #2's evidence (the
  five-in-a-row re-verification record, and the `frontend/AGENTS.md`
  re-surfacing case shared with pilot #1 friction #19). **DONE.**
- **Redteam findings carry the same label (Item 3, cross-reference)** —
  `ai-engineering/core/redteam.md`'s universal rule now requires a
  confidence label alongside the existing file:line evidence
  requirement, pointing back at `verification.md` rather than
  restating the vocabulary. **DONE.**
- **Temporary security-bypass hygiene (Item 6)** — new bullet in
  `ai-engineering/core/security.md`: state explicitly in verification
  evidence when a security control is temporarily disabled, restore it
  before the session ends, never leave a server running with it set.
  **DONE.**

## Lessons from Round 1

- **In-round consistency fix, caught before it shipped:** Item 3's own
  seed text (written when this backlog was reconciled against pilot
  #2) proposed a fourth label, `flagged-not-verified`, without
  checking whether the framework already had a labeling convention. It
  does — `verified`/`inferred`/`unknown`, defined in
  `.claude/skills/engineer/SKILL.md`'s DETECT step and used by
  `context-mapping.md`. Fixed in Item 3's own text above, before
  implementation, to reuse the existing three labels rather than ship
  a fourth competing term.
- **The vocabulary was defined in the wrong layer.** `SKILL.md` is a
  Claude Code adapter file; `ai-engineering/core/verification.md` is
  the vendor-neutral core the adapter is supposed to draw from. The
  confidence-label convention had been defined only in the adapter,
  backwards from the framework's own layering — and that's exactly why
  no *core* rule required it for claims in general (audit/dedup
  findings, redteam findings), only for one skill's scenario/task
  detection. Moved the definition to `verification.md` and changed
  `SKILL.md` to reference it instead of restating it — the same
  delegate-instead-of-duplicate fix Round 3b applied to
  `setup-configure.md` -> `context-mapping.md`.

## Round 2 — Gate procedure + register conventions

Closes Items 4 and 5 against pilot #2's frictions #3, #6, and #7. Built
as one shared design, per the user's explicit instruction for this
round: a single five-state local-status legend (`DONE` /
`NOT_STARTED` / `DEFERRED` / `NEEDS_DECISION` / `CONTESTED`), used
identically by register items and by Gate closures, crosswalked onto
`AGENTS.md`'s seven terminal statuses — not three separate dialects.

- **Status legend for register-scale and Gate work (shared
  foundation)** — new section in `ai-engineering/core/workflow.md`
  defining the five local statuses and their crosswalk to `AGENTS.md`.
  `AGENTS.md`'s "Completion status" section now carries a one-line
  pointer to it instead of the crosswalk being restated there. **DONE.**
- **Register-scale audits (Item 5)** — new section in `workflow.md`:
  distinct ID prefixes from the start (never bare numbers, closing
  friction #7), a required one-line lane-assignment rationale per item
  (closing friction #6), and closeout mapping via the shared crosswalk
  (closing friction #5). `ISSUES.template.md` gained a one-line
  cross-reference to this section rather than a restatement. **DONE.**
- **Gates: investigation, study-only, decision (Item 4)** — new section
  in `workflow.md` naming and templating the pattern pilot #2 invented
  ad hoc (an explicit three-gate split for one finding, and the same
  investigate-then-approve shape reused for a five-item money-path
  batch). Each Gate type's closing states are drawn from the shared
  legend, not a new vocabulary. **DONE.**

## Lessons from Round 2

- **Tension found and resolved by design, not forced (per this round's
  explicit instruction):** pilot #2's own register used one term,
  `OPEN`, for two distinct meanings — "not yet attempted" and
  "investigated, deliberately left as its own scoped future item" (its
  ten frontend-consolidation findings, R42-R51, are the clearest
  example of the second sense). Those two meanings need two different
  `AGENTS.md` targets (`REPLAN_REQUIRED` vs.
  `CONDITIONAL_PASS`/`NEEDS_HUMAN`), so a legend that reused `OPEN`
  verbatim could not crosswalk cleanly onto `AGENTS.md`'s vocabulary no
  matter how the mapping table was written. The fix was to split
  `OPEN` into `NOT_STARTED` and `DEFERRED` — a real vocabulary change,
  not a cosmetic rename — reported here rather than silently picking
  one target and hoping it fit both senses.
- **Building the shared legend before either consuming item, same
  lesson Round 3b drew for `context-mapping.md`.** Item 4's Gate
  closing-states and Item 5's register closing-states were designed
  together as one section first, specifically so neither could drift
  into its own vocabulary — the ordering itself is what prevented a
  third dialect from appearing, not a later reconciliation pass.
- **Observed, deliberately not touched:** `REDTEAM-REPORT.template.md`'s
  release-recommendation vocabulary (`PASS | CONDITIONAL PASS | FAIL`)
  uses wording similar to `AGENTS.md`'s `CONDITIONAL_PASS`, but answers
  a different question (release-readiness verdict vs. task-completion
  status) — not the same crosswalk, and out of scope for this round.
