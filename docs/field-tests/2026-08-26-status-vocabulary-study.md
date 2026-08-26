# Study: Status Vocabulary — BACKLOG-v1.2 Item 11 (study-only gate)

**Gate type:** Study-only, per `ai-engineering/core/workflow.md`'s Gate
definitions — gathers evidence, changes no code or docs (other than
this report and the backlog status update it feeds), always closes
`NEEDS_DECISION`.

**Scope:** every occurrence of the terminal-status vocabulary
(`AGENTS.md`), the local Gate/register vocabulary
(`ai-engineering/core/workflow.md`), and any other status-like term
found along the way, across the whole repository as of 2026-08-26.

**Method note:** occurrences are grouped by file when the same term
appears repeatedly in the same file with the *same* usage category
(definition, usage-in-a-report, or usage-in-prose) — each such row
lists every line number, so no occurrence is dropped, but the table
stays readable. A row is split whenever the category differs within a
file.

---

## 1. Every occurrence, by term

### Terminal vocabulary (`AGENTS.md:121-127`)

| Term | File:line | Context |
|---|---|---|
| `DONE_VERIFIED` | `AGENTS.md:121` | definition (terminal list) |
| `DONE_VERIFIED` | `ai-engineering/core/workflow.md:61` | definition (crosswalk table) |
| `DONE_VERIFIED` | `personal-skills/solution-engineer/SKILL.md:136,173,195` | definition (rule text, terminal list copy, crosswalk table copy) |
| `DONE_VERIFIED` | `.claude/skills/engineer/modules/context-mapping.md:64` | definition (module status option) |
| `DONE_VERIFIED` | `.claude/skills/engineer/modules/onboard-inherited.md:38,62,75,90,107,121,135,141,142` | definition (per-step status option, 9 mentions) |
| `DONE_VERIFIED` | `.claude/skills/engineer/modules/setup-preflight.md:39` | definition |
| `DONE_VERIFIED` | `.claude/skills/engineer/modules/onboard-existing.md:43` | definition |
| `DONE_VERIFIED` | `.claude/skills/engineer/modules/onboard-greenfield.md:55` | definition |
| `DONE_VERIFIED` | `.claude/skills/engineer/modules/setup-configure.md:3,19,25` | definition |
| `DONE_VERIFIED` | `.claude/skills/engineer/modules/setup-install.md:3,39` | definition |
| `DONE_VERIFIED` | `BACKLOG-v0.3.md:328,329,331,332,333,334,335,349` | usage in a report (closeout table + overall status) |
| `DONE_VERIFIED` | `BACKLOG-v0.3.md:161` | usage in prose (names the vocabulary while describing a different gap) |
| `DONE_VERIFIED` | `BACKLOG-v1.1.md:61,95,124,163,190,243,281,429,455,476-483,486,487,495` | usage in a report (per-item Status lines + closeout table + overall status, 19 mentions) |
| `DONE_VERIFIED` | `BACKLOG-v1.1.md:48` | usage in prose (evidence-linting problem statement) |
| `DONE_VERIFIED` | `BACKLOG-v1.2.md:131,158,251` | usage in a report (Items 4, 5, 8) |
| `DONE_VERIFIED` | `docs/field-tests/2026-08-19-cross-agent-contract-test.md:47,48` | usage in a report (Task A scoring) |
| `DONE_VERIFIED` | `docs/field-tests/2026-07-31-pcc-pilot.md:20,21,22` | usage in a report (setup-module statuses) |
| `DONE_VERIFIED` | `personal-skills/solution-engineer/TEST-EVIDENCE.md:42` | usage in a report (S1 scenario result) |
| `DONE_VERIFIED` | `docs/field-tests/2026-08-19-pcc-pilot-2.md:47,99` | usage in prose (observes the term does *not* appear anywhere in the external PCC register/`ISSUES.md`) |
| `CONDITIONAL_PASS` | `AGENTS.md:122` | definition |
| `CONDITIONAL_PASS` | `ai-engineering/core/workflow.md:61,63` | definition (crosswalk table, two rows) |
| `CONDITIONAL_PASS` | `personal-skills/solution-engineer/SKILL.md:135,174,195,197` | definition |
| `CONDITIONAL_PASS` | `.claude/skills/engineer/modules/setup-install.md:40` | definition |
| `CONDITIONAL_PASS` | `.claude/skills/engineer/modules/onboard-existing.md:45` | definition |
| `CONDITIONAL_PASS` | `.claude/skills/engineer/modules/setup-configure.md:3` | definition |
| `CONDITIONAL_PASS` | `.claude/skills/engineer/modules/onboard-inherited.md:62,76,135,142` | definition |
| `CONDITIONAL_PASS` | `BACKLOG-v0.3.md:330` | usage in a report (zero-install sub-tier closeout row) |
| `CONDITIONAL_PASS` | `BACKLOG-v0.3.md:161,301,315,339,340,345` | usage in prose (vocabulary discussion, `OPEN`-split reasoning, closeout-rule explanation) |
| `CONDITIONAL_PASS` | `BACKLOG-v1.1.md:313,388,490,491` | usage in prose (crosswalk-rule reasoning) |
| `CONDITIONAL_PASS` | `BACKLOG-v1.2.md:158` | usage in a report (Item 5, as a transitional status later closed to `DONE_VERIFIED`) |
| `CONDITIONAL_PASS` | `CHANGELOG.md:79` | usage in prose |
| `CONDITIONAL_PASS` | `personal-skills/solution-engineer/TEST-EVIDENCE.md:168,174` | usage in a report (S4 scenario result) |
| `CONDITIONAL_PASS` | `docs/field-tests/2026-08-19-pcc-pilot-2.md:47,99` | usage in prose (same non-use observation as `DONE_VERIFIED` above) |
| `REPLAN_REQUIRED` | `AGENTS.md:123` | definition |
| `REPLAN_REQUIRED` | `ai-engineering/core/workflow.md:62,65` | definition (crosswalk table, two rows) |
| `REPLAN_REQUIRED` | `personal-skills/solution-engineer/SKILL.md:175,196,199` | definition |
| `REPLAN_REQUIRED` | `.claude/skills/engineer/modules/onboard-existing.md:49` | definition |
| `REPLAN_REQUIRED` | `.claude/skills/engineer/modules/onboard-inherited.md:121` | definition |
| `REPLAN_REQUIRED` | `BACKLOG-v0.3.md:300` | usage in prose (`OPEN`-split reasoning) |
| `REPLAN_REQUIRED` | `docs/field-tests/2026-08-19-pcc-pilot-2.md:99` | usage in prose (non-use observation) |
| `REPLAN_REQUIRED` | *(no report actually assigns this status to any item — see §2)* | — |
| `REQUIREMENT_AMBIGUOUS` | `AGENTS.md:124` | definition |
| `REQUIREMENT_AMBIGUOUS` | `personal-skills/solution-engineer/SKILL.md:176` | definition |
| `REQUIREMENT_AMBIGUOUS` | `.claude/skills/engineer/modules/context-mapping.md:66` | definition |
| `REQUIREMENT_AMBIGUOUS` | `.claude/skills/engineer/modules/onboard-greenfield.md:58` | definition |
| `REQUIREMENT_AMBIGUOUS` | `.claude/skills/engineer/modules/setup-configure.md:20` | definition |
| `REQUIREMENT_AMBIGUOUS` | *(no report occurrence found anywhere)* | — |
| `SECURITY_BLOCKED` | `AGENTS.md:125,129,130` | definition (list entry + disambiguation rule) |
| `SECURITY_BLOCKED` | `personal-skills/solution-engineer/SKILL.md:177,181,182` | definition |
| `SECURITY_BLOCKED` | `personal-skills/solution-engineer/references/provenance.md:75` | usage in prose (provenance pointer) |
| `SECURITY_BLOCKED` | `ai-engineering/core/workflow.md:67` | definition (notes it has no per-item Gate/register equivalent) |
| `SECURITY_BLOCKED` | `CHANGELOG.md:45` | usage in prose |
| `SECURITY_BLOCKED` | `BACKLOG-v1.1.md:459` | usage in prose (Item 11 summary) |
| `SECURITY_BLOCKED` | `BACKLOG-v1.2.md:21,330` | usage in prose (Item 1 problem statement; this file's own Item 11 problem statement) |
| `SECURITY_BLOCKED` | `README.md:9` | usage in prose (Status section) |
| `SECURITY_BLOCKED` | `docs/field-tests/2026-08-19-cross-agent-contract-test.md:53,62,83` | usage in a report (Task B scoring row + finding writeup) |
| `SECURITY_BLOCKED` | `personal-skills/solution-engineer/TEST-EVIDENCE.md:89` | usage in a report (S2 scenario, disclosed ambiguity) |
| `ENVIRONMENT_UNAVAILABLE` | `AGENTS.md:126` | definition |
| `ENVIRONMENT_UNAVAILABLE` | `ai-engineering/core/workflow.md:67` | definition |
| `ENVIRONMENT_UNAVAILABLE` | `personal-skills/solution-engineer/SKILL.md:178` | definition |
| `ENVIRONMENT_UNAVAILABLE` | `.claude/skills/engineer/modules/onboard-inherited.md:28` | definition |
| `ENVIRONMENT_UNAVAILABLE` | `.claude/skills/engineer/modules/setup-preflight.md:41` | definition |
| `ENVIRONMENT_UNAVAILABLE` | `.claude/skills/engineer/modules/setup-install.md:42` | definition |
| `ENVIRONMENT_UNAVAILABLE` | *(no report occurrence found anywhere)* | — |
| `NEEDS_HUMAN` | `AGENTS.md:127,129,132` | definition |
| `NEEDS_HUMAN` | `ai-engineering/core/workflow.md:63,64,67` | definition (crosswalk table, two rows, plus the whole-session-blocker note) |
| `NEEDS_HUMAN` | `personal-skills/solution-engineer/SKILL.md:179,181,184,197,198` | definition |
| `NEEDS_HUMAN` | `personal-skills/solution-engineer/references/provenance.md:75` | usage in prose |
| `NEEDS_HUMAN` | `.claude/skills/engineer/modules/onboard-inherited.md:28,39,107,136` | definition |
| `NEEDS_HUMAN` | `.claude/skills/engineer/modules/setup-preflight.md:40` | definition |
| `NEEDS_HUMAN` | `.claude/skills/engineer/modules/onboard-greenfield.md:60` | definition |
| `NEEDS_HUMAN` | `.claude/skills/engineer/modules/setup-install.md:41` | definition |
| `NEEDS_HUMAN` | `.claude/skills/engineer/modules/onboard-existing.md:47` | definition |
| `NEEDS_HUMAN` | `.claude/skills/engineer/modules/setup-configure.md:21` | definition |
| `NEEDS_HUMAN` | `.claude/skills/engineer/modules/context-mapping.md:68` | definition |
| `NEEDS_HUMAN` | `BACKLOG-v1.1.md:311,313,351,459,484,485,489` | usage in a report (Items 8, 9, 11 + closeout table + overall reasoning) |
| `NEEDS_HUMAN` | `BACKLOG-v1.2.md:49,69,191,225,292,317,350,374` | usage in a report (Items 1, 2, 6, 7, 9, 10, 11, 12) |
| `NEEDS_HUMAN` | `BACKLOG-v1.2.md:21,41,330` | usage in prose (Item 1 problem statement, this file's own Item 11 discussion) |
| `NEEDS_HUMAN` | `CHANGELOG.md:45,51,78` | usage in prose |
| `NEEDS_HUMAN` | `BACKLOG-v0.3.md:301,338` | usage in prose |
| `NEEDS_HUMAN` | `README.md:9` | usage in prose |
| `NEEDS_HUMAN` | `personal-skills/solution-engineer/TEST-EVIDENCE.md:82,89` | usage in a report (S2 scenario result + disclosed ambiguity) |
| `NEEDS_HUMAN` | `docs/field-tests/2026-08-19-cross-agent-contract-test.md:53,62,85,88` | usage in a report (Task B scoring + finding writeup) |

### Local vocabulary (`ai-engineering/core/workflow.md:49-67`)

| Term | File:line | Context |
|---|---|---|
| `DONE` (local) | `ai-engineering/core/workflow.md:51,61,67,88,90` | definition |
| `DONE` (local) | `personal-skills/solution-engineer/SKILL.md:195,208,213` | definition |
| `DONE` (local) | `personal-skills/solution-engineer/references/workflow-and-gates.md:58,65` | definition |
| `DONE` (local) | `BACKLOG-v0.3.md:159,269,328,329,331,332,333,334,335` | mixed: `159`/`269` definition/prose (naming the legend), `328`-`335` usage in a report |
| `DONE` (local) | `BACKLOG-v1.1.md:61,95,124,163,190,243,245,281,429,455,476-483,486,487` | usage in a report (per-item local status + closeout table) |
| `DONE` (local) | `BACKLOG-v1.2.md:131,158,251` | usage in a report (Items 4, 5, 8 — status-transition history) |
| `DONE` (local) | `CHANGELOG.md:49` | usage in prose |
| `DONE` (local) | `docs/field-tests/2026-08-19-pcc-campaign-close-and-v1.1-round2.md:57` | usage in a report (external PCC register tally) |
| `DONE` (local) | `docs/field-tests/2026-08-19-pcc-pilot-2.md:46,47,99` | mixed: `46` usage in a report (external register's own, unrelated `DONE` convention), `47`/`99` usage in prose |
| `NOT_STARTED` | `ai-engineering/core/workflow.md:52,62,69` | definition |
| `NOT_STARTED` | `personal-skills/solution-engineer/SKILL.md:196` | definition |
| `NOT_STARTED` | `BACKLOG-v0.3.md:270,304` | usage in prose (`OPEN`-split discussion) |
| `NOT_STARTED` | `BACKLOG-v1.1.md:245` | usage in prose (narrates a sub-item's earlier, now-superseded state) |
| `NOT_STARTED` | `BACKLOG-v1.2.md:49,111,191,225,251,292,317,350,374` | usage in a report (Items 1, 3, 6, 7, 8, 9, 10, 11, 12) |
| `NOT_STARTED` | `BACKLOG-v1.2.md:337` | usage in prose (this file's own Item 11 discussion) |
| `DEFERRED` | `ai-engineering/core/workflow.md:53,63,67,90` | definition |
| `DEFERRED` | `personal-skills/solution-engineer/SKILL.md:197,213` | definition |
| `DEFERRED` | `personal-skills/solution-engineer/references/workflow-and-gates.md:66` | definition |
| `DEFERRED` | `BACKLOG-v0.3.md:270,304,330` | mixed: `270`/`304` prose, `330` usage in a report |
| `DEFERRED` | `BACKLOG-v1.1.md:311,351,484,485` | usage in a report (Items 8, 9) |
| `DEFERRED` | `BACKLOG-v1.2.md:41,69,337` | mixed: `41` prose (Item 1), `69` usage in a report (Item 2), `337` prose (Item 11) |
| `DEFERRED` | `CHANGELOG.md:49` | usage in prose |
| `DEFERRED` | `docs/field-tests/2026-08-19-pcc-campaign-close-and-v1.1-round2.md:57` | usage in a report (external register tally) |
| `NEEDS_DECISION` | `ai-engineering/core/workflow.md:54,64,89` | definition |
| `NEEDS_DECISION` | `personal-skills/solution-engineer/SKILL.md:198,211` | definition |
| `NEEDS_DECISION` | `personal-skills/solution-engineer/references/workflow-and-gates.md:63` | definition |
| `NEEDS_DECISION` | `BACKLOG-v0.3.md:270` | usage in prose |
| `NEEDS_DECISION` | `BACKLOG-v1.2.md:345` | usage in a report (this file's own Item 11 — the status this study-only gate is defined to close as, i.e. this document is that closure) |
| `CONTESTED` | `ai-engineering/core/workflow.md:55,65,88,90` | definition |
| `CONTESTED` | `personal-skills/solution-engineer/SKILL.md:199,209,213` | definition |
| `CONTESTED` | `personal-skills/solution-engineer/references/workflow-and-gates.md:59,67` | definition |
| `CONTESTED` | `BACKLOG-v0.3.md:160,270` | usage in prose |
| `CONTESTED` | `docs/field-tests/2026-08-19-pcc-pilot-2.md:99` | usage in prose |
| `CONTESTED` | *(no report ever actually assigns this status — see §2)* | — |

### Other status-like terms found

| Term | File:line | Context |
|---|---|---|
| `OPEN` (register/issue status) | `ai-engineering/templates/ISSUES.template.md:21,26` | definition (per-issue status column, distinct 4th vocabulary: `OPEN \| FIXED (commit [REF])`) |
| `OPEN` (register/issue status) | `.claude/skills/engineer/modules/onboard-inherited.md:120` | definition (`OPEN` -> `FIXED` transition) |
| `OPEN` (pilot #2's collision term) | `BACKLOG-v0.3.md:159,191,296,301,304` | usage in prose (the collision this study was asked to cover — see §3) |
| `OPEN` (pilot #2's collision term) | `BACKLOG-v1.2.md:335` | usage in prose (this file's own Item 11 problem statement, restating the same finding) |
| `OPEN` (pilot #2's register, external repo) | `docs/field-tests/2026-08-19-pcc-pilot-2.md:19,47,99` | usage in a report (the actual `OPEN`/`NEEDS DECISION` values the external PCC register used — see Scope note below) |
| `OPEN` (issue-status template) | `BACKLOG-v0.2.md:44` | usage in prose (references the `OPEN`/`FIXED` convention while describing an unrelated item) |
| `FIXED (commit [REF])` | `ai-engineering/templates/ISSUES.template.md:21,26` | definition |
| `FIXED (commit [REF])` | `.claude/skills/engineer/modules/onboard-inherited.md:120` | definition |
| `PASS` / `CONDITIONAL PASS` / `FAIL` (redteam release verdict) | `ai-engineering/core/redteam.md:65,66,67` | definition (severity->release rules) |
| `PASS` / `CONDITIONAL PASS` / `FAIL` (redteam release verdict) | `ai-engineering/templates/REDTEAM-REPORT.template.md:24` | definition |
| `PASS` / `CONDITIONAL PASS` / `FAIL` (redteam release verdict) | `personal-skills/solution-engineer/references/redteam-modes.md:55,57,59` | definition |
| `PASS` / `CONDITIONAL PASS` / `FAIL` (independent-reviewer's own verdict) | `.claude/agents/independent-reviewer.md:21` | definition |
| `PASS` / `CONDITIONAL PASS` / `FAIL` (Codex cross-model fallback, mirrors reviewer) | `ai-engineering/adapters/codex/README.md:32` | definition |
| `PASS` / `CONDITIONAL PASS` / `FAIL` | `.claude/skills/engineer/modules/redteam.md:29` | definition (pointer to the rule) |
| `PASS` | `BACKLOG-v0.3.md:314` | usage in prose (explicitly names this as a *different*, deliberately-uncrosswalked vocabulary — see §3) |
| `PASS` | `BACKLOG-v1.1.md:421` | usage in a report (test-run tally, "4/4 PASS") |
| `PASS` (scratch-test scenario results, S1-S4) | `personal-skills/solution-engineer/TEST-EVIDENCE.md:19,32,64,105,141,192-195,197` | usage in a report (a *third* sense: pass/fail of a scripted test scenario, not a release verdict or a task-completion status) |
| `PASS` (mechanical-checker self-tests) | `ai-engineering/checks/TEST-EVIDENCE.md:38-44,79-81,120-125,177-178` | usage in a report (a *fourth* sense: the checker scripts' own unit-test results — "does this shell script behave correctly" — unrelated to any of the above) |

**Scope note on the pilot #2 evidence above:** `REFACTOR-REGISTER.md`
and `ISSUES.md` (the PCC pilot repository's own files, using
`DONE`/`OPEN`/`NEEDS DECISION`/`CONTESTED`) are **not part of this
repository** — they exist only in the external pilot repo. This
repository holds only the field-test *reports about* that register
(`docs/field-tests/2026-08-19-pcc-pilot-2.md` and
`2026-08-19-pcc-campaign-close-and-v1.1-round2.md`), which is why the
table above cites those report files, not the register itself, for
that evidence.

---

## 2. Crosswalks actually exercised

The defined crosswalk (`ai-engineering/core/workflow.md:59-65`,
copied at `personal-skills/solution-engineer/SKILL.md:195-199`) has
five rows. Counting every place a real item (not a template, not a
hypothetical example) was actually closed with a local status and
crosswalked to a terminal one, across `BACKLOG-*.md` closeouts and
`docs/field-tests/*.md`:

| Defined mapping | Times exercised | Example location |
|---|---|---|
| `DONE` -> `DONE_VERIFIED` | **23** (7 in `BACKLOG-v0.3.md`'s closeout table + 1 overall; 9 in `BACKLOG-v1.1.md`'s per-item lines + 10 in its closeout table + 1 overall, minus double-counted restatements = 9 distinct items, each stated twice; 3 in `BACKLOG-v1.2.md`) | `BACKLOG-v1.1.md:61` (Item 1) |
| `DONE` -> `CONDITIONAL_PASS` (with documented caveat) | **0** — never exercised. Every real `DONE` item found crosswalks to `DONE_VERIFIED`; the caveated branch of this row is defined but unused. | — |
| `DEFERRED` -> `CONDITIONAL_PASS` (round/owner assigned) | **1** — `BACKLOG-v0.3.md`'s zero-install sub-tier, and only after a later update once a round/owner was actually assigned (line 345) | `BACKLOG-v0.3.md:330,345` |
| `DEFERRED` -> `NEEDS_HUMAN` (no round/owner) | **3** — `BACKLOG-v1.1.md` Items 8 and 9, `BACKLOG-v1.2.md` Item 2 | `BACKLOG-v1.1.md:311` (Item 8) |
| `NOT_STARTED` -> `REPLAN_REQUIRED` | **0 as defined.** See finding below — every real `NOT_STARTED` item instead crosswalks to `NEEDS_HUMAN`. | — |
| `NEEDS_DECISION` -> `NEEDS_HUMAN` | **0 prior to this document.** This study-only gate (`BACKLOG-v1.2.md` Item 11) is the first real item to close `NEEDS_DECISION`, and this update is the first real exercise of this row. | `BACKLOG-v1.2.md:345` (this gate) |
| `CONTESTED` -> `REPLAN_REQUIRED` | **0** — no item in any `BACKLOG-*.md` or field-test in this repo has ever closed `CONTESTED`. | — |

**Finding not in the defined table: `NOT_STARTED` -> `NEEDS_HUMAN` is
the mapping actually used, every time, instead of the defined
`NOT_STARTED` -> `REPLAN_REQUIRED`.** Every `NOT_STARTED` item found in
§1 (`BACKLOG-v1.2.md` Items 1, 6, 7, 9, 10, 11, 12 — 7 instances) uses
`-> crosswalk NEEDS_HUMAN`, not `REPLAN_REQUIRED`. This is a
systematic deviation from `workflow.md`'s own defined table, not a
one-off typo — it recurs across every backlog-item author who has ever
closed a `NOT_STARTED` item in this repo (including this session,
following the established pattern without cross-checking it against
the table). A plausible reason: `REPLAN_REQUIRED`'s own definition
("a plan needs to be redone") and its Return-paths entry ("Plan or
baseline gap -> phase 5") both presuppose a plan existed and needs
rework — but a `NOT_STARTED` backlog item, in every actual use found
here, never had a plan attempted at all; "logged only, needs a human
to schedule it" fits `NEEDS_HUMAN`'s own definition ("a safe
alternative... requires human approval/scheduling") far better than
`REPLAN_REQUIRED`'s. Nothing mechanically enforces the defined table,
so this drift was never caught until this study.

**Also observed:** `BACKLOG-v1.2.md` Item 5 uses a status **history**
(`CONDITIONAL_PASS -> DONE -> crosswalk DONE_VERIFIED`) — a terminal
status (`CONDITIONAL_PASS`) that was itself later superseded by a
fuller local-to-terminal close. The crosswalk table only defines
local-to-terminal mappings; it has no defined vocabulary for a
terminal status evolving into a different terminal status across
sessions, which is a real, recurring shape in this repo's own history
(see also `BACKLOG-v0.3.md:337-347`, the zero-install sub-tier's
`NEEDS_HUMAN` -> `CONDITIONAL_PASS` update once a round was assigned).

---

## 3. Recorded confusion

| Instance | Terms involved | Recorded in |
|---|---|---|
| **`OPEN`-term collision** — pilot #2's external register used one term, `OPEN`, for two distinct meanings ("not yet attempted" and "investigated, deliberately left as its own scoped future item"). Neither meaning crosswalks cleanly onto a single `AGENTS.md` target (one needs `REPLAN_REQUIRED`, the other `CONDITIONAL_PASS`/`NEEDS_HUMAN`). Fixed by splitting the local legend's `OPEN` into `NOT_STARTED` and `DEFERRED` — a real vocabulary change made in response, not a rename. | `OPEN`, `NOT_STARTED`, `DEFERRED` | `BACKLOG-v0.3.md:294-306` ("Lessons from Round 2"); restated at `ai-engineering/core/workflow.md:69` and `BACKLOG-v1.2.md:335` (this cycle's Item 11 problem statement, sourcing the same finding) |
| **`SECURITY_BLOCKED` vs. `NEEDS_HUMAN` gap** — two independent agents (a solo Claude Code scratch-test and a separate non-Anthropic agent in the cross-agent test), in two independent sessions, chose different terminal statuses for the same underlying situation shape (a safe alternative identified, awaiting approval). Confirmed a real, recurring ambiguity, not a one-off; fixed by adding an explicit disambiguation rule. | `SECURITY_BLOCKED`, `NEEDS_HUMAN` | First flagged: `personal-skills/solution-engineer/TEST-EVIDENCE.md:88-91` (S2 scenario). Confirmed as recurring and fixed: `docs/field-tests/2026-08-19-cross-agent-contract-test.md:53,62-91`. Rule now lives at `AGENTS.md:129-133` and `personal-skills/solution-engineer/SKILL.md:180-185`. |
| **Verification-contract vocabulary not used by the external PCC register at all** — `AGENTS.md`'s terminal statuses never appear anywhere in the external `REFACTOR-REGISTER.md` or campaign `ISSUES.md` entries; the campaign instead used its own third, undocumented-in-this-repo legend (`DONE`/`OPEN`/`NEEDS DECISION`/`CONTESTED`) that happens to share three of five spellings with this framework's *local* legend but was not derived from it and predates the local legend's naming. | `DONE_VERIFIED`, `CONDITIONAL_PASS`, and the external register's own `DONE`/`OPEN`/`NEEDS DECISION`/`CONTESTED` | `docs/field-tests/2026-08-19-pcc-pilot-2.md:47,99` |
| **Redteam's release verdict deliberately left uncrosswalked** — `REDTEAM-REPORT.template.md`'s `PASS \| CONDITIONAL PASS \| FAIL` vocabulary was explicitly noticed as wording-similar to `AGENTS.md`'s `CONDITIONAL_PASS`, observed to answer a different question (release-readiness vs. task-completion), and deliberately not merged or crosswalked — a conscious decision, not an oversight, but it means a fourth adjacent vocabulary exists in this repo with no stated relationship to the other three. | `CONDITIONAL_PASS`, `PASS`/`CONDITIONAL PASS`/`FAIL` | `BACKLOG-v0.3.md:313-317` ("Lessons from Round 2") |
| **`NOT_STARTED` -> `NEEDS_HUMAN` drift** (new finding, this study) — see §2. Never previously recorded as a confusion; surfaced only by this gate's exhaustive grep, since nothing mechanically checks the defined crosswalk against actual usage. | `NOT_STARTED`, `REPLAN_REQUIRED`, `NEEDS_HUMAN` | This document, §2 |

---

## 4. Information-loss analysis (trade-offs only, no recommendation)

### (a) Keep both tiers as-is

- **Lost:** nothing further lost; status quo. The `NOT_STARTED` ->
  `NEEDS_HUMAN` drift (§2) and the redteam-vocabulary adjacency (§3)
  remain live, undetected-by-tooling risks — a future item could repeat
  either without anything catching it, exactly as happened here.
- **Simplified:** nothing changes; zero migration cost, zero risk of
  breaking an existing reference to either vocabulary across 5+
  `BACKLOG-*.md` files, `docs/field-tests/`, and both skill copies.

### (b) Single vocabulary: drop the local set, use terminal statuses everywhere

- **Lost:** the local legend's per-item granularity that the terminal
  set was never designed for — `NOT_STARTED` (needs scoping) and
  `CONTESTED` (evidence conflict, needs a fresh decision) have no
  terminal-status equivalent at the per-item level (`workflow.md:67`
  states this explicitly: `SECURITY_BLOCKED`/`ENVIRONMENT_UNAVAILABLE`
  are whole-session blockers, and by the same logic the terminal set
  has no "not yet attempted" or "evidence conflict" concept at all,
  only "replan required" as a catch-all). Register-scale audits (56
  items in pilot #2) and Gates would lose the distinction between "an
  item was never touched" and "an item was investigated and paused" —
  exactly the distinction `NOT_STARTED`/`DEFERRED` were split apart to
  preserve after the `OPEN` collision (§3). Collapsing back to one
  vocabulary risks recreating that exact collision one level up,
  against `REPLAN_REQUIRED` as the forced single target for both.
- **Simplified:** one vocabulary to teach, learn, and grep for instead
  of two plus a mapping table; removes the crosswalk table itself
  (`workflow.md:57-67`) and its now-confirmed silent drift (§2)
  entirely, since there is nothing left to drift from.

### (c) Single vocabulary: keep only the local set, derive the terminal status by rule

- **Lost:** the terminal set's whole-session concepts
  (`SECURITY_BLOCKED`, `ENVIRONMENT_UNAVAILABLE`) that `workflow.md`
  itself says have "no per-item equivalent" in the local legend — a
  per-item vocabulary has no natural home for "this whole session is
  blocked," so a derivation rule would need to invent a session-level
  exception on top of a set designed for item-level granularity, which
  is a structural mismatch, not a naming one. `REQUIREMENT_AMBIGUOUS`
  also has no local counterpart at all (§1: five definition sites, zero
  report usages found anywhere in this repo) — its derivation rule
  would be untested by any real precedent.
- **Simplified:** register/Gate work (already local-status-native)
  needs no translation step at all; a single external-facing status
  string is still derivable for anything that needs one (e.g. a CI
  gate), just computed rather than separately authored.

### (d) Keep both, but mechanically enforce the crosswalk (extend `check-verification-report.sh`)

- **Lost:** nothing semantic — both vocabularies and their intended
  distinctions survive untouched.
- **Simplified:** nothing about the vocabulary itself; this option
  adds tooling, not simplification. Concretely, per `ai-engineering/
  checks/check-verification-report.sh`'s current source (read this
  round): it validates only that five evidence *field labels* are
  present and non-empty (`Command or procedure` / `Result` / `Pass or
  fail` / `Evidence location` / `Remaining risk`) — it does not inspect
  the *value* of any status field, does not know either vocabulary's
  term list, and does not check crosswalk correctness at all. Building
  this would be new capability, not an extension of existing logic:
  it would need to (i) recognize a local-status assignment in a
  register/Gate context, (ii) recognize its paired terminal-status
  crosswalk, (iii) validate the pair against the defined table, and
  (iv) handle the two-branch rows (`DONE`, `DEFERRED`) correctly, which
  `workflow.md:67` states are "decidable from an observable fact" —
  meaning the checker would also need to detect whether a caveat is
  documented or a round/owner is assigned, not just pattern-match
  strings. This is exactly the class of check that would have caught
  the `NOT_STARTED` -> `NEEDS_HUMAN` drift (§2) mechanically instead of
  by a manual full-repo grep.

---

## 5. Files each design would touch (for sizing a future decision gate)

| Design | Files touched |
|---|---|
| **(a) Keep as-is** | None. |
| **(b) Terminal-only** | `AGENTS.md` (extend terminal list or add rule for the lost granularity), `ai-engineering/core/workflow.md` (remove local legend, register-scale/Gate sections rewritten to use terminal statuses directly), `personal-skills/solution-engineer/SKILL.md` + `references/workflow-and-gates.md` (mirror), every `BACKLOG-*.md` with closed items (historical local statuses would need a decision: leave as historical record, or rewrite — `BACKLOG-v0.3.md`, `BACKLOG-v1.1.md`, `BACKLOG-v1.2.md`), `docs/field-tests/2026-08-19-pcc-campaign-close-and-v1.1-round2.md` (cites the local legend). |
| **(c) Local-only** | `AGENTS.md` (remove/replace terminal list with a derivation rule or pointer), `ai-engineering/core/workflow.md` (add the derivation rule, handle the session-level-blocker gap), `personal-skills/solution-engineer/SKILL.md` + `references/workflow-and-gates.md` (mirror), every process document that currently ends with a terminal status per `AGENTS.md`'s "Completion status" contract (`.claude/skills/engineer/modules/*.md` — 7 files reference terminal statuses per §1), `CLAUDE.md`/adapter docs referencing terminal statuses. |
| **(d) Mechanical enforcement** | `ai-engineering/checks/check-verification-report.sh` and its `.ps1` twin (new logic, not a tweak — see §4d), a new or extended `TEST-EVIDENCE.md` fixture set to validate it (mirroring the existing pattern in `ai-engineering/checks/TEST-EVIDENCE.md`), optionally `.claude/settings.json`/hooks if wired for enforcement at commit/session-close time (BACKLOG-v1.2 Item 6 territory — related but separate scope). No change to `AGENTS.md` or `workflow.md` themselves. |

---

## Evidence

- Command or procedure: repo-wide `Grep` for each of the 12 defined
  status terms plus `OPEN`/`FIXED`/`PASS`/`CONDITIONAL PASS`/`FAIL`,
  cross-checked by direct `Read` of every file with a truncated grep
  line and every file containing a crosswalk table or closeout section.
- Result: full occurrence table (§1), exercised-crosswalk count (§2),
  three previously-recorded confusion instances plus one new finding
  (§3), trade-off analysis with no recommendation (§4), file-impact
  sizing per design (§5).
- Pass or fail: N/A — this is an evidence-gathering gate, not a
  pass/fail check.
- Evidence location: this file.
- Remaining risk: this study covers this repository only — the
  external PCC pilot repository's own `REFACTOR-REGISTER.md`/
  `ISSUES.md` were not re-read directly (not part of this repo; cited
  via the field-test reports that quote them, per the Scope note in
  §1). A decision-owner relying on this study for anything about the
  external register's *current* state, rather than what the field-test
  reports recorded about it, should re-verify against that repo
  directly.

## Decision

**Date:** 2026-08-26. **Option chosen:** design (b) — a single
vocabulary, `AGENTS.md`'s terminal statuses, used everywhere. The
local set (`DONE`/`NOT_STARTED`/`DEFERRED`/`NEEDS_DECISION`/
`CONTESTED`) and the crosswalk table are retired for all files dated
2026-08-26 or later; files predating that date keep the retired
vocabulary as an accurate historical record (see `CHANGELOG.md`).

**Rationale:** the crosswalk table was never followed in practice —
§2 found every real `NOT_STARTED` item in this repo's own backlog
history crosswalked to `NEEDS_HUMAN`, not the table's defined
`REPLAN_REQUIRED`, a systematic deviation that went undetected because
nothing mechanically enforced the table (design (d) would have caught
it; design (a), the status quo, would not have). Beyond that drift,
the local set was found to carry no distinction the terminal set
cannot express on its own: unfinished work now has a plain-prose
convention (`Status: open — scheduled <round/owner>` / `Status: open —
unscheduled`) with no vocabulary term to keep in sync with a second
system, and Gates close directly with a terminal status per gate type
rather than through an intermediate local status and a mapping step.
Implementation: `ai-engineering/core/workflow.md`, `AGENTS.md`,
`personal-skills/solution-engineer/SKILL.md` and its `references/`
files, and `BACKLOG-v1.2.md`'s own item statuses were updated to match;
full diff and verification in the commits closing `BACKLOG-v1.2.md`
Item 11.
