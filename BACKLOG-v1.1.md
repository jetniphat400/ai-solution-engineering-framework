# Backlog v1.1

## Origin

Seeded immediately after `BACKLOG-v0.3.md` closed and v1.0.0 shipped.
Theme: **proof & enforcement**. Rather than import an external review,
this backlog was derived by reading the framework itself as its own
red-team target — a self-audit, dated 2026-08, asking three questions:

1. Which of the framework's rules depend entirely on an agent's
   voluntary compliance, and which could gain a mechanical check
   (a validation script, a CI-style gate, contract linting)?
2. What outcome evidence actually exists for the framework's claims?
   The two field tests in `docs/field-tests/` are the entire evidence
   base — what do they prove, what do they not, and what would real
   proof require?
3. Where does the framework overclaim relative to what's actually
   shipped?

Items 1-7 below come from that self-audit and carry the provenance tag
`self-audit 2026-08`. Items 8-10 were already agreed going into this
round: a distribution item graduating from a `v0.3` deferral, a new
policy dimension for unattended/looped execution, and the zero-install
tier carried over, unscoped, from `BACKLOG-v0.3.md`'s original seed.
None of these ten restate a `v0.3` item — `v0.3`'s own items (adoption
tiers, distribution, confidence labels, the Gate procedure, register
conventions, security-bypass hygiene) are all closed; see
`CHANGELOG.md`'s `1.0.0` entry.

The self-audit's own method is worth naming as a limitation up front:
it was performed by reading the repository, not by running it against
an external target, and by the same kind of process (an agent reading
its own governing documents) the framework asks its users to trust —
Item 6 below exists partly to close that exact gap for future audits.

## Items

### Item 1 — Verification and completion-status evidence linting

**Provenance:** self-audit 2026-08 (sub-question 1).

**Problem:** `ai-engineering/core/verification.md`'s fixed evidence
format (lines 26-38: Command/Result/Pass-or-fail/Evidence
location/Remaining risk) and `AGENTS.md`'s "Completion status" section
(lines 117-127, "End with exactly one status and the evidence
supporting it") both require an agent to self-report evidence — but
nothing anywhere checks that a report actually has all five fields
present and non-empty, or that a claimed `DONE_VERIFIED` cites anything
real. This is pure voluntary compliance for the framework's single most
load-bearing claim: that work was actually verified.

**Proposal:** A lightweight validation script (e.g.
`scripts/check-verification-report.sh`/`.ps1`) that greps a
`VERIFICATION-REPORT.md`-shaped file for the five required field
headers and flags any that are missing or empty. Not semantic
verification — it cannot tell whether the evidence is *true* — but it
closes the cheaper, more common failure: a field silently left blank.

**Size:** M.

**Status:** `DONE` -> crosswalk `DONE_VERIFIED`. Shipped:
`ai-engineering/checks/check-verification-report.sh`/`.ps1`. Also fixed
a pre-existing mismatch between `verification.md`'s stated 5-field
format and `VERIFICATION-REPORT.template.md`'s actual 4-column table
(missing `Pass or fail`), found while building this checker, not
before. Full evidence: `ai-engineering/checks/TEST-EVIDENCE.md`.

### Item 2 — Protected-path change detection

**Provenance:** self-audit 2026-08 (sub-question 1).

**Problem:** `AGENTS.md`'s "Protected assets" section (lines 85-95:
acceptance/security tests, golden fixtures, CI/CD workflows, production
configuration, migration recovery, secret stores) states these must
not change without explicit human approval — but nothing technically
blocks such an edit, and the project-specific "Protected paths" field
this section depends on (`AGENTS.md`'s "Project-specific protected
paths" block) is itself commonly left as an unfilled `[ADD PATHS]`
placeholder, meaning even when the rule is followed it's often
following an empty list.

**Proposal:** A pre-commit hook or CI check template (shipped under
`ai-engineering/templates/` or `scripts/`) that diffs staged/changed
files against a project's own filled-in protected-paths list and
blocks or warns before commit. First mechanical backstop for a rule
that today is prose-only; ships as an optional template, since
protected paths are necessarily project-specific. (Shipped under
`ai-engineering/checks/` instead of either originally-named location —
this rides along with `ai-engineering/**`'s existing wholesale copy to
Full-tier targets with zero installer changes, which `scripts/` does
not get.)

**Size:** M.

**Status:** `DONE` -> crosswalk `DONE_VERIFIED`. Shipped:
`ai-engineering/checks/check-protected-paths.sh`/`.ps1`. Full evidence,
including real-history detection accuracy against a PCC commit that
touched a protected path: `ai-engineering/checks/TEST-EVIDENCE.md`.

### Item 3 — CI regression-gate template for verification manipulation

**Provenance:** self-audit 2026-08 (sub-question 1).

**Problem:** `verification.md`'s "Prohibited verification manipulation"
(lines 50-54) names exactly the class of thing a diff-based check can
catch mechanically — deleted failing tests, weakened assertions,
lowered thresholds, disabled lint or security rules — but this
repository ships **zero** CI configuration of any kind. Confirmed:
`find . -iname "*.yml" -o -iname "*.yaml"` returns nothing, and
`scripts/` contains only the two install scripts, no test or lint
tooling. A framework whose verification contract explicitly names
CI-gateable failure modes provides no CI gate, reference or otherwise.

**Proposal:** A reference CI workflow template (e.g. a sample GitHub
Actions workflow under `ai-engineering/templates/`) that fails a PR
when test count decreases or a lint/security rule gets disabled in the
diff — offered as an optional, adaptable starting point. Stays
consistent with the framework's project-agnostic principle: ships a
template, not a mandated pipeline baked into every install.

**Size:** L — real design work, and care needed to keep it a template
rather than a hardcoded assumption about any project's toolchain.

**Status:** `DONE` -> crosswalk `DONE_VERIFIED`. Shipped:
`ai-engineering/checks/check-verification-regression.sh`/`.ps1` (the
portable, CI-agnostic mechanism) plus `ai-engineering/templates/
ci-regression-gate.example.yml` (one concrete GitHub-Actions-flavored
wrapper, clearly labeled as swappable). Ships two heuristics (test-
count regression, suppression-comment/assertion-removal detection); a
third (decreasing numeric thresholds near keywords like "coverage")
was scoped out as too complex/false-positive-prone for a first version
— a real scoping decision, not a silent drop. Full evidence, including
a test-count cross-check against PCC's real suite that matched
`docs/REFACTOR-REGISTER.md`'s own recorded figure exactly:
`ai-engineering/checks/TEST-EVIDENCE.md`.

### Item 4 — Skill supply-chain pinning has no mechanical enforcement

**Provenance:** self-audit 2026-08 (sub-question 1).

**Problem:** `ai-engineering/policies/skill-supply-chain.md`'s
"Allowlist registry" (lines 36-42) is a literal empty table row in a
policy document — `| | | | | |` — with zero technical connection to
`.claude/settings.json`'s actual permission engine. `.claude/
settings.json` today only mechanically enforces `permissions.deny`
read-path rules (confirmed: `.claude/settings.json` lines 3-10, six
`Read(...)` deny patterns); it has no concept of a pinned skill commit
or an allowlist entry. Nothing technically stops loading a skill that
was never added to the registry, or one whose pinned commit has since
moved.

**Proposal:** Scoped narrowly, since full runtime hash-checking of a
loaded skill is likely adapter-specific and may not be buildable today:
add a recorded pinned-commit verification step to `setup-configure.md`
(or a standalone periodic-audit reminder) that makes the gap visible
and auditable, rather than promising enforcement the framework can't
yet deliver. (Executed as a standalone visibility check rather than a
`setup-configure.md` step, since it's equally useful run anytime, not
only during install — see Status below.)

**Size:** S.

**Status:** `DONE` -> crosswalk `DONE_VERIFIED`. Shipped:
`ai-engineering/checks/check-skill-allowlist.sh`/`.ps1` — advisory
only, scope limited to `.claude/skills/` (not plugins or MCP servers,
per this item's own proposal). Full evidence, including a true
positive against PCC's real, currently-unregistered `analyze-stock`
skill: `ai-engineering/checks/TEST-EVIDENCE.md`.

### Item 5 — Evidence-and-limitations statement

**Provenance:** self-audit 2026-08 (sub-question 2).

**Problem:** The framework's entire outcome evidence is two field
tests (`docs/field-tests/2026-07-31-pcc-pilot.md`,
`docs/field-tests/2026-08-19-pcc-pilot-2.md`), both against the same
target repository, both self-administered by the people who designed
the framework — n=2, no control, no blind assessment, no independent
replication, no quantitative before/after metric. Neither `README.md`
nor `SETUP.md` states this limitation anywhere; both present the
framework's capabilities without qualifying the evidence behind them.

**Proposal:** Add a short, factual "Evidence and limitations"
statement (in `README.md` or a new `docs/EVIDENCE.md`) naming exactly
what the two field tests do and don't establish, so a reader isn't
misled about the framework's actual maturity.

**Size:** S.

### Item 6 — Metrics definition and a reusable field-test template

**Provenance:** self-audit 2026-08 (sub-question 2).

**Problem:** No document anywhere defines what "the framework works"
would mean quantitatively — there is no metrics definition, no success
criteria a pilot could be scored against. The two existing field-test
reports are hand-authored free-form narratives with no shared
template; a third tester, especially one external to this project (a
different team, a repo the framework's authors didn't build), has
nothing to fill in that would produce a result comparable to the first
two. Self-administered, self-graded evidence is also the self-audit's
own limitation (see "Origin" above) — this item is how a future audit,
by anyone, stops being self-graded.

**Proposal:** A three-tier evidence standard, not a flat metrics list —
graded by how much a metric actually proves:

- **Tier 1 (outcome metrics)** — test counts, bugs fixed, and similar
  aggregate numbers. Narrative value only: confounded by model, skill,
  and task variance across sessions, so never citable as causal proof
  that the framework itself caused the outcome.
- **Tier 2 (incident log) — the primary evidence standard.** Recorded
  instances where a *named* framework mechanism (a specific rule in
  `verification.md`, `redteam.md`, `workflow.md`, etc.) caught a defect
  or false claim that would otherwise have shipped. Each entry records
  the mechanism, the incident, and the counterfactual harm — what would
  have happened without it. This is the format a field-test template
  must implement as its core, required table; Tier 1 and Tier 3 support
  it but don't replace it.
- **Tier 3 (controlled comparison)** — for similar task batches, run one
  through full framework discipline and a matched one lightweight;
  metrics (rework rounds, escaped defects, tests added) are pre-defined
  *before* running either batch, never chosen after seeing results.
  This item designs the protocol (pre-registration rules, batch-pairing
  rules); first execution piggybacks on a real work batch in the pilot
  repo rather than a staged exercise.

Implemented as `docs/field-tests/TEMPLATE.md` — alongside the field-test
reports it standardizes, not `ai-engineering/templates/` (this item's
own original proposal named that path; corrected here to match where
it actually shipped, since a template for evidence *about* the
framework belongs with the evidence itself, not the engineering
artifacts the framework produces for a target project).

**Size:** L.

**Status:** Design and template `DONE` (v1.1 Round 1) — see
`docs/field-tests/TEMPLATE.md`. Tier 3's first real execution is
`NOT_STARTED`, depending on a future real work batch in the pilot repo.

### Item 7 — "AI-agnostic" claim outruns the shipped adapters

**Provenance:** self-audit 2026-08 (sub-question 3).

**Problem:** `README.md:1` titles the project "AI-Agnostic
User-Centered Solution Engineering Framework," and `README.md:3` calls
it "a portable engineering baseline for Claude Code, OpenAI Codex, and
future coding agents." But the two named adapters are not remotely at
parity: `ai-engineering/adapters/claude/README.md` points at a fully
built adapter — 7 modules, 3 skills, an agent definition, real
mechanically-enforced deny rules — while the entirety of
`ai-engineering/adapters/codex/README.md` is 12 lines stating Codex
reads `AGENTS.md` natively plus one recommended prompt. No
Codex-specific skill, routing, onboarding module, or Gate procedure
exists. "Future coding agents" names zero adapters, planned or
evidenced.

**Proposal:** A fork, not a decision made here: either invest in
genuine Codex-adapter parity — noting Codex has no skill-loading
mechanism to hang custom modules off of today, which may be a real
technical constraint rather than an oversight — or soften `README.md`'s
framing to match what's actually shipped (e.g., "a vendor-neutral core
[`AGENTS.md`, `ai-engineering/`] with a full Claude Code adapter;
Codex support today is native-`AGENTS.md`-only").

**Size:** M.

### Item 8 — Direct-from-URL install

**Provenance:** pre-agreed, graduating from `BACKLOG-v0.3.md`'s Item 2,
whose proposal text (line 80) named this "a later polish item —
deferred until the framework has left pilot status." `v1.0.0` shipping
this round is exactly that trigger.

**Problem:** Both install tiers (`SETUP.md`'s Full and Light) start
with a manual `git clone` of the framework source. There is no
direct-from-URL mechanism (fetching the framework source without a
manual clone step).

**Proposal:** Design and ship a direct-from-URL install path — the
exact mechanism (a fetch script, a release-archive download, etc.) is
not yet decided; this item is to design and evaluate options, not
prescribe one.

**Size:** M.

### Item 9 — Unattended execution profile: lanes as loop stopping conditions

**Provenance:** pre-agreed. Motivation: the external coding-agent
landscape as of August 2026 increasingly supports unattended,
multi-iteration execution (scheduled runs, loops); text below is kept
project- and vendor-agnostic.

**Problem:** `ai-engineering/policies/processing-lanes.md` governs
approval gates and rigor per lane, but says nothing about how a lane
should bound *unattended*, multi-iteration execution. Nothing in the
framework today distinguishes "safe to let run without a human present
for N iterations" from "must stop and ask every time," even though the
three lanes already encode exactly this kind of risk gradient for
single-shot work.

**Proposal:** Map each lane to a loop stopping condition:

- **Fast** — loop freely; each iteration is small, clear, reversible,
  and already meets Fast Lane's existing bar.
- **Standard** — loop while verification keeps passing; halt on the
  first verification failure or ambiguity for human input.
- **Controlled** — never loop unattended; halt for human confirmation
  before every iteration, same as its existing single-shot requirement.

Scope of this item is exactly two deliverables: the mapping above, and
a definition of what a "loop-runnable verification gate" requires
(a deterministic pass/fail signal, bounded runtime, no reliance on the
same interactive judgment calls a human would otherwise make) —
without which "Standard loops while verification passes" isn't
actually checkable unattended.

**Size:** L.

### Item 10 — Zero-install tier

**Provenance:** carried over, unscoped, from `BACKLOG-v0.3.md`'s
original Item 1 (its zero-install sub-tier, descoped when Light tier
shipped in Round 3 — see `BACKLOG-v0.3.md`'s Item 1 status note).

**Problem:** Both current tiers (Full, Light) are per-repo — nothing
installs the framework's discipline once, at the user's own
agent-config level, such that it applies to any repo the user opens,
even one with no `AGENTS.md`/`ai-engineering/` present at all.

**Proposal:** A personal-level `/engineer`-equivalent skill, installed
once outside any project, that carries the framework's discipline
(classify, propose before acting, evidence over assumption) into any
repo the user opens. If it finds no `AGENTS.md`/`ai-engineering/` in
the current repo, it offers the Light or Full install rather than
silently operating without a contract; if it finds one already present,
it defers to it. (The externally-prototyped draft this proposal
originally referenced was confirmed absent from this machine during
the Round 1 re-test attempt below, and was not reconstructed. This item
was instead executed as a fresh derivation directly from this repo's
v1.0 canon — see "Execution" below — with the external review's design
constraints preserved via this session's own instructions, not via the
lost file.)

**Size:** L — mechanism is inherently adapter-specific (how a
personal-level skill is packaged and installed varies by coding agent)
and not yet designed, per `BACKLOG-v0.3.md`'s original open question.

**Status:** Assigned to v1.1 Round 1. Owner: maintainer. Closes the
open follow-up `BACKLOG-v0.3.md`'s cycle closeout named against this
item — see that file's "Cycle closeout" section, updated to
`CONDITIONAL_PASS` accordingly.

**Re-test attempt, v1.1 Round 1 (2026-08):** the externally-prototyped
draft this item's Proposal references was searched for on the machine
running this session — `~/.claude/skills` (does not exist as a
directory at all), `~/.agents/skills` (exists; contains only
`find-skills` and `hallmark`, neither of which is it), and a broader
home-directory search for anything named `*solution-engineer*` (no
matches). The draft is not present here. Per this item's own
instruction for that outcome, it was not reconstructed — no mock-repo
scenarios were invented or run, and nothing was added under any
zero-install path this round. The Round 1 assignment and owner above
still stand, but the item's actual completion is now contingent on the
draft being supplied from wherever it was actually prototyped, or on
building the tier fresh without it — reported plainly rather than
marked complete or silently dropped.

**Execution, v1.1 Round 1 (2026-08):** built fresh from this repo's own
canon rather than waiting on the missing draft. Every behavior in
`personal-skills/solution-engineer/SKILL.md` traces to a cited file in
this repo (see that file's own "Provenance" section); four requirements
with no direct canon precedent (numeric Fast-lane thresholds,
non-waivable status honesty under user overrides, mid-task
reclassification, monorepo scoping) are flagged there as this skill's
own explicit extensions rather than presented as pre-existing rules.
The external review's design constraints were preserved via this
session's own instructions restating them, not via the lost draft file
itself.

Tested against 4 scratch-repo scenarios by fresh, context-free
subagents before shipping — trivial change, an urgent request hiding a
real risk, a prompt injection embedded in repository content, and a
target with its own Light-tier `AGENTS.md` already present. **4/4
PASS**, no fix-and-retry needed. Full evidence: `personal-skills/
solution-engineer/TEST-EVIDENCE.md`.

Shipped: `personal-skills/solution-engineer/` (skill + references +
test evidence); `SETUP.md` documents it as the third tier alongside
Full and Light, including the degradation rule and a pointer to the
test evidence.

**Status:** `DONE` -> crosswalk `DONE_VERIFIED`.

### Item 11 — Cross-agent contract test

**Provenance:** planning session 2026-08.

**Problem:** The framework claims cross-agent portability — even after
last round's softened `README.md` tagline, it still names a real
Claude Code adapter alongside Codex's native-`AGENTS.md` support — but
this has never actually been exercised through more than one coding
agent. Both existing field tests (`docs/field-tests/*.md`) are Claude
Code sessions; the Codex adapter (flagged as thin in Item 7) has zero
recorded executions of any kind.

**Proposal:** Run the identical `AGENTS.md` contract and an identical
small task set through two different coding agents — Claude Code plus
one non-Anthropic agent (e.g. GitHub Copilot or OpenAI Codex) — against
the same scratch repository. Compare across the two runs: lane
classification, evidence discipline, status-vocabulary compliance, and
tension reporting. This is the first real test of the "AI-agnostic"
claim (structural inspection only got as far as Item 7's fork), and
its results feed directly into deciding which branch of that fork to
take.

**Size:** M.

**Status (items 5, 7, 8, 9, 11 above):** Open, not yet scoped into a
round. (Items 1-4 closed in Round 2 — see each item's own Status
above.)
