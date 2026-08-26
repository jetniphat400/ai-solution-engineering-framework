# Backlog v1.3

## Origin

Seeded immediately after `BACKLOG-v1.2.md` closed a **partial** cycle
and v1.2.0 shipped (see `BACKLOG-v1.2.md`'s "Cycle closeout" section
and `CHANGELOG.md`'s `1.2.0` entry). v1.2 shipped six of fourteen
items — the mechanical-enforcement and policy-correction items (status
vocabulary simplification, Claude Code hooks, and three smaller policy
fixes) — and left eight open. This backlog carries those eight
forward with their original text and provenance intact, renumbered in
recommended execution order (each item's own `**Provenance:**` line
names its original `BACKLOG-v1.2.md` item number), plus one new item
logged from a gap the v1.2 hooks work itself found and left open
rather than fixed.

**Recommended order, with the dependency reasons it follows:**

1. **Item 1 (Claude adapter playbook and lane runtime profiles, was
   v1.2 Item 7)** — first, because Items 4 (unattended execution
   profile, was v1.2 Item 3) and 5 (multi-agent contract, was v1.2
   Item 13) both explicitly depend on it: neither can name concrete
   Claude-specific mechanisms without the playbook existing first.
2. **Item 2 (single-owner mode, was v1.2 Item 10) and Item 3
   (requirements intake before classification, was v1.2 Item 9)** —
   next, as a pair: both are vendor-neutral workflow/policy gaps with
   no dependency on Item 1 or on each other, small enough to take
   together.
3. **Item 4 (unattended execution profile, was v1.2 Item 3)** — after
   Item 1 ships, since its Claude-specific half (mapping stopping
   conditions to `/loop`, `/goal`, `/schedule`, background agents)
   belongs in the adapter playbook Item 1 creates.
4. **Item 5 (multi-agent contract and Claude agent-teams profile, was
   v1.2 Item 13)** — after Item 1, for the same reason, and now also
   genuinely unblocked on its other stated dependency: v1.2 shipped
   Item 6 (Claude Code hooks), so part (b)'s planned
   `TaskCompleted` → `check-verification-report.sh` wiring has a real
   hook mechanism to attach to instead of a forward reference.
5. **Item 6 (compatibility record, was v1.2 Item 12) and Item 7
   (zero-install skill has no sync story, was v1.2 Item 1)** — after
   the above, as a pair: both are documentation/tooling gaps
   independent of Items 1-5, and Item 6 becomes markedly more useful
   once Item 1's playbook exists to have a compatibility record kept
   against.
6. **Item 8 (direct-from-URL install, was v1.2 Item 2)** — left
   **unscheduled**, per the same instruction that kept it unscheduled
   in `BACKLOG-v1.2.md`; nothing in this round's ordering changes that.

**Item 9 (the `Bash`-tool bypass of protected-path enforcement) is not
placed in the numbered sequence above** — it wasn't part of the given
ordering, and where it belongs relative to Items 1-8 is a call for the
decision-owner, not one this seeding round makes on their behalf. It
is logged here, not left to live only in a limitations note, because
it is a real, currently-open hole in a shipped Controlled-lane
security control.

## Items

### Item 1 — Claude Code adapter playbook and lane runtime profiles

**Provenance:** carried over verbatim from `BACKLOG-v1.2.md` Item 7
(external review 2026-08-26, claude-code-best-practice fold-in);
recommended first in this backlog because Items 4 and 5 below depend
on it.

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

**Status:** open — unscheduled.

### Item 2 — Single-owner mode

**Provenance:** carried over verbatim from `BACKLOG-v1.2.md` Item 10
(external review 2026-08-26, claude-code-best-practice fold-in);
recommended together with Item 3 below, independent of Item 1.

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

**Status:** open — unscheduled.

### Item 3 — Requirements intake before classification

**Provenance:** carried over verbatim from `BACKLOG-v1.2.md` Item 9
(external review 2026-08-26, claude-code-best-practice fold-in);
recommended together with Item 2 above, independent of Item 1.

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

**Status:** open — unscheduled.

### Item 4 — Unattended execution profile

**Provenance:** carried over verbatim from `BACKLOG-v1.2.md` Item 3
(itself carried over from `BACKLOG-v1.1.md` Item 9, Proposal extended
in the v1.2 round); recommended after Item 1, since its Claude-specific
half belongs in the adapter playbook Item 1 creates.

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

**Extension from the v1.2 round:** split the mapping across two
locations consistent with the framework's vendor-neutral core/policy
split. The lane→stopping-condition mapping above (vendor-neutral) goes
in `ai-engineering/policies/processing-lanes.md`. The Claude-specific
mapping of each stopping condition to concrete mechanisms (`/loop`,
`/goal`, `/schedule`, background/`--bg` agents) goes in the Claude
adapter under `ai-engineering/adapters/claude/` (see Item 1's playbook
and lane-profiles deliverables above) — `processing-lanes.md` itself
must not name a Claude-specific command.

**Size:** L. Depends on Item 1.

**Status:** open — unscheduled.

### Item 5 — Multi-agent contract and Claude agent-teams profile

**Provenance:** carried over verbatim from `BACKLOG-v1.2.md` Item 13
(external research 2026-08-26 — Claude Code agent-teams docs
(`https://code.claude.com/docs/en/agent-teams`), Cemri et al. 2025 "Why
Do Multi-Agent LLM Systems Fail?" (MAST, arXiv 2503.13657), SEMAP
(arXiv 2510.12120)); recommended after Item 1 for the same
adapter-dependency reason as Item 4, and now additionally unblocked on
its other original dependency, since `BACKLOG-v1.2.md` Item 6 (Claude
Code hooks) has shipped `DONE_VERIFIED` — part (b)'s planned
`TaskCompleted` wiring now has a real, live mechanism to attach to.

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
  close without a valid evidence block — no longer a forward reference:
  `BACKLOG-v1.2.md` Item 6 shipped this hook mechanism `DONE_VERIFIED`.
- State the hierarchy limitation honestly: Head -> Sr -> Dev is realized
  as lead + flat teammates with task dependencies, not nested teams.
- Record token-cost and session-resumption limitations from the docs,
  and the skills/MCP-server fidelity gap for teammates spawned from a
  subagent definition.

**Acceptance:** part (b) is not marked `DONE_VERIFIED` until a field
test following `docs/field-tests/TEMPLATE.md` has run at least one
Standard-lane parallel implementation and one Controlled-lane parallel
review, with a Tier 2 incident log.

**Size:** L. Depends on Item 1.

**Status:** open — unscheduled.

### Item 6 — Compatibility record

**Provenance:** carried over verbatim from `BACKLOG-v1.2.md` Item 12
(external review 2026-08-26, claude-code-best-practice fold-in);
recommended together with Item 7 below, after Items 1-5, since it
becomes markedly more useful once Item 1's playbook exists to record a
compatibility baseline against.

**Problem:** No file in the repository records which Claude Code
version this framework's field tests, hooks, or adapter guidance were
last verified against, or which hook events/frontmatter fields the
adapter actually depends on — confirmed absent (`docs/` contains only
`docs/field-tests/`, no `compat.md` or equivalent).

**Proposal:** Add `docs/compat.md` recording the Claude Code version
each field test and the playbook (Item 1) were verified against, and
every hook event and frontmatter field the adapter depends on. Once
Item 1 ships, this becomes the fastest-aging file in the repo (tied to
a specific product version) and should be the first thing checked
before trusting the playbook's command list.

**Size:** S.

**Status:** open — unscheduled.

### Item 7 — Zero-install skill has no sync story

**Provenance:** carried over verbatim from `BACKLOG-v1.2.md` Item 1
(noticed in use, 2026-08-20); recommended together with Item 6 above,
after Items 1-5.

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
- Resolve this as a side effect of `BACKLOG-v1.2.md` Item 2 below
  (direct-from-URL install) if that item's eventual mechanism happens
  to cover personal-level installs, not just per-repo ones — worth
  checking against Item 8's design once it's scoped, rather than
  solving sync twice.

**Size:** not yet estimated — depends on which branch of the fork is
taken.

**Status:** open — unscheduled.

### Item 8 — Direct-from-URL install

**Provenance:** carried over verbatim from `BACKLOG-v1.2.md` Item 2
(itself carried over verbatim from `BACKLOG-v1.1.md` Item 8); left
unscheduled per the same instruction that applied in the v1.2 round —
nothing in this round's ordering changes that.

**Problem:** Both install tiers (`SETUP.md`'s Full and Light) start
with a manual `git clone` of the framework source. There is no
direct-from-URL mechanism (fetching the framework source without a
manual clone step).

**Proposal:** Design and ship a direct-from-URL install path — the
exact mechanism (a fetch script, a release-archive download, etc.) is
not yet decided; this item is to design and evaluate options, not
prescribe one.

**Size:** M.

**Status:** open — unscheduled.

### Item 9 — Bash-tool bypass of protected-path enforcement

**Provenance:** live dogfooding 2026-08-26, `BACKLOG-v1.2.md` Item 6
(Claude Code hooks) and Item 14 (defects found in live use). Logged as
its own item, not left only in a limitations note, per explicit
instruction: a known hole in a shipped Controlled-lane security
control belongs in a backlog.

**Problem:** The `PreToolUse` hook that mechanically enforces
`AGENTS.md`'s protected-paths rule matches only the `Edit`, `Write`,
and `MultiEdit` tools — exactly as `BACKLOG-v1.2.md` Item 6 scoped it.
A `Bash` tool call that writes to a protected path (`cat >>`, `sed -i`,
a heredoc, `git apply`, `mv`, ...) is not covered at all: no block, no
warning, no override needed. Confirmed directly, repeatedly, and
non-theoretically while building and evidencing Item 6 and Item 14
themselves — several edits to newly-protected files (including this
backlog's own predecessor) were made via `Bash` specifically because
the hook correctly blocked the `Edit` tool from making them, and the
`Bash` route always succeeded with zero hook involvement. "Protected"
under the current mechanism means "protected for three tools," not
"protected," full stop — a materially narrower guarantee than the
phrase suggests to anyone who hasn't read `ai-engineering/adapters/
claude/hooks.md`'s limitations section.

**Proposal:** Not prescribed here — two candidate directions, per
`hooks.md`'s own framing of the tradeoff, evaluation left to whoever
scopes this item:

- Extend the `PreToolUse` matcher to also cover `Bash`, and have the
  hook wrapper parse the command for a file-write target before
  deciding whether to check it against the protected-paths list — a
  fundamentally harder and less reliable problem than reading
  `tool_input.file_path` directly off `Edit`/`Write`/`MultiEdit`
  (shell commands can write files through redirection, `sed -i`, `mv`,
  a heredoc, a here-doc inside a here-doc, a script that itself calls
  another script, ...; a parser that misses a shape is a silent gap in
  exactly the place this item exists to close).
- Accept `Bash`-tool bypass as the practical boundary of what a
  `PreToolUse` hook can enforce, and rely instead on the `Stop` hook's
  evidence-block requirement (any turn that changed the repo via any
  tool, including `Bash`, must declare a terminal status and evidence)
  as the actual backstop for protected-path changes made this way —
  which catches that a change happened and demands it be justified,
  but does not block the change itself and does not single out
  protected paths specifically.

**Size:** not yet estimated — depends on which direction is chosen.

**Status:** open — unscheduled.
