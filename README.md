# AI-Agnostic User-Centered Solution Engineering Framework

A portable engineering baseline: a vendor-neutral core contract (`AGENTS.md`, `ai-engineering/`) plus a full Claude Code adapter. The core contract has been cross-tested against Claude Code and one other coding agent on identical tasks — see the "Status" section below for what that test does and doesn't establish. `/engineer`'s router, red-team modes, and onboarding modules remain Claude-Code-specific; other agents pick up the core contract via native `AGENTS.md` discovery, not this skill machinery (see `BACKLOG-v1.1.md` Item 7).

Everything needed to adopt, operate, and extend this framework lives in this repository — no external service, hosted component, or separate download beyond the one-time source checkout `SETUP.md` describes.

## Status

`v1.1.0`. Field-tested three times (`docs/field-tests/`); the first two were run by this framework's own authors against the same internal repository (real evidence, but limited: no independent replication, no control). The third cross-tested the core `AGENTS.md` contract against Claude Code and one non-Anthropic coding agent, given identical tasks on identical repos — 7 of 8 scored dimensions matched exactly or in substance (lane classification, evidence discipline, independent identification of a real vulnerability, and consistent handling of an embedded prompt-injection attempt), with one real gap found and fixed (a terminal-status ambiguity, `SECURITY_BLOCKED` vs. `NEEDS_HUMAN`). Full result: `docs/field-tests/2026-08-19-cross-agent-contract-test.md`. This is real evidence for cross-agent portability of the core contract specifically — at n=1, one agent, one repo, two small tasks — not a general "works with any agent" claim. Licensed under MIT — see `LICENSE`.

## What this starter kit provides

- A vendor-neutral `AGENTS.md` repository contract
- A nine-phase user-to-production workflow
- Fast, Standard, and Controlled processing lanes
- Architecture assessment and incremental refactoring guidance
- Verification, protected test assets, adversarial red-team review, and human approvals
- Claude Code adapter with project settings, skills, rules, and a read-only reviewer
- OpenAI Codex adapter based on `AGENTS.md`
- Templates for specifications, plans, ADRs, refactoring, red-team, verification, and completion reports

## Recommended first use

Two install tiers exist: Full (the complete module tree) and Light (a
single configured `AGENTS.md`, no module tree). The steps below are the
Full path — see `SETUP.md` for both tiers and how to choose.

Start with a non-critical repository that your team understands well.

1. Back up or commit the current repository.
2. Copy this starter kit into the repository root.
3. Replace all `[PROJECT ...]` placeholders in `AGENTS.md`.
4. Fill in the real build, test, lint, and run commands.
5. Review `.claude/settings.json` before using Claude Code.
6. Start in approval-based mode. Do not enable direct production access.
7. Run one Standard Lane pilot task and review the evidence.

See `SETUP.md` for detailed instructions on either tier.

## License

MIT — see `LICENSE`.
