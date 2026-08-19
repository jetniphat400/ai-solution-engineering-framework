# AI Engineering Framework — Field Test #3: Campaign Closure and Enforcement Round

**Date:** 2026-08-19
**Tester:** the framework's own maintainer (this session, and — for the
PCC campaign material below — prior Claude Code sessions working under
this same framework). Not an independent or external tester; weigh
this evidence accordingly, same caveat as field tests #1 and #2.
**Target repo:** primarily `D:\PCC_invesment_source\PCC` (branch `dev`)
for the campaign-closure and Tier-3 material; secondarily this
framework's own repo for the Round 2 enforcement-checker material,
explicitly flagged where it applies rather than blended together.
**Framework source and version tested:** `v1.1.0` (this backlog cycle,
commits through `41afdec`)
**Install tier under test:** Full (PCC); N/A for the framework
repo's own self-testing
**Prior field tests this one can be compared against:** `docs/
field-tests/2026-07-31-pcc-pilot.md` (pilot #1, the v0.1->v0.2 install)
and `docs/field-tests/2026-08-19-pcc-pilot-2.md` (pilot #2, the
framework "in operation" — the same PCC campaign, but only through
2026-08-03; **this report covers what happened between 2026-08-03 and
2026-08-19, plus this session's own v1.1 work — it does not re-report
pilot #2's findings**, including the five re-verification incidents
[`R7`/`R35`-`R38`] pilot #2 already covered).

---

## 1. Scope

Two distinct bodies of work, reported together because both are direct
evidence for `BACKLOG-v1.1.md`'s "proof & enforcement" theme:

1. **PCC campaign closure (2026-08-03 -> 2026-08-19).** The remaining
   register items from the campaign pilot #2 reported mid-flight:
   frontend formatting consolidation (`R45`-`R48`), the framework's
   first real Tier-3 controlled-comparison execution (`R42`/`R43`), a
   terminal coverage sweep (24 characterization tests), and the
   campaign's own closeout (`docs/REFACTOR-REGISTER.md`). 58/58 items
   now carry a terminal status.
2. **This framework's own v1.1 Rounds 1-2 (this session).** Deriving
   and testing the `solution-engineer` zero-install skill, and building
   four mechanical enforcement checkers (`ai-engineering/checks/`)
   against both synthetic fixtures and PCC as a read-only real target.

A campaign closeout and a set of tool-development sessions are not the
same weight of evidence — the campaign is real production engineering
work; the checker-building is this framework auditing and mechanizing
itself. Both are reported, neither is inflated to look like the other.

---

## 2. Tier 1 — Outcome metrics (narrative only)

| Metric | Before (2026-08-03) | After (2026-08-19) |
|---|---|---|
| PCC backend test count | 179 (end of pilot #2's reporting window) | 219 |
| PCC backend test count, full campaign | 112 (2026-07-28 baseline) | 219 (net +107) |
| PCC register items with terminal status | 40/56 executed (per pilot #2) | 58/58 (100%, `DONE` or `DEFERRED`, none ambiguous) |
| Framework's own enforcement tooling | 0 checkers, 0 CI config | 4 checkers (`ai-engineering/checks/`), 1 CI example template |

> **This tier is narrative context only, never causal proof.** These
> numbers are confounded by model choice, skill/prompt version, and task
> difficulty — a higher test count or a faster session says nothing on its
> own about whether a *framework mechanism* caused it. Do not cite this
> table alone as evidence the framework works. See Tier 2.

---

## 3. Tier 2 — Incident log (required — the primary evidence standard)

| Mechanism | Incident | Counterfactual harm |
|---|---|---|
| Tier-3 pre-registration rule (`docs/field-tests/TEMPLATE.md` §4, applied for the first time) | PCC's `R42`/`R43` pair pre-registered "wall time, first commit -> last commit" as a metric; `R43`'s own pre-declared single-combined-commit shape made the metric degenerate to zero by construction (`docs/REFACTOR-REGISTER.md` line 259) — caught and recorded as a methodology finding because the pre-registration rule requires reporting the metric as pre-registered, not silently substituting a better-looking number | Without the pre-registration discipline, "0 minutes" could have been reported and read as "LIGHTWEIGHT was instant," a false causal claim, instead of a metric-definition mismatch |
| Same pre-registration rule, escaped-defects metric | `R42`/`R43`'s escaped-defects check came due at the campaign's own closeout with "only hours, not a real soak period" elapsed (`docs/REFACTOR-REGISTER.md` line 20) — the pre-registered "recheck later" framing forced this limitation to be stated rather than a bare "none found" being reported as clean | A bare "0 escaped defects" at closeout would have read as a real safety signal instead of "not enough time has passed to know" |
| Re-verification discipline applied to the original audit's own inventory claims (this framework's evidence-over-assumption principle, `verification.md`) | Frontend consolidation (`R45`-`R48`) re-inventoried all 4 items against current source before migrating anything and found the original audit's site-counts were stale: `fmt()` was actually 18 sites/7 behaviors, not "≥3"; `pnlClass` was 6 sites with a naming collision, not 3 (`docs/REFACTOR-REGISTER.md` line 50) | Migrating against the original, stale counts would have missed roughly 4x the actual `fmt()` call sites and the `pnlClass` naming collision entirely |
| Characterization-tests-first discipline (`ai-engineering/core/workflow.md`'s "build in small batches") | Writing characterization tests for `portfolio_history.py` (zero prior coverage, feeds the real-money equity curve) surfaced a test-isolation bug: `portfolio_history._cache` is a module-level dict that persists across test functions within one pytest process (`docs/REFACTOR-REGISTER.md` line 365) | Undetected test pollution could have made later tests pass or fail based on execution order rather than actual correctness — a real, if latent, coverage-sweep defect caught by the act of adding coverage, not by design |
| This framework's own `ai-engineering/checks/check-verification-report.sh`, tested against realistic fixtures (this session, v1.1 Round 2) | A bash `set -e` interaction silently aborted the checker before it reported anything, specifically on the *passing* (table-format) fixture, not a failing one — found because the fixture produced no output at all | A CI job wiring this checker in as a gate would have silently never run the check on every table-format report, reporting nothing rather than failing loudly — the worst failure mode for an enforcement tool |
| Same round, `check-verification-regression.sh`'s test-count extraction | Naive digit-stripping (`tr -dc '0-9'`) would have turned pytest's real `"219 tests collected in 5.10s"` into `"219510"` — caught only when run against PCC's real output, not any synthetic fixture, all of which used bare-number command output | A regression gate comparing against a corrupted baseline would either always pass (corrupted number inflated past any real count) or always false-flag (depending on which digits landed where) |

No entry above restates a pilot #2 incident (`R7`/`R35`-`R38`'s
re-verification findings) — those are already evidenced there.

---

## 4. Tier 3 — Controlled comparison (`R42`/`R43`, PCC's `docs/
REFACTOR-REGISTER.md` lines 238-263, transcribed)

**Pre-registration (filled in before either item ran, 2026-08-19):**

- **Metrics:** tests added, wall time (first commit -> last commit, by
  git timestamp), rework rounds, escaped defects (recheck at the next
  register-review pass).
- **Batch-pairing rule:** same repository/session/original audit pass
  (both under "Shared infrastructure"), same lane (`Standard`), same
  defect category (TTL-cache-dict boilerplate, no money-path or
  scoring semantics), overlapping file surface. **Disclosed asymmetry,
  not hidden:** the two are *not* size-matched — `R42` spans 6 call
  sites/5 files, `R43` spans 2 files — "a real-batch-of-convenience
  comparison, not a controlled experiment with size held constant."
- **Assignment rule, stated before either result was known:** the item
  with more call sites/files (an objective, already-on-record
  attribute) gets FULL discipline, since more touch points mean more
  chances for a regression to slip through reduced process. `R42`
  (6 sites/5 files) -> FULL. `R43` (2 files) -> LIGHTWEIGHT.

**Outcome:**

| Metric | `R42` (FULL) | `R43` (LIGHTWEIGHT) |
|---|---|---|
| Tests added | 14 | 2 |
| Wall time (first commit -> last) | 2m51s | **Not measurable as pre-registered** — `R43`'s own pre-declared single-combined-commit shape has no first-vs-last span; the metric degenerates to zero by construction, not because the work was instant. See this field test's Tier 2 entry above and this round's `TEMPLATE.md` refinement. |
| Rework rounds | 0 | 0 |
| Escaped defects | None found at the recheck — but only hours elapsed, not a real soak period; genuinely unknowable yet | Same caveat |

**Reading both arms together, honestly (quoting the register's own
framing):** "this is one pair, on one repo, on a same-day session... 
nothing... should be read as 'LIGHTWEIGHT is proven cheaper.'" Both
arms needed *some* new test coverage to credibly claim the fix worked;
what LIGHTWEIGHT actually cut was process/documentation overhead (one
commit, a short register note), not the minimum proof floor. Whether
this holds on a riskier or larger LIGHTWEIGHT item is not answered by
this single pair.

**Status:** Complete (one pair; not a basis for a general claim).

---

## 5. Friction findings

1. **A pre-existing mismatch between this framework's own stated
   policy and its shipped template went undetected until a mechanical
   checker was built against it.** `ai-engineering/core/
   verification.md`'s "Evidence format" states 5 fields (`Command or
   procedure` / `Result` / `Pass or fail` / `Evidence location` /
   `Remaining risk`); `ai-engineering/templates/
   VERIFICATION-REPORT.template.md`'s actual table had only 4 columns
   and was missing `Pass or fail` entirely. Neither pilot #1 nor pilot
   #2's prose-based review caught this — it surfaced only once Round
   2's checker had to parse the template literally. Fixed this round
   (`ai-engineering/templates/VERIFICATION-REPORT.template.md`), but
   the gap itself — that prose review can carry a template/policy
   drift for an unknown length of time without mechanization ever
   forcing the check — is the friction worth naming.
2. **The Tier-3 protocol's own metrics were underspecified on first
   real use.** Neither "wall time" nor "escaped defects" had a stated
   operationalization or measurement window before `R42`/`R43` ran —
   both gaps were discovered only by running a real pair, not by
   design review beforehand. Fixed this round in `docs/field-tests/
   TEMPLATE.md` (see Item 4, this round), but this is the second time
   in this framework's history (after pilot #1/#2's own friction
   findings) that a protocol's gaps were found only in first real use,
   not before it — worth naming as a recurring pattern, not a one-off.

---

## 6. Verdict

This field test establishes two things, at their real weight and no
more: (1) a completed, closed 58-item engineering campaign continued to
apply the framework's discipline consistently through its final two
weeks, including the framework's own first-ever Tier-3 controlled
comparison, which itself surfaced two real gaps in the Tier-3 protocol
that are now fixed; and (2) this framework's own newly-built mechanical
checkers (Round 2) caught two real, non-trivial implementation bugs the
moment they were run against realistic and real data, neither of which
any of the initial synthetic fixtures alone had caught.

What it does not establish: causal proof that the framework produces
better outcomes than not using it (Tier 1's own limitation, stated
above); any claim broader than "this one Tier-3 pair, on this one
repo, on one day" (Tier 3's own stated limitation); or anything about
this framework's portability across different coding agents — that is
`BACKLOG-v1.1.md` Item 11's question, not this field test's, and is
being tested separately this same round.
