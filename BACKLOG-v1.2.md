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

**Status:** `DONE_VERIFIED`. Implemented substantially beyond the
original proposal, with explicit human confirmation at each phase: a
`PreToolUse` hook on `Edit`/`Write`/`MultiEdit` blocking edits to
`AGENTS.md`'s newly-populated "Project-specific protected paths" block
(`AGENTS.md`, `ai-engineering/policies/`, `ai-engineering/checks/`,
`.claude/settings.json`); a `UserPromptSubmit` hook recording a
per-session `git status` baseline; a `Stop` hook enforcing exactly one
terminal status and the five-field evidence block, but only on a turn
that actually modified the repository — added specifically to avoid
deadlocking ordinary conversation turns (design note (iv), not in the
original proposal); an `AI_ENGINEERING_PROTECTED_PATH_OVERRIDE` env-var
override with no permanent allowlist; a self-maintained loop-guard
counter substituting for `stop_hook_active`, confirmed absent from the
installed version's (`2.1.246`) hooks documentation by direct,
repeated search rather than assumed present; every hook registered
twice per event (bash + PowerShell exec-form entries) for cross-platform
coverage.

Verified with real hook invocations, not inspection: a real `Edit` tool
call against a real newly-protected path was actually intercepted and
blocked live, twice, in the course of this item's own work (not a
drill); the override, Stop-hook block, Stop-hook pass, and the
no-edit-turn deadlock-avoidance case were each verified either live or
at script level against this repo's real files and real git state (see
`ai-engineering/checks/TEST-EVIDENCE.md`'s Item 6 entry for the full
breakdown of which). An independent-reviewer pass on the full diff
returned `CONDITIONAL PASS`; findings M1 (a nested `powershell.exe`
call could fail closed on every edit on a restrictive-policy host), M3
(a bash/PowerShell case-sensitivity asymmetry), and L2 (a missing
word-boundary anchor) were fixed and re-verified. Findings H1
(deadlock-avoidance is conditional on `session_id` extraction
succeeding — no safe alternative exists), M2 (dual-fire's shared-state
race, bounded consequence), L1 (an edit-then-revert nets to a clean
diff and skips enforcement), and L3 (Windows-only path style, correct
for this design's target) were documented as accepted limitations
rather than fixed, with reasoning in
`ai-engineering/adapters/claude/hooks.md`.

**H2, kept prominent rather than buried**: the `PreToolUse` hook only
matches `Edit`/`Write`/`MultiEdit`, exactly as scoped — a `Bash`-tool
write to a protected path is not covered at all, with no block, no
warning, and no override needed. This is not a hidden gap: it was
exercised live as a legitimate workaround during this item's own
implementation (several edits to newly-protected files, including this
entry, were made via `Bash` specifically because the hook correctly
blocked the `Edit` tool from making them). Protected-path enforcement
via this mechanism should be read as "enforced for the three matched
tools," not "enforced," full stop.

Two more real, pre-existing/newly-introduced bugs were found and fixed
during implementation, unrelated to the review findings above: (1)
`check-protected-paths.sh` crashed silently under `set -e` whenever the
protected-paths block had no path-shaped token — exactly this repo's
own placeholder state before this item populated it; (2) both new
PowerShell wrapper scripts wrote their per-session state files with a
UTF-8 BOM via `Out-File -Encoding utf8`, which `Get-Content` masks on a
PowerShell-only round trip but which would corrupt a `bash` reader's
numeric/string comparisons in the dual-fire case — found by inspecting
a real state file's raw bytes, fixed with explicit BOM-less encodings.

**Remaining-risk record, updated by Item 14 (2026-08-26):** three
defects surfaced in live use immediately after this item shipped and
are now fixed — see Item 14. Specifically: the bash handler not
running at all on a host where `bash` resolves to the WSL stub (Item
14 Defect 1, fixed via shell-form hook registration); the whole-message
terminal-status false positive this item's own header already flagged
as a known limitation (Item 14 Defect 2, fixed by scoping the count to
declaration-position lines); and the missing-baseline-on-every-check
behavior (Item 14 Defect 3, fixed with a self-healing, non-under-
enforcing RECOVERY baseline). **Still open and accepted, unchanged by
Item 14**: H1 (deadlock-avoidance conditional on `session_id`
extraction), M2 (dual-fire's shared-state race), L1 (edit-then-revert
nets to a clean diff), L3 (Windows-only path style), and — most
significantly — **H2, the `PreToolUse` hook's `Bash`-tool bypass of
protected-path enforcement, which remains open.** As of this Item 14
close, `BACKLOG-v1.3.md` does not yet exist; H2 is planned to become
its own tracked item there as part of this session's Part 3 work
(carrying open v1.2 items forward), rather than living only in a
limitations note — but that file's creation is a separate, later
commit, not something this sentence should be read as already true.

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

**Status:** `DONE_VERIFIED`. The study-only gate closed `NEEDS_HUMAN` on
2026-08-26; full report:
`docs/field-tests/2026-08-26-status-vocabulary-study.md`. Per this gate
type's own definition (`ai-engineering/core/workflow.md`'s "Study-only
gate"), it gathered evidence and informed the decision without making
one. The decision gate ran the same day and chose design (b) — retire
the local vocabulary and crosswalk table, use `AGENTS.md`'s terminal
statuses everywhere — recorded in the study report's "## Decision"
section (commit `7275d03`). Implementation landed in commit `77d5c11`
(`AGENTS.md`, `ai-engineering/core/workflow.md`,
`personal-skills/solution-engineer/SKILL.md` and its `references/`
files, and this file's other items). Evidence: commits `77d5c11`,
`7275d03`, and `3a4990d`; the independent-reviewer
returned `CONDITIONAL PASS` naming finding B1 (this item's own status
paragraph had not been updated to match — the decision was already
made, but the paragraph still said one was pending and used the
retired vocabulary live) and finding H1 (the pre-decision grep claimed
the change complete without re-checking after implementation); B1,
H1's underlying gap, and findings M1/M2/L2 were all remediated in
commit `3a4990d`, re-verified by a repo-wide grep for every retired
term and by `check-verification-report.sh` against the study report.
**Process lesson (H1):** a grep run to justify a completion claim must
be run *after* the edits it is certifying, against the edited state —
not only during the earlier study phase — or it can miss the very item
it is meant to close, as it did here.

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

### Item 13 — Multi-agent contract and Claude agent-teams profile

**Provenance:** external research 2026-08-26 — Claude Code agent-teams
docs (`https://code.claude.com/docs/en/agent-teams`), Cemri et al. 2025
"Why Do Multi-Agent LLM Systems Fail?" (MAST, arXiv 2503.13657), SEMAP
(arXiv 2510.12120).

**Problem:** The framework has one multi-agent mechanism
(`independent-reviewer` as a fresh-context subagent) and no rules for
anything beyond it: no status aggregation across agents, no handoff
format, no file-ownership rule, no lane rule for parallel work. MAST's
three failure categories (specification, inter-agent misalignment,
task verification) are the same three problems this framework already
targets for single agents, but none of its controls are stated for the
multi-agent case. Enabling agent teams without those rules would let a
lead report `DONE_VERIFIED` over a teammate's `CONDITIONAL_PASS`, which
breaks the framework's central guarantee.

**Premises verified before writing this item** (installed Claude Code
`2.1.246`, docs fetched 2026-08-26, describing behavior "as of
v2.1.178" — the installed version postdates every version note on the
page, so no version mismatch applies): agent teams are experimental
and disabled by default, enabled by `CLAUDE_CODE_EXPERIMENTAL_AGENT_
TEAMS=1` — confirmed verbatim. No nested teams ("teammates cannot spawn
their own teammates"), the lead is fixed for the session's lifetime,
and a teammate cannot be promoted to lead or given leadership —
confirmed verbatim (`Limitations` section). A subagent definition from
project, user, plugin, or CLI scope — including `.claude/agents/
independent-reviewer.md`, confirmed present in this repo — can be
referenced by name to spawn a teammate with that definition's `tools`
allowlist and `model`, its body appended as additional system-prompt
instructions — confirmed ("Use subagent definitions for teammates"),
with one caveat: the definition's `skills` and `mcpServers` frontmatter
fields are NOT applied when it runs as a teammate — a fidelity gap part
(b) must document. The lead can require plan approval from a teammate
and be given approval criteria in the spawn prompt, but "the lead makes
approval decisions autonomously" — confirmed, and worth stating plainly
in part (b): the lead's approval is a judgment call guided by criteria,
not a mechanical gate. `TeammateIdle` and `TaskCompleted` hooks exist
and exit code 2 blocks — confirmed, with a nuance: `TeammateIdle`'s
exit-2 "sends feedback and keeps the teammate working" (it blocks the
teammate going idle, not a task closing), while `TaskCompleted`'s
exit-2 "prevents completion and sends feedback" (it blocks the task
itself) — these are two different block points, not interchangeable,
and part (b)'s hook wiring must use `TaskCompleted` for the
evidence-block gate, not `TeammateIdle`. Teammates cannot approve
permissions on the user's behalf or relay a denied action to bypass the
check — confirmed verbatim ("Messages between agents"). No premise
required correction; all six are accurate as given, with the two
caveats above (skills/MCP-server fidelity, the two distinct hook block
points) folded into part (b)'s scope rather than dropped.

**Proposal, part (a)** — `ai-engineering/policies/multi-agent-contract.md`,
vendor-neutral:

1. Status aggregation: an orchestrator's terminal status can never be
   higher than the lowest terminal status of any agent whose work it
   includes.
2. Handoff contract: every inter-agent result uses the existing
   five-field evidence block; free-text "done" is not a handoff.
3. File ownership: parallel implementers own disjoint file sets,
   declared at spawn; a file outside an agent's set is a protected path
   for that agent.
4. Orchestrator does not implement. It classifies, decomposes, assigns,
   approves plans against lane criteria, and aggregates. Orchestrator
   implementation is a process failure, not a shortcut.
5. Lane table: Fast — no multi-agent. Standard — parallel implementation
   allowed under rules 1-4, review by a separate agent gated on
   implementation tasks. Controlled — parallel review only (independent
   lenses, e.g. security / data / tests); parallel implementation
   forbidden.
6. Model tiers apply per role: reviewer roles use
   `CRITICAL_REVIEW_MODEL`; the orchestrator may use a lower tier than
   its implementers.

**Proposal, part (b)** — `ai-engineering/adapters/claude/agent-teams.md`:

- Map roles to subagent definitions (lead = orchestrator;
  `independent-reviewer` as the review teammate; per-scope implementer
  definitions).
- Express lane rules as plan-approval criteria given to the lead, and
  state plainly that the lead's approval is a judgment call guided by
  those criteria, not a mechanical gate.
- Wire `TaskCompleted` (not `TeammateIdle` — the two hooks block
  different points, see the verified-premises note above) to
  `ai-engineering/checks/check-verification-report.sh` so a task cannot
  close without a valid evidence block (depends on Item 6).
- State the hierarchy limitation honestly: Head -> Sr -> Dev is realized
  as lead + flat teammates with task dependencies, not nested teams.
- Record token-cost and session-resumption limitations from the docs,
  and the skills/MCP-server fidelity gap for teammates spawned from a
  subagent definition.

**Acceptance:** part (b) is not marked `DONE_VERIFIED` until a field
test following `docs/field-tests/TEMPLATE.md` has run at least one
Standard-lane parallel implementation and one Controlled-lane parallel
review, with a Tier 2 incident log.

**Size:** L. Depends on Items 6 and 7.

**Status:** open — scheduled this cycle, after Items 6, 7, and 3.
Owner: maintainer.

### Item 14 — Item 6 hook defects found in live use

**Provenance:** live dogfooding 2026-08-26, observed in the Stop-hook
blocks immediately after Item 6 shipped.

**Problem:** Three real defects in shipped code, confirmed by direct
diagnosis, not assumed:

1. The bash hook handler never ran on the reference dev host — every
   turn emitted `WSL (10 - Relay) ERROR: CreateProcessCommon:818:
   execvpe(/bin/bash) failed: No such file or directory`. Diagnosed:
   `where.exe bash` resolves to `C:\Windows\System32\bash.exe` (the
   WSL launcher stub) before real Git Bash, because Git's `bin`
   directory isn't on this session's `PATH` — only the PowerShell
   handler ever decided.
2. The terminal-status count was whole-message, so a message that
   named its outcome in prose and again in its formal declaration was
   blocked as ambiguous — confirmed by two real live blocks.
3. The per-turn baseline was not found at Stop time on every check
   within an affected turn, enforcing the evidence block even when
   nothing changed. Diagnosed: `session_id` extraction, path, and BOM
   were all correct; the real cause is that `UserPromptSubmit` never
   re-fires on a Stop-hook-forced continuation, so a missing baseline
   (from any cause) repeats "no baseline" for the rest of that turn.

**Proposal, executed together with this log entry** (defects in
shipped code, not logged-only): (1) switch the three bash-targeting
hook entries in `.claude/settings.json` from exec form to shell form
(`"shell": "bash"`), trusting Claude Code's own Git-Bash detection
instead of a bare OS PATH lookup — confirmed working live on the first
attempt, so the agreed fallback (a wrapper self-detecting it can't run
under real bash or reach its check script, exiting 0 silently) was not
needed and was not implemented. (2) Scope the terminal-status count to
declaration-position lines only (a `Terminal status` line, or a line
consisting solely of a token) — prose mentions no longer count. (3)
Self-heal a missing baseline with a RECOVERY marker that does NOT grant
a clean-diff pass for the rest of the turn, specifically so edits made
earlier in the turn are never silently dropped from consideration —
under-enforcing on a turn that did modify the repo is the worse
failure.

**Size:** S.

**Status:** `DONE_VERIFIED`. All three defects fixed and verified by
real invocation, not inspection: (1) a real `Edit` PreToolUse
invocation was decided by the bash script itself with no WSL error, on
both a protected path (blocked) and an unprotected one (silent pass);
(2) a message naming its outcome in prose and declaring it formally
once now passes, script-verified in both implementations; (3) an
ordinary no-edit turn (real repo git-status data, no recovery marker)
passes immediately, and — the harder half — a recovery marker forces
continued enforcement despite a clean diff, with a fresh
`UserPromptSubmit` correctly clearing it afterward. (4) A protected-path
edit is still blocked live, post-fix (`AGENTS.md`).

An independent-reviewer pass on this remediation itself returned
`FAIL`, not a pass on the first try: B1 (blocking — this file
previously claimed, in present tense, that `BACKLOG-v1.3.md` already
tracked H2, before that file existed) and H1 (high — the Defect 2 fix
didn't recognize a declaration wrapped in a markdown list marker,
exactly the format `personal-skills/solution-engineer/SKILL.md` itself
uses for the seven terminal statuses, reintroducing an over-blocking
false positive of the same class this item exists to fix). Both were
real regressions, not matters of judgment, and both are now fixed and
re-verified, along with medium/low findings M1 (a non-atomic
recovery-file write order that could defeat Defect 3's own
no-false-pass guarantee under real dual-fire), M2 (a stale doc
section), M3 (a premature "recorded" claim), L1, and L2. Full
before/after evidence and the complete verdict:
`ai-engineering/checks/TEST-EVIDENCE.md`'s Item 14 entry and
`ai-engineering/adapters/claude/hooks.md`'s "Independent review
findings (Item 14, FAIL → remediated)" section.
