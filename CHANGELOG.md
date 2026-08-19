# Changelog

## Versioning rule

Each completed backlog cycle bumps the `VERSION` file's minor version
and records an entry below, in the same commit that closes out that
cycle's first round. A backlog cycle (e.g. "v0.2") can span several
rounds — Round 3a bumped `VERSION` to `0.2.0` when it opened the v0.2
backlog's final stretch; Round 3b, which closes every remaining v0.2
item, confirms `0.2.0` rather than bumping again, since it's still the
same cycle. The next `[MAJOR].[MINOR]` bump happens when a new backlog
cycle (a new `BACKLOG-vX.Y.md`) opens. This keeps `VERSION` and the
backlog in lockstep so a git-log-depth guess is never needed to answer
"what version is this" (see Round 3a below, which existed to fix
exactly that ambiguity).

## 1.1.0

Closes the v1.1 backlog (see `BACKLOG-v1.1.md`), theme "proof &
enforcement" — three rounds:

- **Round 1** — the `solution-engineer` zero-install skill, derived
  fresh from v1.0 canon after the externally-prototyped draft was
  confirmed lost (not reconstructed from it). Tested against 4
  scratch-repo scenarios, 4/4 pass. `SETUP.md` documents it as the
  third tier alongside Full and Light.
- **Round 2** — four mechanical enforcement checkers
  (`ai-engineering/checks/`): verification-evidence linting,
  protected-path change detection, a CI regression-gate script and
  example template, and skill-supply-chain allowlist visibility.
  Validated against synthetic fixtures and, read-only, against the PCC
  pilot repo — two real bugs found and fixed in the process (a bash
  `set -e` silent-abort, a test-count digit-concatenation bug), plus a
  pre-existing mismatch between `verification.md`'s stated evidence
  format and `VERIFICATION-REPORT.template.md`'s actual table, found
  and fixed before the checker could even be built against it.
- **Round 3** — field test #3 (the PCC campaign's full closure, 58/58
  items terminal, 112->219 tests, and the framework's first real
  Tier-3 controlled comparison); two real gaps found in the Tier-3
  protocol itself (wall-time incomparable across differing commit
  granularity, an unbounded escaped-defects window) and fixed in
  `docs/field-tests/TEMPLATE.md`; a cross-agent contract test (Claude
  Code vs. one non-Anthropic agent, identical tasks) that matched on
  7 of 8 scored dimensions and surfaced one real, now-fixed terminal-
  status ambiguity (`SECURITY_BLOCKED` vs. `NEEDS_HUMAN`); `README.md`'s
  "AI-agnostic" framing recalibrated to that evidence rather than left
  as structural inspection alone.

All 11 `BACKLOG-v1.1.md` items closed: 9 `DONE`, 2 `DEFERRED` (direct-
from-URL install, an unattended-execution lane profile — both honestly
crosswalked to `NEEDS_HUMAN`, no successor round assigned yet, per the
same rule applied at the `v1.0.0` closeout).

## 1.0.0

First public version. All items in the v0.3 backlog (see
`BACKLOG-v0.3.md`) now closed under the "v1.0 = adoption" cut-line:

- **Round 1** — claim confidence labels (`verification.md`,
  `redteam.md`, promoted from the `engineer` skill's DETECT-only
  vocabulary to a standing verification-contract rule) and temporary
  security-bypass hygiene (`security.md`).
- **Round 2** — the Gate procedure (investigation / study-only /
  decision) and register-scale audit conventions (ID-prefix,
  lane-rationale, closeout mapping), sharing one five-state local-status
  legend crosswalked onto `AGENTS.md`'s terminal statuses
  (`ai-engineering/core/workflow.md`).
- **Round 3, Part A** — Full and Light install tiers documented as
  equals in `SETUP.md`, from a shared "Step 0: Get the framework
  source"; the clone-install-delete flow made explicit for the first
  time.
- **Round 3, Part B** — `BACKLOG-v1.1.md` seeded via self-audit
  (theme: "proof & enforcement") rather than an external import: which
  rules are voluntary-compliance-only vs. mechanizable, what the two
  field tests do/don't prove, and where the framework overclaims.
- **Round 3, Part C** — cycle closeout: every `BACKLOG-v0.3.md` item
  terminal-status'd per the Round 2 legend (one item, the zero-install
  sub-tier, honestly crosswalks to `NEEDS_HUMAN` rather than a
  rounded-up `CONDITIONAL_PASS` — reported, not smoothed over);
  `README.md` updated for public release (self-contained principle,
  evidence-and-limitations pointer, softened adapter-parity claim);
  `LICENSE` (MIT) added; `VERSION` bumped to `1.0.0` here.

## 0.2.0

All four rounds of the v0.2 backlog (see `BACKLOG-v0.2.md`), now fully
closed:

- **Round 1** — first-party docs carve-out, `ISSUES.template.md`, the
  skill supply-chain policy.
- **Round 2** — the unified `/engineer` entry point (shell, routing,
  setup modules) and the redteam mode upgrade.
- **Round 3a** — repairs from the first field-test pilot
  (`docs/field-tests/2026-07-31-pcc-pilot.md`): merge-safe installer
  scripts, a per-subpath `.claude/` conflict matrix, upgrade detection
  in `setup-preflight.md`, a thin `engineering-workflow` alias, and
  `setup-configure.md` scope gaps. `VERSION` bumped to `0.2.0` here.
- **Round 3b** — closes the backlog: the AI-maps-context procedure
  (`context-mapping.md`), the three onboard modules (inherited /
  existing / greenfield), router wiring, a provenance-tag sweep across
  `ai-engineering/core/**` and `ai-engineering/policies/**`, and
  discovery-doc fixes for both tensions Round 3a reported.

## 0.1.0 — Baseline

Framework v0.1 as designed: `AGENTS.md`, `CLAUDE.md`, `ai-engineering/`
core/policies/templates, and the Claude Code adapter.
