# Backlog v1.2

## Origin

Seeded immediately after `BACKLOG-v1.1.md` closed and v1.1.0 shipped.
First item logged from a gap noticed in normal use, not from a formal
self-audit round.

## Items

### Item 1 — Zero-install skill has no sync story

**Provenance:** noticed in use, 2026-08-20.

**Problem:** `personal-skills/solution-engineer/SKILL.md` now exists in
two places that can silently diverge: this repo's copy, and a separate
copy the user has installed directly into their Claude app (per
Zero-install's own design in `SETUP.md`'s "Zero-install" section —
install once, outside any project). These two copies have already
drifted within one day: the app-installed copy predates v1.1's
`SECURITY_BLOCKED`/`NEEDS_HUMAN` disambiguation (`AGENTS.md`'s
"Completion status" section, fixed under v1.1 Item 11 — see
`BACKLOG-v1.1.md`), so it carries stale status-vocabulary guidance the
repo copy has already corrected. `SKILL.md`'s current frontmatter (lines
1-4) has no version marker of any kind, so a stale installed copy is not
mechanically detectable — a user (or agent) reading the app copy has no
signal that it's out of date relative to this repo.

**Proposal:** A fork, not a decision made here — three candidate
directions, not mutually exclusive:

- Add a version marker inside `SKILL.md` itself (e.g. a version line in
  frontmatter, or a pointer to the framework `VERSION` it was generated
  against) so a stale installed copy is at least detectable by
  comparison, even without an automated sync mechanism.
- Add an update procedure to `SETUP.md`'s "Zero-install" section —
  today that section documents installing the skill once, but says
  nothing about what a user should do when the source repo's copy
  changes after their personal install already exists.
- Resolve this as a side effect of `BACKLOG-v1.1.md` Item 8
  (direct-from-URL install, still `DEFERRED`/`NEEDS_HUMAN`) if that
  item's eventual mechanism happens to cover personal-level installs,
  not just per-repo ones — worth checking against Item 8's design once
  it's scoped, rather than solving sync twice.

**Size:** not yet estimated — depends on which branch of the fork is
taken.

**Status:** open — unscheduled. Logged only, per explicit instruction
not to act this round.

### Item 2 — Direct-from-URL install

**Provenance:** carried over verbatim from `BACKLOG-v1.1.md` Item 8.

**Problem:** Both install tiers (`SETUP.md`'s Full and Light) start
with a manual `git clone` of the framework source. There is no
direct-from-URL mechanism (fetching the framework source without a
manual clone step).

**Proposal:** Design and ship a direct-from-URL install path — the
exact mechanism (a fetch script, a release-archive download, etc.) is
not yet decided; this item is to design and evaluate options, not
prescribe one.

**Size:** M.

**Status:** open — unscheduled. Not scheduled this cycle.

### Item 3 — Unattended execution profile

**Provenance:** carried over from `BACKLOG-v1.1.md` Item 9, Proposal
extended this round.

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

Scope is exactly two deliverables: the mapping above, and a definition
of what a "loop-runnable verification gate" requires (a deterministic
pass/fail signal, bounded runtime, no reliance on the same interactive
judgment calls a human would otherwise make).

**Extension this round:** split the mapping across two locations
consistent with the framework's vendor-neutral core/policy split. The
lane→stopping-condition mapping above (vendor-neutral) goes in
`ai-engineering/policies/processing-lanes.md`. The Claude-specific
mapping of each stopping condition to concrete mechanisms (`/loop`,
`/goal`, `/schedule`, background/`--bg` agents) goes in the Claude
adapter under `ai-engineering/adapters/claude/` (see Item 7's playbook
and lane-profiles deliverables) — `processing-lanes.md` itself must not
name a Claude-specific command.

**Size:** L.

**Status:** open — scheduled this round.

### Item 4 — Provenance extraction from solution-engineer SKILL.md

**Provenance:** retroactive log, 2026-08-26 — executed before being
logged in this backlog, per this round's instruction to record the
plan-derived items after the fact rather than omit them.

**Problem:** `personal-skills/solution-engineer/SKILL.md` mixed
`[source: ...]` citations and "flagged as this skill's own extension"
rationale prose throughout its operating rules, cluttering a contract
other sessions load standalone.

**Proposal:** Extract every citation and extension-rationale note into
a new `references/provenance.md`, following the folder's existing
condensed-pointer/full-detail convention; `SKILL.md` keeps only
operating rules.

**Size:** M.

**Status:** `DONE_VERIFIED`. Executed as commit
`0a728d1` before this item was logged here — noted explicitly rather
than presented as planned-then-done. Evidence: post-edit grep of
`SKILL.md` for `\[source:`/`flagged as` returned zero matches;
`references/provenance.md` created containing all extracted content;
`git diff --stat` confirmed only the two intended files changed.

### Item 5 — Lane-conditioned confirmation

**Provenance:** retroactive log, 2026-08-26 — executed before being
logged, same as Item 4.

**Problem:** `ai-engineering/policies/processing-lanes.md` and
`personal-skills/solution-engineer/SKILL.md`'s PROPOSE section
required an unconditional "Confirm?" wait for every lane, including
Fast, even though Fast is defined as small/clear/low-risk/one-sentence
work where that overhead isn't warranted.

**Proposal:** `processing-lanes.md` now states a per-lane confirmation
rule as canon (Fast: announce and proceed immediately; Standard/
Controlled: propose and wait for explicit confirmation).
`personal-skills/solution-engineer/SKILL.md`'s PROPOSE section was made
lane-conditioned to match, plus a mid-task-reclassification clause
noting that escalating out of Fast also flips the wait behavior.

**Size:** S.

**Status:** `CONDITIONAL_PASS` -> `DONE_VERIFIED`.
Shipped as commit `df883d5`; remaining-work gap (`.claude/skills/
engineer/SKILL.md`'s PROPOSE section still requiring "Confirm?"
unconditionally for all lanes) closed as commit `e7c3b7c`, which
lane-conditions that section with the same wording shipped in
`personal-skills/solution-engineer/SKILL.md`. Post-fix, repo-wide grep
for `Confirm\?` shows every occurrence is either lane-conditioned
(`.claude/skills/engineer/SKILL.md`, `personal-skills/
solution-engineer/SKILL.md`) or historical prose describing the
now-fixed gap (this file). No remaining drift between the two skills.

### Item 6 — Wire existing checks as Claude Code hooks

**Provenance:** external review 2026-08-26 (claude-code-best-practice
fold-in).

**Problem:** `.claude/settings.json` contains only `permissions.deny`
(six `Read(...)` patterns) — no `hooks` block of any kind (confirmed
by direct read). `ai-engineering/checks/check-protected-paths.sh`/
`.ps1` and `check-verification-report.sh`/`.ps1` exist and are shipped
(per `BACKLOG-v1.1.md` Items 1-2) but have no hook or CI wiring —
confirmed: the only "hook" mention in either script is a comment noting
the protected-paths script is "suitable as a pre-commit hook," not an
actual wired hook; both are invoked manually today.

**Proposal:** A `PreToolUse` hook invoking `check-protected-paths` on
`Edit`/`Write` targets; a `Stop` hook invoking
`check-verification-report`; a documented override mechanism so policy
files themselves remain editable; keep the `.ps1` variants at parity
with `.sh`.

**Size:** M.

**Status:** open — unscheduled. Logged only, per explicit instruction
not to act this round.

### Item 7 — Claude Code adapter playbook and lane runtime profiles

**Provenance:** external review 2026-08-26 (claude-code-best-practice
fold-in).

**Problem:** `ai-engineering/core/` and `ai-engineering/policies/` are
vendor-neutral by design — confirmed: every core/policy file read this
round (`workflow.md`, `redteam.md`, `processing-lanes.md`,
`approval-matrix.md`, `protected-assets.md`, `instruction-authority.md`,
`model-tiers.md`) uses only vendor-neutral language ("coding agent,"
provider-neutral model tiers), no Claude-specific command or mechanism
named anywhere in them. **Premise not confirmed precisely as stated:**
the premise that "the only Claude-specific guidance today is the short
`CLAUDE.md` adapter block and `adapters/claude/README.md`" undercounts
what actually exists — `.claude/rules/engineering.md` and
`.claude/rules/security.md` also carry Claude-specific guidance prose
(lane defaults, plan-mode instructions, security rules), beyond just
those two files. `adapters/claude/README.md` itself is confirmed short
(16 lines: validation commands, a pointer to `.claude/settings.json`).

**Proposal:** Add `ai-engineering/adapters/claude/playbook.md` ("when
doing X → use /command Y → because Z", every command verified against
the installed Claude Code version, beta items tagged `[beta]`) and
`adapters/claude/lane-profiles.md` (Fast/Standard/Controlled →
permission mode, plan mode, worktree isolation, auto-mode allowed or
forbidden). `processing-lanes.md` may link to the adapter but must not
name a Claude command.

**Size:** M.

**Status:** open — unscheduled. Logged only, per explicit instruction
not to act this round.

### Item 8 — Reviewer model contradicts model-tiers policy

**Provenance:** external review 2026-08-26 (claude-code-best-practice
fold-in).

**Problem:** `.claude/agents/independent-reviewer.md` declares
`model: inherit` (confirmed, line 5) while `ai-engineering/policies/
model-tiers.md` requires `CRITICAL_REVIEW_MODEL` for "security,
migration, high-risk design, and final adversarial review" (confirmed,
line 8) and states high-risk tasks "must not be downgraded solely for
cost." `inherit` resolves to whatever model the calling session
happens to be running, which is not guaranteed to meet the
`CRITICAL_REVIEW_MODEL` tier — a real, confirmed contradiction between
the agent definition and the policy it's meant to satisfy for final
adversarial/independent review.

**Proposal:** Pin the reviewer to the strongest available model;
document the tier→model mapping in `adapters/claude/README.md`;
document a cross-model fallback in `adapters/codex/README.md`.

**Size:** S.

**Status:** `DONE_VERIFIED`. Shipped as commit `da41613`: `independent-reviewer.md` pins
`model: fable` (verified accepted via `claude --help` and a direct
quote from `https://code.claude.com/docs/en/sub-agents`'s subagent
frontmatter table — `best` was checked and confirmed *not* valid there,
despite matching the "strongest available, degrade gracefully"
semantics in prose); `adapters/claude/README.md` documents the full
tier→model mapping with `opus` as the explicit fallback where Fable 5
isn't available; `adapters/codex/README.md` documents the cross-vendor
fallback as the preferred Controlled-lane path. Post-edit grep of
`ai-engineering/core/` and `ai-engineering/policies/` for
`fable|opus|sonnet|haiku|claude-` returned zero matches — no
vendor/model name leaked into vendor-neutral canon. One verification
gap disclosed rather than hidden: `claude agents` requires an
interactive TTY and couldn't be run headlessly to confirm the loaded
subagent picker shows `fable`; verified instead by direct inspection
of the YAML frontmatter's structure and the already-confirmed-valid
literal value.

### Item 9 — Requirements intake before classification

**Provenance:** external review 2026-08-26 (claude-code-best-practice
fold-in).

**Problem:** Premise verified: `ai-engineering/core/workflow.md`'s
Phase 1 ("Intake and governance") only covers "Classify project state,
change type, risk, trust, processing lane, permission profile, and
decision owners" — no explicit requirements-interview step. Phase 2
("User and project discovery," "Understand the user need, current
process, evidence, constraints...") also states no interview
*procedure* — it names what to understand, not how to elicit it. No
explicit requirements-interview step exists anywhere in `workflow.md`,
confirmed by direct read.

**Proposal:** Add a vendor-neutral intake procedure (minimal spec →
structured interview → spec with open questions) to `core/workflow.md`
and `templates/`, with Claude-specific `AskUserQuestion` mechanics
placed in the adapter, not in `workflow.md` itself.

**Size:** M.

**Status:** open — unscheduled. Logged only, per explicit instruction
not to act this round.

### Item 10 — Single-owner mode

**Provenance:** external review 2026-08-26 (claude-code-best-practice
fold-in).

**Problem:** `ai-engineering/policies/approval-matrix.md` assumes
distinct business, technical, security, and release owners (confirmed:
its table names "Business or project owner," "Technical owner,"
"Security or technical owner," "Database and technical owners,"
"Release or infrastructure owner," "Technical owner independent of
implementer") and, for a solo user, asks them to "assign at least one
Business Owner and one Technical Owner before Controlled Lane work"
(confirmed, line 15) — which still asks a one-person team to role-play
distinct named owners.

**Proposal:** Add a single-owner mode that replaces owner naming with a
mandatory separation-of-sessions rule: Controlled-lane review runs in a
fresh session, not the implementing one.

**Size:** S.

**Status:** open — unscheduled. Logged only, per explicit instruction
not to act this round.

### Item 11 — Status vocabulary simplification (study-only gate)

**Provenance:** external review 2026-08-26 (claude-code-best-practice
fold-in).

**Problem:** The two-tier status system (`AGENTS.md` terminal statuses
+ `workflow.md`'s five-state local/Gate legend + crosswalk table) is
confirmed to exist as described. **Premise refined, not rejected:** the
premise cites "one confirmed ambiguity (v1.1 Item 11)" as its evidence,
but that ambiguity (`SECURITY_BLOCKED` vs `NEEDS_HUMAN`, fixed in
`AGENTS.md`) sits within the *terminal-status* vocabulary itself, not
the local-status-to-terminal crosswalk. A second, more directly
relevant data point exists in the file actually read this round:
`workflow.md`'s own "Tension reported, not forced" note records that
pilot #2's register used a single term, `OPEN`, for two distinct
meanings, which could not crosswalk cleanly onto `AGENTS.md`'s
vocabulary and had to be split into `NOT_STARTED`/`DEFERRED`. Both are
real, already-fixed ambiguities — the premise's underlying claim (this
system has already produced confirmed ambiguity) holds, just from two
sources rather than the one cited.

**Proposal:** Run a study-only gate — grep every reference to both
vocabularies across the repo, list every crosswalk actually used in
`docs/field-tests/` and `BACKLOG-*.md`, and report whether a single
vocabulary would lose information. No edits. Closes `NEEDS_DECISION`
when executed.

**Size:** S.

**Status:** The study-only gate closed `NEEDS_HUMAN` on 2026-08-26; full
report: `docs/field-tests/2026-08-26-status-vocabulary-study.md`. Per
this gate type's own definition (`ai-engineering/core/workflow.md`'s
"Study-only gate"), it gathered evidence and informed the decision
without making one. The decision gate ran the same day and chose
design (b) — retire the local vocabulary and crosswalk table, use
`AGENTS.md`'s terminal statuses everywhere — recorded in the study
report's "## Decision" section (commit `7275d03`). Implementation
landed in commit `77d5c11` (`AGENTS.md`, `ai-engineering/core/
workflow.md`, `personal-skills/solution-engineer/SKILL.md` and its
`references/` files, and this file's other items). Independent review
found this item's own status paragraph had not been updated to match
(CONDITIONAL PASS, finding B1); that gap and the review's other
findings (M1, M2, L2) were remediated in a follow-up commit before this
item closed.

### Item 12 — Compatibility record

**Provenance:** external review 2026-08-26 (claude-code-best-practice
fold-in).

**Problem:** No file in the repository records which Claude Code
version this framework's field tests, hooks, or adapter guidance were
last verified against, or which hook events/frontmatter fields the
adapter actually depends on — confirmed absent (`docs/` contains only
`docs/field-tests/`, no `compat.md` or equivalent).

**Proposal:** Add `docs/compat.md` recording the Claude Code version
each field test and the playbook (Item 7) were verified against, and
every hook event and frontmatter field the adapter depends on. Once
Item 7 ships, this becomes the fastest-aging file in the repo (tied to
a specific product version) and should be the first thing checked
before trusting the playbook's command list.

**Size:** S.

**Status:** open — unscheduled. Logged only, per explicit instruction
not to act this round.
