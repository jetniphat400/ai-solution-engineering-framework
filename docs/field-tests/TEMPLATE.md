# Field Test Template

[Use this template for any field test of this framework — a pilot install, a
task or campaign run under it, or a comparison against not using it. It
implements the three-tier evidence standard from `BACKLOG-v1.1.md` Item 6, so
results from different testers, on different repositories, are comparable
instead of one-off narratives. Delete this bracketed instruction block once
the report is filled in; keep the section headers.]

# [Framework Name/Version] Field Test [N]: [One-line description]

**Date:** [YYYY-MM-DD]
**Tester:** [Name/role — note explicitly whether the tester is one of the
framework's own authors/maintainers, since that affects how the evidence
below should be weighted]
**Target repo:** [path or identifier], branch [branch]
**Framework source and version tested:** [commit or tag]
**Install tier under test:** Full | Light | Zero-install
**Prior field tests this one can be compared against:** [list, or "none —
first test"]

---

## 1. Scope

[What was actually run: one task, a small batch, a full campaign. State
scope honestly — a single bug fix and a 50-item audit are not comparable
evidence at the same weight.]

---

## 2. Tier 1 — Outcome metrics (optional, narrative only)

[Aggregate numbers: test counts before/after, defects fixed, lines changed,
session duration. Fill in if available — it costs little and gives useful
context — but the banner below must stay attached to it.]

| Metric | Before | After |
|---|---|---|
| | | |

> **This tier is narrative context only, never causal proof.** These
> numbers are confounded by model choice, skill/prompt version, and task
> difficulty — a higher test count or a faster session says nothing on its
> own about whether a *framework mechanism* caused it. Do not cite this
> table alone as evidence the framework works. See Tier 2.

---

## 3. Tier 2 — Incident log (required — the primary evidence standard)

[This is the table that actually proves something. An entry only belongs
here if a *named* framework mechanism — a specific rule in
`ai-engineering/core/*.md`, a lane classification, a Gate, a redteam attack
surface, a protected-asset check — is the reason a defect or a false claim
did not ship. If nothing in the framework caught it, it doesn't go here,
even if the defect itself was interesting. "No incidents this test" is a
valid, honest entry — do not pad this table to make the tier look
productive.]

| Mechanism | Incident | Counterfactual harm |
|---|---|---|
| [Cite the specific rule, e.g. `verification.md`'s claim-confidence convention, or a named Gate type] | [What actually happened — cite file:line or a commit, the same way `docs/field-tests/*.md` cite their source documents] | [What would have shipped, or what would have been acted on, if this mechanism had not been in place — be concrete, not speculative] |

---

## 4. Tier 3 — Controlled comparison (protocol; fill in only once a real
run happens)

[Do not backfill this section from memory after the fact — if the metrics
below weren't defined before the two batches ran, this tier doesn't apply
to this test. Leave it marked "not run" rather than reconstructing a
before-the-fact appearance.]

**Pre-registration (must be filled in *before* either batch starts):**

- Metrics to be measured: [e.g. rework rounds, escaped defects found later,
  tests added — list exactly which, defined now, not after seeing results]
- Batch-pairing rule: [how two batches are judged "similar enough" to
  compare — same repository, comparable size/risk/domain; state the rule,
  not just the pair chosen]
- Which batch gets full framework discipline vs. lightweight/no discipline,
  and how that assignment was decided (ideally not hand-picked after the
  fact to favor one arm)

> **If "wall time" is one of the metrics, state its exact
> operationalization now** (e.g. "first commit timestamp -> last commit
> timestamp" vs. "task start -> first commit"), and check it against
> each arm's *pre-declared* commit shape before relying on it. A
> "first commit -> last commit" span silently degenerates to zero for
> whichever arm is pre-declared as a single combined commit — that is a
> mismatch in the metric's definition for that arm, not a finding that
> the arm was instant. (Found the hard way: a real Tier-3 pair pre-
> registered exactly this metric, and the LIGHTWEIGHT arm's own
> pre-declared single-commit shape made it unmeasurable by construction
> — recorded as a methodology finding rather than papered over, but
> avoidable by stating the operationalization and checking it against
> each arm's declared shape up front.)
>
> **If "escaped defects" is one of the metrics, pre-register *when* the
> check actually runs** — a stated interval ("recheck after N days") or
> a stated trigger ("recheck at the next session touching this area"),
> not just "later." An unspecified window makes a "none found" result
> at close time mean nothing: hours elapsed is not a soak period, and a
> reader can't tell the difference between "genuinely clean" and "not
> enough time has passed to know" unless the window was named in
> advance.

**Outcome (fill in after both batches complete):**

| Metric | Full-discipline batch | Lightweight batch |
|---|---|---|
| | | |

**Status:** Not run | In progress | Complete

---

## 5. Friction findings

[Numbered list, same format as prior field tests — one finding per gap in
the framework itself (missing rule, vocabulary mismatch, unclear
procedure), not per bug found in the target repo. Cite file:line evidence
for each.]

---

## 6. Verdict

[What this specific test does and does not establish — be as explicit
about the limits as about the findings. A single-tester, single-repo test
proves less than a multi-tester or multi-repo one; say so plainly rather
than letting the reader infer scope from the rest of the document.]
