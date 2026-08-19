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
protected paths are necessarily project-specific.

**Size:** M.

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
yet deliver.

**Size:** S.

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

**Proposal:** Define a small set of adoption/effectiveness metrics
(e.g., percentage of completed tasks with all five verification-
evidence fields present, percentage of Controlled-lane changes with a
recorded pre-diff approval, friction-findings-per-session as a leading
indicator) and add `ai-engineering/templates/
FIELD-TEST-REPORT.template.md` so future pilots — particularly ones
run by people other than this framework's authors, on repositories
they didn't build — produce comparable, citable evidence instead of a
one-off narrative.

**Size:** L.

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
silently operating without a contract. A personal-skill draft was
prototyped externally and will be contributed through a normal PR once
re-tested — this item stands on its own and does not depend on that
draft landing.

**Size:** L — mechanism is inherently adapter-specific (how a
personal-level skill is packaged and installed varies by coding agent)
and not yet designed, per `BACKLOG-v0.3.md`'s original open question.

**Status:** Assigned to v1.1 Round 1. Owner: maintainer. Closes the
open follow-up `BACKLOG-v0.3.md`'s cycle closeout named against this
item — see that file's "Cycle closeout" section, updated to
`CONDITIONAL_PASS` accordingly.

**Status (items 1-9 above):** Open, not yet scoped into a round.
