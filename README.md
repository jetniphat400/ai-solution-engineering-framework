# AI-Agnostic User-Centered Solution Engineering Framework

A portable engineering baseline with a full Claude Code adapter and native `AGENTS.md` support for OpenAI Codex. (Codex support today is native-file-discovery only — no Codex-specific skill, routing, or onboarding exists yet; see `BACKLOG-v1.1.md` Item 7.)

Everything needed to adopt, operate, and extend this framework lives in this repository — no external service, hosted component, or separate download beyond the one-time source checkout `SETUP.md` describes.

## Status

`v1.0.0` — first public release. Field-tested twice (`docs/field-tests/`), both times by this framework's own authors against the same internal repository — real evidence, but limited: no independent replication, no control, no quantitative metric yet. See `BACKLOG-v1.1.md` Items 5-6 for the planned evidence-and-limitations statement and an independently-replicable field-test template. Licensed under MIT — see `LICENSE`.

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
